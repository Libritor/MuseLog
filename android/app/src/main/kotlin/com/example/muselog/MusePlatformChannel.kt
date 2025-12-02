package com.example.muselog

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Platform channel for integrating Muse SDK (LibMuse) with Flutter.
 * 
 * This class handles:
 * - Bluetooth permissions
 * - Device scanning and discovery
 * - Connection management
 * - Data streaming from Muse devices
 * 
 * TODO: Add LibMuse SDK integration
 * 1. Add LibMuse AAR/JAR to android/app/libs/
 * 2. Update build.gradle to include: implementation files('libs/libmuse-android.aar')
 * 3. Import LibMuse classes:
 *    import com.choosemuse.libmuse.*
 * 4. Implement the TODOs below
 */
class MusePlatformChannel(private val activity: Activity) {
    
    companion object {
        private const val METHOD_CHANNEL = "com.muselog.muse/methods"
        private const val DEVICE_SCAN_CHANNEL = "com.muselog.muse/device_scan"
        private const val EEG_DATA_CHANNEL = "com.muselog.muse/eeg_data"
        private const val BAND_POWER_CHANNEL = "com.muselog.muse/band_power"
        private const val FNIRS_CHANNEL = "com.muselog.muse/fnirs"
        private const val IMU_CHANNEL = "com.muselog.muse/imu"
        private const val CONNECTION_STATUS_CHANNEL = "com.muselog.muse/connection_status"
        
        private const val PERMISSION_REQUEST_CODE = 1001
    }
    
    private var methodChannel: MethodChannel? = null
    private var deviceScanEventChannel: EventChannel? = null
    private var eegDataEventChannel: EventChannel? = null
    private var bandPowerEventChannel: EventChannel? = null
    private var fnirsEventChannel: EventChannel? = null
    private var imuEventChannel: EventChannel? = null
    private var connectionStatusEventChannel: EventChannel? = null
    
    // Event sinks for streaming data to Flutter
    private var deviceScanSink: EventChannel.EventSink? = null
    private var eegDataSink: EventChannel.EventSink? = null
    private var bandPowerSink: EventChannel.EventSink? = null
    private var fnirsSink: EventChannel.EventSink? = null
    private var imuSink: EventChannel.EventSink? = null
    private var connectionStatusSink: EventChannel.EventSink? = null
    
    // TODO: Add LibMuse variables
    // private var museManager: MuseManagerAndroid? = null
    // private val connectedMuses = mutableMapOf<String, Muse>()
    // private val dataListeners = mutableMapOf<String, MuseDataListener>()
    
    fun setupChannels(binaryMessenger: io.flutter.plugin.common.BinaryMessenger) {
        // Method channel for commands
        methodChannel = MethodChannel(binaryMessenger, METHOD_CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            handleMethodCall(call, result)
        }
        
        // Event channels for streaming data
        deviceScanEventChannel = EventChannel(binaryMessenger, DEVICE_SCAN_CHANNEL)
        deviceScanEventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                deviceScanSink = events
            }
            override fun onCancel(arguments: Any?) {
                deviceScanSink = null
            }
        })
        
        eegDataEventChannel = EventChannel(binaryMessenger, EEG_DATA_CHANNEL)
        eegDataEventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eegDataSink = events
            }
            override fun onCancel(arguments: Any?) {
                eegDataSink = null
            }
        })
        
        bandPowerEventChannel = EventChannel(binaryMessenger, BAND_POWER_CHANNEL)
        bandPowerEventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                bandPowerSink = events
            }
            override fun onCancel(arguments: Any?) {
                bandPowerSink = null
            }
        })
        
        fnirsEventChannel = EventChannel(binaryMessenger, FNIRS_CHANNEL)
        fnirsEventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                fnirsSink = events
            }
            override fun onCancel(arguments: Any?) {
                fnirsSink = null
            }
        })
        
        imuEventChannel = EventChannel(binaryMessenger, IMU_CHANNEL)
        imuEventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                imuSink = events
            }
            override fun onCancel(arguments: Any?) {
                imuSink = null
            }
        })
        
        connectionStatusEventChannel = EventChannel(binaryMessenger, CONNECTION_STATUS_CHANNEL)
        connectionStatusEventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                connectionStatusSink = events
            }
            override fun onCancel(arguments: Any?) {
                connectionStatusSink = null
            }
        })
    }
    
    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "requestBluetoothPermissions" -> {
                requestBluetoothPermissions(result)
            }
            "startDeviceScan" -> {
                startDeviceScan(result)
            }
            "stopDeviceScan" -> {
                stopDeviceScan(result)
            }
            "connectToDevice" -> {
                val deviceId = call.argument<String>("deviceId")
                if (deviceId != null) {
                    connectToDevice(deviceId, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Device ID is required", null)
                }
            }
            "disconnectFromDevice" -> {
                val deviceId = call.argument<String>("deviceId")
                if (deviceId != null) {
                    disconnectFromDevice(deviceId, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Device ID is required", null)
                }
            }
            "startDataStream" -> {
                val deviceId = call.argument<String>("deviceId")
                if (deviceId != null) {
                    startDataStream(deviceId, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Device ID is required", null)
                }
            }
            "stopDataStream" -> {
                val deviceId = call.argument<String>("deviceId")
                if (deviceId != null) {
                    stopDataStream(deviceId, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Device ID is required", null)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }
    
    private fun requestBluetoothPermissions(result: MethodChannel.Result) {
        val permissions = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            arrayOf(
                Manifest.permission.BLUETOOTH_SCAN,
                Manifest.permission.BLUETOOTH_CONNECT,
                Manifest.permission.ACCESS_FINE_LOCATION
            )
        } else {
            arrayOf(
                Manifest.permission.BLUETOOTH,
                Manifest.permission.BLUETOOTH_ADMIN,
                Manifest.permission.ACCESS_FINE_LOCATION
            )
        }
        
        val allGranted = permissions.all {
            ContextCompat.checkSelfPermission(activity, it) == PackageManager.PERMISSION_GRANTED
        }
        
        if (allGranted) {
            result.success(true)
        } else {
            ActivityCompat.requestPermissions(activity, permissions, PERMISSION_REQUEST_CODE)
            // Note: In a real implementation, you'd handle the result in onRequestPermissionsResult
            result.success(false)
        }
    }
    
    private fun startDeviceScan(result: MethodChannel.Result) {
        // TODO: Implement LibMuse device scanning
        /*
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
                            "batteryPercent" to 0 // Update when available
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
        */
        
        // STUB: Send dummy device for testing without SDK
        android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
            deviceScanSink?.success(listOf(
                mapOf(
                    "id" to "00:55:DA:B0:XX:XX",
                    "name" to "Muse-TEST",
                    "isConnected" to false,
                    "batteryPercent" to 75
                )
            ))
        }, 1000)
        result.success(null)
    }
    
    private fun stopDeviceScan(result: MethodChannel.Result) {
        // TODO: Implement stopping scan
        /*
        museManager?.stopListening()
        */
        result.success(null)
    }
    
    private fun connectToDevice(deviceId: String, result: MethodChannel.Result) {
        // TODO: Implement device connection
        /*
        try {
            val muse = museManager?.getMuses()?.find { it.macAddress == deviceId }
            if (muse != null) {
                // Set up connection listener
                val connectionListener = object : MuseConnectionListener {
                    override fun receiveMuseConnectionPacket(p: MuseConnectionPacket, muse: Muse?) {
                        val connectionState = p.currentConnectionState
                        connectionStatusSink?.success(mapOf(
                            "deviceId" to deviceId,
                            "isConnected" to (connectionState == ConnectionState.CONNECTED),
                            "batteryPercent" to 0 // Update when battery data available
                        ))
                    }
                }
                muse.registerConnectionListener(connectionListener)
                
                // Register data listeners
                registerDataListeners(muse, deviceId)
                
                // Connect
                muse.runAsynchronously()
                connectedMuses[deviceId] = muse
                result.success(true)
            } else {
                result.success(false)
            }
        } catch (e: Exception) {
            result.error("CONNECTION_ERROR", e.message, null)
        }
        */
        result.success(true) // STUB
    }
    
    private fun disconnectFromDevice(deviceId: String, result: MethodChannel.Result) {
        // TODO: Implement disconnection
        /*
        connectedMuses[deviceId]?.disconnect()
        connectedMuses.remove(deviceId)
        dataListeners.remove(deviceId)
        */
        result.success(null)
    }
    
    private fun startDataStream(deviceId: String, result: MethodChannel.Result) {
        // Data streaming is automatically started when listeners are registered
        result.success(null)
    }
    
    private fun stopDataStream(deviceId: String, result: MethodChannel.Result) {
        // Data streaming will stop when device is disconnected
        result.success(null)
    }
    
    // TODO: Implement data listener registration
    /*
    private fun registerDataListeners(muse: Muse, deviceId: String) {
        val sessionStartTime = System.currentTimeMillis()
        
        // EEG data listener
        val eegListener = object : MuseDataListener {
            override fun receiveMuseDataPacket(p: MuseDataPacket, muse: Muse?) {
                if (p.packetType() == MuseDataPacketType.EEG) {
                    val eegData = mapOf(
                        "deviceId" to deviceId,
                        "timestamp" to p.timestamp(),
                        "msElapsed" to (System.currentTimeMillis() - sessionStartTime).toInt(),
                        "tp9Raw" to p.getEegChannelValue(Eeg.TP9),
                        "af7Raw" to p.getEegChannelValue(Eeg.AF7),
                        "af8Raw" to p.getEegChannelValue(Eeg.AF8),
                        "tp10Raw" to p.getEegChannelValue(Eeg.TP10),
                        "drl" to p.getEegChannelValue(Eeg.DRL),
                        "ref" to p.getEegChannelValue(Eeg.REF)
                    )
                    activity.runOnUiThread {
                        eegDataSink?.success(eegData)
                    }
                }
            }
            override fun receiveMuseArtifactPacket(p: MuseArtifactPacket, muse: Muse?) {}
        }
        
        muse.registerDataListener(eegListener, MuseDataPacketType.EEG)
        
        // Add similar listeners for band powers, fNIRS, IMU, etc.
    }
    */
    
    fun dispose() {
        // TODO: Clean up LibMuse resources
        /*
        connectedMuses.values.forEach { it.disconnect() }
        connectedMuses.clear()
        museManager?.stopListening()
        */
    }
}
