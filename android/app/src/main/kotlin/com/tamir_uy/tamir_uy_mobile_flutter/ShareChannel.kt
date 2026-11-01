package com.tamir_uy.tamir_uy_mobile_flutter

import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * "Share → Andoza AI" (andoza/share): hands text shared to the app, e.g. a
 * Pinterest pin, to Dart.
 *
 * A share that starts the app is kept until Dart asks for it with `take`
 * (the engine is not listening yet at launch). A share while Dart is already
 * listening is sent straight away as `shared`.
 */
class ShareChannel {
    private var channel: MethodChannel? = null
    private var pending: String? = null
    private var dartReady = false

    fun setup(engine: FlutterEngine) {
        channel = MethodChannel(engine.dartExecutor.binaryMessenger, "andoza/share").also {
            it.setMethodCallHandler { call, result ->
                when (call.method) {
                    "take" -> {
                        dartReady = true
                        result.success(pending)
                        pending = null
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    fun receive(intent: Intent?) {
        if (intent?.action != Intent.ACTION_SEND || intent.type != "text/plain") return
        val text = intent.getStringExtra(Intent.EXTRA_TEXT)?.takeIf { it.isNotBlank() } ?: return
        val ch = channel
        if (dartReady && ch != null) ch.invokeMethod("shared", text) else pending = text
    }
}
