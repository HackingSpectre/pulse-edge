import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/db/database.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/widgets.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  int _sex = 0;
  int _birthYear = DateTime.now().year - 25;
  bool _loaded = false;

  Future<void> _load() async {
    if (_loaded) return;
    _loaded = true;
    final p = await ref.read(profileRepoProvider).get();
    if (p == null) return;
    setState(() {
      _name.text = p.name;
      _username.text = p.username == null ? '' : '@${p.username}';
      _sex = p.sex;
      _birthYear = p.birthYear;
      _height.text = p.heightCm?.toStringAsFixed(0) ?? '';
      _weight.text = p.weightKg?.toStringAsFixed(0) ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref
        .read(profileRepoProvider)
        .save(
          ProfilesCompanion(
            name: Value(_cleanName(_name.text)),
            username: Value(_cleanUsername(_username.text)),
            sex: Value(_sex),
            birthYear: Value(_birthYear),
            heightCm: Value(double.tryParse(_height.text)),
            weightKg: Value(double.tryParse(_weight.text)),
            createdAtMs: Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile updated.')));
    context.go(Routes.settings);
  }

  String _cleanName(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? 'Friend' : trimmed;
  }

  String? _cleanUsername(String value) {
    final username = value.trim().replaceAll(RegExp(r'\s+'), '_');
    if (username.isEmpty) return null;
    return username.startsWith('@') ? username.substring(1) : username;
  }

  @override
  Widget build(BuildContext context) {
    final years = List<int>.generate(80, (i) => DateTime.now().year - 5 - i);
    return NeuScaffold(
      title: 'Profile',
      showBack: true,
      onBack: () => context.go(Routes.settings),
      scrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NeuTextField(
            controller: _name,
            label: 'Name',
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: T.space5),
          NeuTextField(
            controller: _username,
            label: 'Username',
            hint: 'optional',
            icon: Icons.alternate_email_rounded,
          ),
          const SizedBox(height: T.space5),
          Text('Sex assigned at birth'.toUpperCase(), style: T.label),
          const SizedBox(height: T.space2),
          Wrap(
            spacing: T.space2,
            runSpacing: T.space2,
            children: [
              for (final entry in const [
                MapEntry(1, 'Male'),
                MapEntry(2, 'Female'),
                MapEntry(3, 'Other'),
                MapEntry(0, 'Prefer not to say'),
              ])
                NeuChip(
                  label: entry.value,
                  selected: _sex == entry.key,
                  onPressed: () => setState(() => _sex = entry.key),
                ),
            ],
          ),
          const SizedBox(height: T.space5),
          Text('Birth year'.toUpperCase(), style: T.label),
          const SizedBox(height: T.space2),
          NeuSurface(
            depth: NeuDepth.sunken,
            borderRadius: T.brMd,
            padding: const EdgeInsets.symmetric(
              horizontal: T.space4,
              vertical: T.space3,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _birthYear,
                isExpanded: true,
                style: T.body,
                onChanged: (v) {
                  if (v != null) setState(() => _birthYear = v);
                },
                items: [
                  for (final y in years)
                    DropdownMenuItem(value: y, child: Text('$y')),
                ],
              ),
            ),
          ),
          const SizedBox(height: T.space5),
          Row(
            children: [
              Expanded(
                child: NeuTextField(
                  controller: _height,
                  label: 'Height (cm)',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: T.space4),
              Expanded(
                child: NeuTextField(
                  controller: _weight,
                  label: 'Weight (kg)',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          const SizedBox(height: T.space7),
          NeuButton(
            label: 'Save',
            variant: NeuButtonVariant.filled,
            expanded: true,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
