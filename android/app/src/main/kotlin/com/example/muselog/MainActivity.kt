package com.example.muselog

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    private var musePlatformChannel: MusePlatformChannel? = null
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Initialize and setup Muse platform channel
        musePlatformChannel = MusePlatformChannel(this)
        musePlatformChannel?.setupChannels(flutterEngine.dartExecutor.binaryMessenger)
    }
    
    override fun onDestroy() {
        musePlatformChannel?.dispose()
        super.onDestroy()
    }
}
