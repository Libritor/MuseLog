import Flutter
import UIKit

/**
 * Platform channel for integrating Muse SDK (LibMuse) with Flutter on iOS.
 *
 * This class handles:
 * - Bluetooth permissions
 * - Device scanning and discovery
 * - Connection management
 * - Data streaming from Muse devices
 *
 * TODO: Add LibMuse SDK integration
 * 1. Add LibMuse.framework or LibMuse.xcframework to Xcode project
 * 2. Drag into ios/Runner/Frameworks/ and select "Embed & Sign"
 * 3. Import LibMuse:
 *    import LibMuse
 * 4. Implement the TODOs below
 */
class MusePlatformChannel: NSObject {
    
    private static let methodChannelName = "com.muselog.muse/methods"
    private static let deviceScanChannelName = "com.muselog.muse/device_scan"
    private static let eegDataChannelName = "com.muselog.muse/eeg_data"
    private static let bandPowerChannelName = "com.muselog.muse/band_power"
    private static let fnirsChannelName = "com.muselog.muse/fnirs"
    private static let imuChannelName = "com.muselog.muse/imu"
    private static let connectionStatusChannelName = "com.muselog.muse/connection_status"
    
    private var methodChannel: FlutterMethodChannel?
    private var deviceScanEventChannel: FlutterEventChannel?
    private var eegDataEventChannel: FlutterEventChannel?
    private var bandPowerEventChannel: FlutterEventChannel?
    private var fnirsEventChannel: FlutterEventChannel?
    private var imuEventChannel: FlutterEventChannel?
    private var connectionStatusEventChannel: FlutterEventChannel?
    
    private var deviceScanSink: FlutterEventSink?
    private var eegDataSink: FlutterEventSink?
    private var bandPowerSink: FlutterEventSink?
    private var fnirsSink: FlutterEventSink?
    private var imuSink: FlutterEventSink?
    private var connectionStatusSink: FlutterEventSink?
    
    // TODO: Add LibMuse variables
    // private var museManager: IXNMuseManager?
    // private var connectedMuses: [String: IXNMuse] = [:]
    // private var dataListeners: [String: IXNMuseDataListener] = [:]
    
    func setupChannels(binaryMessenger: FlutterBinaryMessenger) {
        // Method channel for commands
        methodChannel = FlutterMethodChannel(name: MusePlatformChannel.methodChannelName,
                                             binaryMessenger: binaryMessenger)
        methodChannel?.setMethodCallHandler(handleMethodCall)
        
        // Event channels for streaming data
        deviceScanEventChannel = FlutterEventChannel(name: MusePlatformChannel.deviceScanChannelName,
                                                     binaryMessenger: binaryMessenger)
        deviceScanEventChannel?.setStreamHandler(DeviceScanStreamHandler(channel: self))
        
        eegDataEventChannel = FlutterEventChannel(name: MusePlatformChannel.eegDataChannelName,
                                                  binaryMessenger: binaryMessenger)
        eegDataEventChannel?.setStreamHandler(EEGDataStreamHandler(channel: self))
        
        bandPowerEventChannel = FlutterEventChannel(name: MusePlatformChannel.bandPowerChannelName,
                                                    binaryMessenger: binaryMessenger)
        bandPowerEventChannel?.setStreamHandler(BandPowerStreamHandler(channel: self))
        
        fnirsEventChannel = FlutterEventChannel(name: MusePlatformChannel.fnirsChannelName,
                                               binaryMessenger: binaryMessenger)
        fnirsEventChannel?.setStreamHandler(FNIRSStreamHandler(channel: self))
        
        imuEventChannel = FlutterEventChannel(name: MusePlatformChannel.imuChannelName,
                                             binaryMessenger: binaryMessenger)
        imuEventChannel?.setStreamHandler(IMUStreamHandler(channel: self))
        
        connectionStatusEventChannel = FlutterEventChannel(name: MusePlatformChannel.connectionStatusChannelName,
                                                          binaryMessenger: binaryMessenger)
        connectionStatusEventChannel?.setStreamHandler(ConnectionStatusStreamHandler(channel: self))
    }
    
    private func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "requestBluetoothPermissions":
            requestBluetoothPermissions(result: result)
        case "startDeviceScan":
            startDeviceScan(result: result)
        case "stopDeviceScan":
            stopDeviceScan(result: result)
        case "connectToDevice":
            if let args = call.arguments as? [String: Any],
               let deviceId = args["deviceId"] as? String {
                connectToDevice(deviceId: deviceId, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Device ID is required", details: nil))
            }
        case "disconnectFromDevice":
            if let args = call.arguments as? [String: Any],
               let deviceId = args["deviceId"] as? String {
                disconnectFromDevice(deviceId: deviceId, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Device ID is required", details: nil))
            }
        case "startDataStream":
            if let args = call.arguments as? [String: Any],
               let deviceId = args["deviceId"] as? String {
                startDataStream(deviceId: deviceId, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Device ID is required", details: nil))
            }
        case "stopDataStream":
            if let args = call.arguments as? [String: Any],
               let deviceId = args["deviceId"] as? String {
                stopDataStream(deviceId: deviceId, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Device ID is required", details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func requestBluetoothPermissions(result: @escaping FlutterResult) {
        // iOS handles Bluetooth permissions automatically via Info.plist
        // No explicit permission request needed
        result(true)
    }
    
    private func startDeviceScan(result: @escaping FlutterResult) {
        // TODO: Implement LibMuse device scanning
        /*
        if museManager == nil {
            museManager = IXNMuseManager.shared()
        }
        
        // Set up notification observer for Muse list changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(museListChanged),
            name: NSNotification.Name.IXNMuseListChanged,
            object: nil
        )
        
        museManager?.startListening()
        result(nil)
        */
        
        // STUB: Send dummy device for testing without SDK
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.deviceScanSink?([
                [
                    "id": "00:55:DA:B0:XX:XX",
                    "name": "Muse-TEST",
                    "isConnected": false,
                    "batteryPercent": 75
                ]
            ])
        }
        result(nil)
    }
    
    // TODO: Implement Muse list change handler
    /*
    @objc private func museListChanged() {
        guard let muses = museManager?.getMuses() as? [IXNMuse] else { return }
        
        let deviceList = muses.map { muse in
            return [
                "id": muse.macAddress ?? "",
                "name": muse.name ?? "Unknown",
                "isConnected": muse.connectionState == .connected,
                "batteryPercent": 0 // Update when available
            ] as [String : Any]
        }
        
        DispatchQueue.main.async {
            self.deviceScanSink?(deviceList)
        }
    }
    */
    
    private func stopDeviceScan(result: @escaping FlutterResult) {
        // TODO: Implement stopping scan
        /*
        museManager?.stopListening()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IXNMuseListChanged, object: nil)
        */
        result(nil)
    }
    
    private func connectToDevice(deviceId: String, result: @escaping FlutterResult) {
        // TODO: Implement device connection
        /*
        guard let muses = museManager?.getMuses() as? [IXNMuse] else {
            result(false)
            return
        }
        
        guard let muse = muses.first(where: { $0.macAddress == deviceId }) else {
            result(false)
            return
        }
        
        // Set up connection listener
        muse.register(self as! IXNMuseConnectionListener)
        
        // Register data listeners
        registerDataListeners(muse: muse, deviceId: deviceId)
        
        // Connect
        muse.runAsynchronously()
        connectedMuses[deviceId] = muse
        result(true)
        */
        result(true) // STUB
    }
    
    private func disconnectFromDevice(deviceId: String, result: @escaping FlutterResult) {
        // TODO: Implement disconnection
        /*
        connectedMuses[deviceId]?.disconnect()
        connectedMuses.removeValue(forKey: deviceId)
        dataListeners.removeValue(forKey: deviceId)
        */
        result(nil)
    }
    
    private func startDataStream(deviceId: String, result: @escaping FlutterResult) {
        // Data streaming is automatically started when listeners are registered
        result(nil)
    }
    
    private func stopDataStream(deviceId: String, result: @escaping FlutterResult) {
        // Data streaming will stop when device is disconnected
        result(nil)
    }
    
    // TODO: Implement data listener registration
    /*
    private func registerDataListeners(muse: IXNMuse, deviceId: String) {
        let sessionStartTime = Date().timeIntervalSince1970 * 1000
        
        // Create data listener
        let dataListener = IXNMuseDataListener()
        dataListener.receiveMuseDataPacket = { [weak self] packet, _ in
            guard let self = self else { return }
            
            if packet.packetType() == .eeg {
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
            
            // Add similar handling for band powers, fNIRS, IMU, etc.
        }
        
        muse.register(dataListener, type: .eeg)
        dataListeners[deviceId] = dataListener
    }
    */
    
    func dispose() {
        // TODO: Clean up LibMuse resources
        /*
        connectedMuses.values.forEach { $0.disconnect() }
        connectedMuses.removeAll()
        museManager?.stopListening()
        */
    }
}

// MARK: - Stream Handlers

class DeviceScanStreamHandler: NSObject, FlutterStreamHandler {
    weak var channel: MusePlatformChannel?
    
    init(channel: MusePlatformChannel) {
        self.channel = channel
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        channel?.deviceScanSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        channel?.deviceScanSink = nil
        return nil
    }
}

class EEGDataStreamHandler: NSObject, FlutterStreamHandler {
    weak var channel: MusePlatformChannel?
    
    init(channel: MusePlatformChannel) {
        self.channel = channel
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        channel?.eegDataSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        channel?.eegDataSink = nil
        return nil
    }
}

class BandPowerStreamHandler: NSObject, FlutterStreamHandler {
    weak var channel: MusePlatformChannel?
    
    init(channel: MusePlatformChannel) {
        self.channel = channel
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        channel?.bandPowerSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        channel?.bandPowerSink = nil
        return nil
    }
}

class FNIRSStreamHandler: NSObject, FlutterStreamHandler {
    weak var channel: MusePlatformChannel?
    
    init(channel: MusePlatformChannel) {
        self.channel = channel
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        channel?.fnirsSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        channel?.fnirsSink = nil
        return nil
    }
}

class IMUStreamHandler: NSObject, FlutterStreamHandler {
    weak var channel: MusePlatformChannel?
    
    init(channel: MusePlatformChannel) {
        self.channel = channel
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        channel?.imuSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        channel?.imuSink = nil
        return nil
    }
}

class ConnectionStatusStreamHandler: NSObject, FlutterStreamHandler {
    weak var channel: MusePlatformChannel?
    
    init(channel: MusePlatformChannel) {
        self.channel = channel
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        channel?.connectionStatusSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        channel?.connectionStatusSink = nil
        return nil
    }
}
