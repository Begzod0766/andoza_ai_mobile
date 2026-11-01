package com.tamir_uy.tamir_uy_mobile_flutter

import android.content.Intent
import android.os.Bundle
import com.tamir_uy.tamir_uy_mobile_flutter.arscan.ArScanChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    private var arScan: ArScanChannel? = null
    private val share = ShareChannel()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Only a fresh launch: a recreated activity (rotation, process restore)
        // still carries the share it was started with, already handled.
        if (savedInstanceState == null) share.receive(intent)
    }

    // singleTop: a share while the app is open arrives here, not in onCreate.
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        share.receive(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // The ARCore floor-plan scanner (andoza/arscan); its result comes back
        // through onActivityResult below.
        arScan = ArScanChannel(this).also { it.setup(flutterEngine) }
        share.setup(flutterEngine)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        arScan?.handleActivityResult(requestCode, resultCode, data)
    }
}
