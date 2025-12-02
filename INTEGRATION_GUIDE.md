# MuseLog - Muse SDK Integration Guide

This guide explains how to integrate the official Interaxon Muse SDK (LibMuse) into the MuseLog Flutter application.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Android Integration](#android-integration)
3. [iOS Integration](#ios-integration)
4. [Testing Integration](#testing-integration)
5. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Materials

1. **Muse SDK / LibMuse**
   - Android: `libmuse-android.aar` or `.jar` file
   - iOS: `LibMuse.framework` or `LibMuse.xcframework`
   - Obtain from: [Interaxon Developer Portal](https://choosemuse.com/development/)

2. **Muse Developer Account**
   - Sign up at Interaxon's developer portal
   - Review SDK documentation and license terms

3. **Physical Muse Device**
   - Muse S or Muse S Athena headband
   - Fully charged and in pairing mode

4. **Development Environment**
   - Flutter 3.0.0+
   - Android Studio (for Android)
   - Xcode 14+ (for iOS, macOS required)
   - Physical mobile device (BLE doesn't work well on emulators)

---

## Android Integration

### Step 1: Add LibMuse to Project

1. Locate your LibMuse Android SDK file (e.g., `libmuse-android.aar`)

2. Copy it to the Android libs directory:
   ```
   muselog/android/app/libs/libmuse-android.aar
   ```

3. Update `android/app/build.gradle`:
   ```gradle
   android {
       ...
   }

   dependencies {
       implementation fileTree(dir: 'libs', include: ['*.jar', '*.aar'])
       implementation files('libs/libmuse-android.aar')
       
       // If LibMuse has dependencies, add them here
       // Example:
       // implementation 'androidx.appcompat:appcompat:1.6.0'
   }
   ```

### Step 2: Implement Platform Channel

Open `android/app/src/main/kotlin/com/example/muselog/MusePlatformChannel.kt` and:

1. **Import LibMuse classes** at the top:
   ```kotlin
   import com.choosemuse.libmuse.*
   ```

2. **Add class variables** (uncomment the TODOs):
   ```kotlin
   private var museManager: MuseManagerAndroid? = null
   private val connectedMuses = mutableMapOf<String, Muse>()
   private val dataListeners = mutableMapOf<String, MuseDataListener>()
   ```

3. **Implement `startDeviceScan()`**:
   ```kotlin
   private fun startDeviceScan(result: MethodChannel.Result) {
       try {
           if (museManager == null) {
               museManager = MuseManagerAndroid.getInstance()
               museManager?.setContext(activity)
           }
           
           museManager?.setMuseListener(object : MuseListener {
               override fun museListChanged() {
                   val muses = museManager?.getMuses() ?: emptyList()
                   val deviceList = muses.map { muse ->
                       mapOf(
                           "id" to muse.macAddress,
                           "name" to muse.name,
                           "isConnected" to (muse.connectionState == ConnectionState.CONNECTED),
                           "batteryPercent" to 0
                       )
                   }
                   activity.runOnUiThread {
                       deviceScanSink?.success(deviceList)
                   }
               }
           })
           
           museManager?.startListening()
           result.success(null)
       } catch (e: Exception) {
           result.error("SCAN_ERROR", e.message, null)
       }
   }
   ```

4. **Implement `connectToDevice()`**:
   ```kotlin
   private fun connectToDevice(deviceId: String, result: MethodChannel.Result) {
       try {
           val muse = museManager?.getMuses()?.find { it.macAddress == deviceId }
           if (muse != null) {
               val connectionListener = object : MuseConnectionListener {
                   override fun receiveMuseConnectionPacket(p: MuseConnectionPacket, muse: Muse?) {
                       val state = p.currentConnectionState
                       val isConnected = state == ConnectionState.CONNECTED
                       
                       activity.runOnUiThread {
                           connectionStatusSink?.success(mapOf(
                               "deviceId" to deviceId,
                               "isConnected" to isConnected,
                               "batteryPercent" to 0
                           ))
                       }
                   }
               }
               muse.registerConnectionListener(connectionListener)
               
               // Register data listeners
               registerDataListeners(muse, deviceId)
               
               // Start connection
               muse.runAsynchronously()
               connectedMuses[deviceId] = muse
               result.success(true)
           } else {
               result.success(false)
           }
       } catch (e: Exception) {
           result.error("CONNECTION_ERROR", e.message, null)
       }
   }
   ```

5. **Implement `registerDataListeners()`**:
   ```kotlin
   private fun registerDataListeners(muse: Muse, deviceId: String) {
       val sessionStartTime = System.currentTimeMillis()
       
       // EEG listener
       val eegListener = object : MuseDataListener {
           override fun receiveMuseDataPacket(p: MuseDataPacket, muse: Muse?) {
               if (p.packetType() == MuseDataPacketType.EEG) {
                   val eegData = mapOf(
                       "deviceId" to deviceId,
                       "timestamp" to p.timestamp().toLong(),
                       "msElapsed" to (System.currentTimeMillis() - sessionStartTime).toInt(),
                       "tp9Raw" to p.getEegChannelValue(Eeg.TP9),
                       "af7Raw" to p.getEegChannelValue(Eeg.AF7),
                       "af8Raw" to p.getEegChannelValue(Eeg.AF8),
                       "tp10Raw" to p.getEegChannelValue(Eeg.TP10),
                       "drl" to p.getEegChannelValue(Eeg.DRL),
                       "ref" to p.getEegChannelValue(Eeg.REF),
                       "tp9Hsi" to 1, // Get from HSI packet
                       "af7Hsi" to 1,
                       "af8Hsi" to 1,
                       "tp10Hsi" to 1,
                       "tp9ArtifactFree" to true, // Get from artifact packet
                       "af7ArtifactFree" to true,
                       "af8ArtifactFree" to true,
                       "tp10ArtifactFree" to true
                   )
                   activity.runOnUiThread {
                       eegDataSink?.success(eegData)
                   }
               }
           }
           override fun receiveMuseArtifactPacket(p: MuseArtifactPacket, muse: Muse?) {
               // Handle artifact data
           }
       }
       
       muse.registerDataListener(eegListener, MuseDataPacketType.EEG)
       
       // Band power listener
       val bandPowerListener = object : MuseDataListener {
           override fun receiveMuseDataPacket(p: MuseDataPacket, muse: Muse?) {
               if (p.packetType() == MuseDataPacketType.BAND_POWER) {
                   // Extract and send band power data
                   // Similar structure to EEG
               }
           }
           override fun receiveMuseArtifactPacket(p: MuseArtifactPacket, muse: Muse?) {}
       }
       
       muse.registerDataListener(bandPowerListener, MuseDataPacketType.BAND_POWER)
       
       // Add fNIRS, IMU, battery listeners similarly
   }
   ```

### Step 3: Test on Android Device

1. Connect Android device via USB
2. Enable USB debugging in device settings
3. Run:
   ```bash
   flutter run -d <android-device-id>
   ```

---

## iOS Integration

### Step 1: Add LibMuse to Xcode Project

1. Open `ios/Runner.xcworkspace` in Xcode

2. Drag `LibMuse.framework` or `LibMuse.xcframework` into the project:
   - Right-click on `Runner` in project navigator
   - Select "Add Files to Runner"
   - Choose your LibMuse framework
   - Ensure "Copy items if needed" is checked
   - Select "Create groups"

3. Configure embedding:
   - Select `Runner` project in navigator
   - Go to "Runner" target → "General" tab
   - Scroll to "Frameworks, Libraries, and Embedded Content"
   - Find LibMuse and set to **"Embed & Sign"**

### Step 2: Implement Platform Channel

Open `ios/Runner/MusePlatformChannel.swift` and:

1. **Import LibMuse** at the top:
   ```swift
   import LibMuse
   ```

2. **Add class variables** (uncomment the TODOs):
   ```swift
   private var museManager: IXNMuseManager?
   private var connectedMuses: [String: IXNMuse] = [:]
   private var dataListeners: [String: IXNMuseDataListener] = [:]
   ```

3. **Implement `startDeviceScan()`**:
   ```swift
   private func startDeviceScan(result: @escaping FlutterResult) {
       if museManager == nil {
           museManager = IXNMuseManager.shared()
       }
       
       NotificationCenter.default.addObserver(
           self,
           selector: #selector(museListChanged),
           name: NSNotification.Name.IXNMuseListChanged,
           object: nil
       )
       
       museManager?.startListening()
       result(nil)
   }
   
   @objc private func museListChanged() {
       guard let muses = museManager?.getMuses() as? [IXNMuse] else { return }
       
       let deviceList = muses.map { muse in
           return [
               "id": muse.macAddress ?? "",
               "name": muse.name ?? "Unknown",
               "isConnected": muse.connectionState == .connected,
               "batteryPercent": 0
           ] as [String : Any]
       }
       
       DispatchQueue.main.async {
           self.deviceScanSink?(deviceList)
       }
   }
   ```

4. **Implement `connectToDevice()`**:
   ```swift
   private func connectToDevice(deviceId: String, result: @escaping FlutterResult) {
       guard let muses = museManager?.getMuses() as? [IXNMuse],
             let muse = muses.first(where: { $0.macAddress == deviceId }) else {
           result(false)
           return
       }
       
       // Register connection listener
       // Note: Implement IXNMuseConnectionListener protocol
       
       // Register data listeners
       registerDataListeners(muse: muse, deviceId: deviceId)
       
       // Connect
       muse.runAsynchronously()
       connectedMuses[deviceId] = muse
       result(true)
   }
   ```

5. **Implement `registerDataListeners()`**:
   ```swift
   private func registerDataListeners(muse: IXNMuse, deviceId: String) {
       let sessionStartTime = Date().timeIntervalSince1970 * 1000
       
       let dataListener = IXNMuseDataListener()
       
       // EEG data handler
       dataListener.receiveMuseDataPacket = { [weak self] packet, _ in
           guard let self = self, packet.packetType() == .eeg else { return }
           
           let eegData: [String: Any] = [
               "deviceId": deviceId,
               "timestamp": Int(packet.timestamp() * 1000),
               "msElapsed": Int(Date().timeIntervalSince1970 * 1000 - sessionStartTime),
               "tp9Raw": packet.eegChannelValue(.tp9),
               "af7Raw": packet.eegChannelValue(.af7),
               "af8Raw": packet.eegChannelValue(.af8),
               "tp10Raw": packet.eegChannelValue(.tp10),
               "drl": packet.eegChannelValue(.drl),
               "ref": packet.eegChannelValue(.ref)
           ]
           
           DispatchQueue.main.async {
               self.eegDataSink?(eegData)
           }
       }
       
       muse.register(dataListener, type: .eeg)
       
       // Add band power, fNIRS, IMU listeners similarly
       
       dataListeners[deviceId] = dataListener
   }
   ```

### Step 3: Test on iOS Device

1. Connect iPhone/iPad via USB
2. In Xcode, select your device
3. Configure signing (Xcode → Runner → Signing & Capabilities)
4. Run:
   ```bash
   flutter run -d <ios-device-id>
   ```

---

## Testing Integration

### 1. Basic Connection Test

```dart
// In Flutter, test the integration:
final repository = ref.read(museRepositoryProvider);

// Request permissions
final granted = await repository.requestPermissions();
print('Permissions granted: $granted');

// Start scanning
await repository.startScanning();

// Listen for devices
repository.watchDevices().listen((devices) {
  print('Found ${devices.length} devices');
  for (var device in devices) {
    print('  - ${device.name} (${device.id})');
  }
});
```

### 2. Data Stream Test

```dart
// Connect to device
final device = devices.first;
final connected = await repository.connectDevice(device);

if (connected) {
  // Listen to EEG stream
  repository.watchEEGData().listen((sample) {
    print('EEG: TP9=${sample.tp9Raw}, AF7=${sample.af7Raw}');
  });
}
```

### 3. Verify CSV Writing

After recording a session:
1. Navigate to post-session screen
2. Check "View Location" for CSV file path
3. Verify file contains data with correct columns
4. Test "Share" functionality

---

## Troubleshooting

### Common Issues

#### Android: "Class not found" errors
- **Cause**: LibMuse AAR not properly added
- **Fix**: Verify `build.gradle` has correct `implementation files('libs/libmuse-android.aar')`
- **Fix**: Check AAR file is in `android/app/libs/`
- **Fix**: Run `flutter clean` and rebuild

#### Android: Permission denied
- **Cause**: Missing runtime permissions
- **Fix**: Go to device Settings → Apps → MuseLog → Permissions
- **Fix**: Grant Bluetooth and Location permissions
- **Fix**: On Android 12+, ensure BLUETOOTH_SCAN and BLUETOOTH_CONNECT are granted

#### iOS: Framework not found
- **Cause**: LibMuse not embedded correctly
- **Fix**: In Xcode, verify framework is in "Frameworks, Libraries, and Embedded Content"
- **Fix**: Ensure it's set to "Embed & Sign"
- **Fix**: Clean build folder (Xcode → Product → Clean Build Folder)

#### iOS: Crash on launch
- **Cause**: Framework architecture mismatch
- **Fix**: Ensure LibMuse.xcframework supports both simulator and device
- **Fix**: Use `lipo -info LibMuse.framework/LibMuse` to check architectures

#### No devices found
- **Cause**: Muse headband not in pairing mode
- **Fix**: Hold power button on Muse until LED blinks rapidly
- **Cause**: Bluetooth disabled
- **Fix**: Enable Bluetooth in device settings
- **Cause**: App doesn't have BLE permissions
- **Fix**: Check app permissions in device settings

#### Data streams not working
- **Cause**: Data listeners not registered
- **Fix**: Verify `registerDataListeners()` is called after connection
- **Cause**: EventSinks not set up
- **Fix**: Check Flutter side is listening to streams before native sends data

### Debugging Tips

1. **Enable verbose logging**:
   ```kotlin
   // Android
   Log.d("MuseLog", "Message here")
   ```
   ```swift
   // iOS
   print("MuseLog: Message here")
   ```

2. **Check Flutter logs**:
   ```bash
   flutter logs
   ```

3. **Test native code separately**:
   - Create a simple native Android/iOS app
   - Verify LibMuse works before integrating with Flutter

4. **Use Android Studio / Xcode debuggers**:
   - Set breakpoints in platform channel code
   - Step through LibMuse API calls

---

## Additional Resources

- **Muse Developer Portal**: https://choosemuse.com/development/
- **LibMuse Documentation**: Check SDK documentation included with download
- **Flutter Platform Channels**: https://docs.flutter.dev/platform-integration/platform-channels
- **Bluetooth Permissions**: 
  - Android: https://developer.android.com/guide/topics/connectivity/bluetooth/permissions
  - iOS: https://developer.apple.com/documentation/corebluetooth

---

## Support

For issues specific to:
- **MuseLog Flutter app**: Check inline code comments and TODOs
- **LibMuse SDK**: Contact Interaxon support or check SDK documentation
- **Flutter**: https://docs.flutter.dev/

---

**You're ready to integrate!** Follow the steps above, wire in your LibMuse SDK, and you'll have a fully functional Muse brain-sensing data logger.
