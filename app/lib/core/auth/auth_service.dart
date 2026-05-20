import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

import '../utils/logger.dart';

enum PinResult { ok, wrong, lockedOut, notSet }
enum BiometricResult { ok, unavailable, cancelled, failed }

/// Local authentication.
///
/// PIN: 4–8 digits. Stored as PBKDF2-HMAC-SHA256 with a 16-byte salt and
/// 200_000 iterations (overkill for offline brute force on Android Keystore-
/// backed storage, but cheap enough). Lockout after 5 consecutive failures
/// for 30 seconds, doubling for each additional failure.
///
/// Biometric: passes through to platform; no key release on success — we use
/// it as a UX gate only. The DB encryption key (future) is gated by PIN.
class AuthService {
  AuthService(this._storage);

  final FlutterSecureStorage _storage;
  final LocalAuthentication _local = LocalAuthentication();

  static const _kHash = 'pin_hash';
  static const _kSalt = 'pin_salt';
  static const _kFails = 'pin_fails';
  static const _kLockoutUntilMs = 'pin_lockout_until';

  Future<bool> hasPin() async {
    return (await _storage.read(key: _kHash)) != null;
  }

  Future<void> setPin(String pin) async {
    final salt = _randomBytes(16);
    final hash = _hashPin(pin, salt);
    await _storage.write(key: _kHash, value: base64Encode(hash));
    await _storage.write(key: _kSalt, value: base64Encode(salt));
    await _storage.write(key: _kFails, value: '0');
    await _storage.delete(key: _kLockoutUntilMs);
  }

  Future<int?> remainingLockoutMs() async {
    final s = await _storage.read(key: _kLockoutUntilMs);
    if (s == null) return null;
    final until = int.parse(s);
    final remain = until - DateTime.now().millisecondsSinceEpoch;
    return remain > 0 ? remain : null;
  }

  Future<PinResult> verifyPin(String pin) async {
    final hashB64 = await _storage.read(key: _kHash);
    final saltB64 = await _storage.read(key: _kSalt);
    if (hashB64 == null || saltB64 == null) return PinResult.notSet;

    final lockMs = await remainingLockoutMs();
    if (lockMs != null && lockMs > 0) return PinResult.lockedOut;

    final hash = _hashPin(pin, base64Decode(saltB64));
    final ok = _ctEq(hash, base64Decode(hashB64));
    if (ok) {
      await _storage.write(key: _kFails, value: '0');
      await _storage.delete(key: _kLockoutUntilMs);
      return PinResult.ok;
    }
    final fails = (int.tryParse(await _storage.read(key: _kFails) ?? '0') ?? 0) + 1;
    await _storage.write(key: _kFails, value: '$fails');
    if (fails >= 5) {
      // Exponential backoff: 30 s × 2^(fails-5).
      final lockSec = 30 * (1 << (fails - 5).clamp(0, 6));
      final until = DateTime.now().millisecondsSinceEpoch + lockSec * 1000;
      await _storage.write(key: _kLockoutUntilMs, value: '$until');
      return PinResult.lockedOut;
    }
    return PinResult.wrong;
  }

  Future<bool> biometricsAvailable() async {
    try {
      final supported = await _local.isDeviceSupported();
      if (!supported) return false;
      final canCheck = await _local.canCheckBiometrics;
      if (!canCheck) return false;
      final list = await _local.getAvailableBiometrics();
      return list.isNotEmpty;
    } catch (e) {
      log.w('biometricsAvailable failed: $e');
      return false;
    }
  }

  Future<BiometricResult> authenticateBiometric({String reason = 'Unlock Pulse Edge'}) async {
    try {
      final ok = await _local.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: true,
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Unlock Pulse Edge',
            cancelButton: 'Use PIN',
          ),
          IOSAuthMessages(cancelButton: 'Use PIN'),
        ],
      );
      return ok ? BiometricResult.ok : BiometricResult.cancelled;
    } catch (e) {
      log.w('biometric auth error: $e');
      return BiometricResult.failed;
    }
  }

  Future<void> wipe() async {
    await _storage.deleteAll();
  }

  // ─── helpers ───────────────────────────────────────────────────────────

  Uint8List _randomBytes(int n) {
    final r = math.Random.secure();
    return Uint8List.fromList(List<int>.generate(n, (_) => r.nextInt(256)));
  }

  // PBKDF2-HMAC-SHA256, 200_000 iterations, 32-byte output.
  Uint8List _hashPin(String pin, List<int> salt) {
    const iterations = 200000;
    const dkLen = 32;
    final pwBytes = utf8.encode(pin);
    final hmac = Hmac(sha256, pwBytes);
    final blocks = (dkLen / 32).ceil();
    final out = Uint8List(blocks * 32);
    for (var i = 1; i <= blocks; i++) {
      final block = Uint8List(salt.length + 4)
        ..setRange(0, salt.length, salt)
        ..buffer.asByteData().setUint32(salt.length, i);
      var u = hmac.convert(block).bytes;
      final t = Uint8List.fromList(u);
      for (var k = 1; k < iterations; k++) {
        u = hmac.convert(u).bytes;
        for (var j = 0; j < t.length; j++) {
          t[j] ^= u[j];
        }
      }
      out.setRange((i - 1) * 32, i * 32, t);
    }
    return Uint8List.sublistView(out, 0, dkLen);
  }

  bool _ctEq(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var x = 0;
    for (var i = 0; i < a.length; i++) {
      x |= a[i] ^ b[i];
    }
    return x == 0;
  }
}
