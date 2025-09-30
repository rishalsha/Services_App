package com.example.locker_app

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "services.share/channel"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleShareIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleShareIntent(intent)
    }

    private fun handleShareIntent(intent: Intent?) {
        if (intent == null) return
        val action = intent.action
        val type = intent.type
        if (Intent.ACTION_SEND == action && type != null) {
            (intent.getParcelableExtra(Intent.EXTRA_STREAM) as? Uri)?.let { uri ->
                notifyDart(listOf(uri.toString()))
            }
        } else if (Intent.ACTION_SEND_MULTIPLE == action && type != null) {
            val uris = intent.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM) ?: arrayListOf()
            notifyDart(uris.map { it.toString() })
        }
    }

    private fun notifyDart(paths: List<String>) {
        if (paths.isEmpty()) return
        val engine = flutterEngine ?: return
        MethodChannel(engine.dartExecutor.binaryMessenger, channelName).invokeMethod("ingestShared", paths)
    }
}
