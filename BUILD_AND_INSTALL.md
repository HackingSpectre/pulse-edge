# Build and Install Pulse Edge APK

Use these commands whenever you want to bundle the Flutter app as an APK and send it to your phone through USB.

## 1. Go to the Flutter app

```bash
cd /home/spectre/Documents/Works/pulse-edge/app
```

## 2. Build the release APK

For normal day-to-day builds, do **not** run `flutter clean`. Keeping the build
cache makes rebundling much faster.

```bash
/home/spectre/development/flutter/bin/flutter build apk --release
```

If you changed dependencies in `pubspec.yaml`, run this first:

```bash
/home/spectre/development/flutter/bin/flutter pub get
```

The APK will be created here:

```bash
/home/spectre/Documents/Works/pulse-edge/app/build/app/outputs/flutter-apk/app-release.apk
```

## 3. Connect your phone

On your phone:

- Enable Developer options.
- Enable USB debugging.
- Plug the phone into your PC.
- Accept the USB debugging prompt on the phone.

Check that the phone is visible:

```bash
adb devices
```

If `adb` is missing:

```bash
sudo apt install android-tools-adb
```

## 4. Install the APK on your phone

```bash
adb install -r /home/spectre/Documents/Works/pulse-edge/app/build/app/outputs/flutter-apk/app-release.apk
```

The `-r` flag updates the app if it is already installed.

## Quick One-Shot Command

```bash
cd /home/spectre/Documents/Works/pulse-edge/app && \
/home/spectre/development/flutter/bin/flutter build apk --release && \
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

## Useful Checks

Check connected devices:

```bash
adb devices
```

Uninstall the app first, if Android refuses to update it:

```bash
adb uninstall com.spectre.pulseedge
```

Then install again:

```bash
adb install -r /home/spectre/Documents/Works/pulse-edge/app/build/app/outputs/flutter-apk/app-release.apk
```

## Troubleshooting Build Problems

Only use `flutter clean` as a reset button when the build cache seems broken,
Gradle is behaving strangely, or native Android files/dependencies changed.
It deletes cached build output, so the next build will take longer.

```bash
cd /home/spectre/Documents/Works/pulse-edge/app
/home/spectre/development/flutter/bin/flutter clean
/home/spectre/development/flutter/bin/flutter pub get
/home/spectre/development/flutter/bin/flutter build apk --release
```

## Notes

- The `flutter_blue_plus_winrt` message is a warning from the Windows plugin metadata. It does not stop the Android APK build.
- The Built-in Kotlin messages are warnings for future Flutter versions. They do not stop the current APK build.
- If the build fails with a Java/Kotlin JVM target mismatch again, keep the JVM 17 override in `app/android/build.gradle.kts`.
