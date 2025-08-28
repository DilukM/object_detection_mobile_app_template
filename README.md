# object_detection

# Object Detection — Flutter sample

A small, starter Flutter app that demonstrates real-time object detection using the device camera and a TensorFlow Lite model (SSD MobileNet). This repository is intended to be a concise starting point for developers who want to build mobile object detection apps.

## What this repo contains

- A Flutter app that opens the camera and runs object detection using a bundled TFLite model.
- Model and label files: `assets/ssd_mobilenet.tflite`, `assets/ssd_mobilenet.txt`.
- Main code: `lib/main.dart`, `lib/ObjectDetection.dart`, `lib/BoundingBox.dart`.

## Checklist (what this README provides)

- [x] Repo overview and file map
- [x] Prerequisites and environment notes
- [x] Setup and run steps for Android and iOS
- [x] How to replace or change the model
- [x] Troubleshooting (including the tflite_v2 namespace fix)
- [x] How to publish the sample to GitHub

## Prerequisites

- Flutter SDK (recommended: Flutter 3.0 or later). Verify with:

```bash
flutter --version
```

- Android SDK and platform tools for Android builds.
- (Optional) Xcode for iOS builds.
- A connected device or emulator.

## Quick setup

1. Clone the repo (or copy files into a new Flutter project):

```bash
git clone <your-repo-url>
cd object_detection
```

2. Install dependencies:

```bash
flutter pub get
```

3. (Optional) If you modified pubspec or assets, run:

```bash
flutter pub get
flutter clean
```

## Run on Android

1. Start an Android emulator or connect a device.
2. Run the app:

```bash
flutter run -d <device-id>
```

Replace `<device-id>` with the output of `flutter devices` or omit to run on the default device.

### Android permissions

Ensure camera permission is present in `android/app/src/main/AndroidManifest.xml`. Example entries to check:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera.any" android:required="false" />
```

## Run on iOS

1. Open the iOS project in Xcode (if you need to edit capabilities) or run directly from the terminal on a connected device:

```bash
flutter run -d ios
```

2. Make sure `NSCameraUsageDescription` is set in `ios/Runner/Info.plist`.

## Model and assets

- The repo includes a sample TFLite model and label file in the `assets/` folder:

  - `assets/ssd_mobilenet.tflite`
  - `assets/ssd_mobilenet.txt`

- If you replace the model, keep the filename or update the model path in the app code (`ObjectDetection.dart`) and ensure `pubspec.yaml` lists the assets:

```yaml
flutter:
	assets:
		- assets/ssd_mobilenet.tflite
		- assets/ssd_mobilenet.txt
```

## Notes on the `tflite_v2` plugin namespace error

If you encounter an error during Android configuration like:

"Namespace not specified. Specify a namespace in the module's build file... tflite_v2-1.0.0/android/build.gradle"

This is a known issue with older plugins that predate Android Gradle Plugin's `namespace` requirement. You have two safe options:

1. Quick local fix (temporary): edit the plugin in the local pub cache.

Open the plugin build file (example path on Windows):

```
C:\Users\<your-user>\AppData\Local\Pub\Cache\hosted\pub.dev\tflite_v2-1.0.0\android\build.gradle
```

Add a `namespace` line inside the `android {}` block. For the version used by this sample the correct namespace is likely the plugin package, e.g.:

```groovy
android {
		namespace "sq.flutter.tflite"
		// ...existing config...
}
```

After editing the pub cache file, run:

```bash
flutter clean
flutter pub get
flutter run
```

Warning: editing files in the pub cache is a local, temporary workaround. Package upgrades will overwrite these changes.

2. Permanent fix (recommended): vendor the plugin into your repo and edit it there, or update the dependency to a plugin version that declares `namespace`.

- To vendor: copy the plugin source into a `packages/tflite_v2` folder and point `pubspec.yaml` to that path. Then edit `packages/tflite_v2/android/build.gradle` and add the `namespace` the same way. This keeps your fix source-controlled and shareable.

## Troubleshooting

- If the camera is blank or the app crashes, check device logs with `flutter run` or `adb logcat`.
- If model inference is slow, try a smaller model or enable NNAPI / GPU delegates where supported.
- If you see Gradle/AGP errors about `compileSdkVersion` or dependencies, ensure your Android SDK and `compileSdkVersion` satisfy plugin requirements (often `compileSdkVersion 31` or above).

## Code pointers (where to look)

- `lib/main.dart` — app entry and camera initialization.
- `lib/ObjectDetection.dart` — camera stream handling + inference and UI glue.
- `lib/BoundingBox.dart` — helper UI code to draw detection boxes.

## Contributing

Contributions are welcome. A recommended workflow:

1. Fork the repo.
2. Make a branch for your feature/fix.
3. Submit a pull request with a short description and test steps.

## License

Include a license file if you want this sample to be publicly re-usable. If you want a permissive default, consider the MIT license.


