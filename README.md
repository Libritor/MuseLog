# MuseLog - Muse Brain-Sensing Headband Data Logger

A production-grade Flutter application for connecting to **Interaxon Muse S / Muse S Athena** brain-sensing headbands, streaming EEG, fNIRS, IMU, and battery data, visualizing it live, and recording to CSV.

## Features

- ✅ **Multi-device support** - Connect to multiple Muse headbands simultaneously
- ✅ **Live data visualization** - Real-time charts for EEG, band powers, fNIRS, and IMU
- ✅ **Contact quality indicators** - Horseshoe-style HSI display for TP9/AF7/AF8/TP10
- ✅ **CSV recording** - Export data with 60+ selectable columns
- ✅ **Cross-platform** - Single codebase for Android and iOS
- ✅ **Research-grade** - Precise timestamping and trigger markers

## Project Structure

```
muselog/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── data/
│   │   ├── models/                        # Domain models
│   │   │   ├── muse_device.dart
│   │   │   ├── eeg_sample.dart
│   │   │   ├── band_power_sample.dart
│   │   │   ├── fnirs_sample.dart
│   │   │   ├── imu_sample.dart
│   │   │   └── recording_session.dart
│   │   ├── services/
│   │   │   ├── muse_service.dart          # Muse SDK abstraction
│   │   │   ├── csv_writer_service.dart    # CSV recording
│   │   │   └── platform_channel.dart      # Native bridge
│   │   └── repositories/
│   │       └── muse_repository.dart       # Data repository
│   ├── presentation/
│   │   ├── providers/                     # Riverpod providers
│   │   ├── screens/
│   │   │   ├── device_list_screen.dart
│   │   │   ├── recording_config_screen.dart
│   │   │   ├── live_session_screen.dart
│   │   │   └── post_session_screen.dart
│   │   └── widgets/
│   │       ├── hsi_indicator.dart         # Contact quality display
│   │       ├── eeg_chart.dart
│   │       ├── band_power_chart.dart
│   │       ├── fnirs_chart.dart
│   │       └── imu_chart.dart
│   └── utils/
│       └── constants.dart
├── android/
│   └── app/src/main/
│       ├── kotlin/                        # Platform channel (Kotlin)
│       └── AndroidManifest.xml            # BLE permissions
├── ios/
│   └── Runner/
│       ├── AppDelegate.swift              # Platform channel (Swift)
│       └── Info.plist                     # Bluetooth permissions
└── test/
```

## Prerequisites

1. **Flutter SDK**: Version 3.0.0 or higher
   ```bash
   flutter --version
   ```

2. **Muse SDK / LibMuse**: You must have access to the official Interaxon Muse SDK for:
   - **Android**: LibMuse JAR/AAR files
   - **iOS**: LibMuse framework/xcframework

3. **Development Tools**:
   - **Android**: Android Studio with Android SDK
   - **iOS**: Xcode (macOS only) with iOS SDK

## Getting Started

### 1. Install Dependencies

```bash
cd muselog
flutter pub get
```

### 2. Integrate Muse SDK

#### Android (Kotlin)

1. Place your **LibMuse AAR/JAR** files in:
   ```
   android/app/libs/libmuse-android.aar
   ```

2. Update `android/app/build.gradle`:
   ```gradle
   dependencies {
       implementation files('libs/libmuse-android.aar')
       // Add any other Muse SDK dependencies
   }
   ```

3. Wire up LibMuse in `android/app/src/main/kotlin/.../MusePlatformChannel.kt`:
   - See inline TODOs in the file for exact integration points
   - Implement device discovery using LibMuse's `MuseManager`
   - Subscribe to EEG, band powers, fNIRS, IMU streams
   - Send data to Flutter via MethodChannel

#### iOS (Swift)

1. Add **LibMuse.framework** or **LibMuse.xcframework** to your Xcode project:
   - Drag into `ios/Runner/Frameworks/` in Xcode
   - Ensure "Embed & Sign" is selected

2. Wire up LibMuse in `ios/Runner/MusePlatformChannel.swift`:
   - See inline TODOs for integration points
   - Implement discovery using LibMuse's `IXNMuseManager`
   - Subscribe to data packets and stream to Flutter

### 3. Configure Permissions

#### Android

Already configured in `android/app/src/main/AndroidManifest.xml`:
- `BLUETOOTH`
- `BLUETOOTH_ADMIN`
- `BLUETOOTH_SCAN`
- `BLUETOOTH_CONNECT`
- `ACCESS_FINE_LOCATION`

#### iOS

Already configured in `ios/Runner/Info.plist`:
- `NSBluetoothAlwaysUsageDescription`
- `NSBluetoothPeripheralUsageDescription`

### 4. Run the App

#### On Android:
```bash
flutter run -d <android-device-id>
```

#### On iOS:
```bash
flutter run -d <ios-device-id>
```

**Note**: You must run on **physical devices** for Bluetooth functionality. Emulators/simulators do not support BLE.

## Building for Production

### Android (APK/AAB)

1. Configure signing in `android/app/build.gradle`
2. Build:
   ```bash
   flutter build apk --release
   flutter build appbundle --release
   ```

### iOS (IPA)

1. Open `ios/Runner.xcworkspace` in Xcode
2. Configure signing & capabilities
3. Archive and upload to App Store Connect

Or via command line:
```bash
flutter build ipa --release
```

## Architecture

### Data Flow

```
Muse Headband (BLE)
       ↓
Native SDK (LibMuse)
       ↓
Platform Channel (Kotlin/Swift)
       ↓
MuseService (Dart)
       ↓
MuseRepository (Dart)
       ↓
Riverpod Providers
       ↓
UI Screens & Widgets
```

### Key Components

1. **MuseService**: Abstraction over platform channels, exposes Dart streams
2. **CSV Writer**: Efficient streaming writer for large recording sessions
3. **State Management**: Riverpod for reactive, testable state
4. **Charts**: fl_chart for high-performance real-time visualization

## CSV Output Format

Recorded data includes these columns (user-selectable):

- **Metadata**: PACKET_TYPE, CLOCK_TIME, ms_ELAPSED, TRIGGER_COUNT
- **Contact Quality**: TP9/AF7/AF8/TP10 HSI and artifact flags
- **Raw EEG**: TP9_RAW, AF7_RAW, AF8_RAW, TP10_RAW, DRL, REF
- **Band Powers (Absolute)**: Delta, Theta, Alpha, Beta, Gamma per channel
- **Band Powers (Relative)**: Delta, Theta, Alpha, Beta, Gamma per channel
- **IMU**: GYRO_X/Y/Z, ACCEL_X/Y/Z
- **fNIRS**: 730nm, 850nm, RED, AMBIENT for LEFT/RIGHT, OUTER/INNER
- **Battery**: BATTERY_PERCENT

Files are saved to:
- **Android**: `/Android/data/com.example.muselog/files/`
- **iOS**: App Documents directory

## Testing

Run unit tests:
```bash
flutter test
```

Key test files:
- `test/models_test.dart` - Domain model tests
- `test/csv_writer_test.dart` - CSV generation tests
- `test/hsi_logic_test.dart` - Contact quality color mapping

## Troubleshooting

### BLE Not Working
- Ensure physical device (not emulator)
- Check permissions are granted in device settings
- Verify Bluetooth is enabled
- Check Muse headband is charged and in pairing mode

### LibMuse Integration Issues
- Verify SDK files are correctly placed and linked
- Check that native code compiles without errors
- Review platform channel method names match on both sides
- Enable verbose logging in native code to debug

### Performance Issues
- Reduce chart refresh rate (see `Constants.chartRefreshInterval`)
- Limit visible time window for live charts
- Disable unused visualizations during recording

## License

This project is for research and personal use. Ensure compliance with Muse SDK license terms.

## Support

For issues with:
- **Flutter code**: Check inline documentation and TODOs
- **Muse SDK**: Consult official Interaxon documentation
- **BLE permissions**: Review Android/iOS permission guides

---

**Ready to build!** Follow the integration steps above, wire in your LibMuse SDK, and you'll have a fully functional Muse data logger.
