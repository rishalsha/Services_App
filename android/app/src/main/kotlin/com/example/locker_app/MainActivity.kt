package com.example.locker_app

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine


class MainActivity : FlutterActivity() {
    private val channelName = "services.share/channel"
    private val deleteChannel = "com.example/file_deleter"
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, deleteChannel).setMethodCallHandler {
            call, result ->
            // The method name MUST be identical to the one in your Dart code
            if (call.method == "deleteFileFromUri") {
                val uriString = call.argument<String>("uri")

                if (uriString != null) {
                    try {
                        val fileUri = Uri.parse(uriString)
                        val rowsDeleted = context.contentResolver.delete(fileUri, null, null)

                        if (rowsDeleted > 0) {
                            result.success(true) // Success
                        } else {
                            result.success(false) // Failed (e.g., file not found)
                        }
                    } catch (e: SecurityException) {
                        result.error("PERMISSION_ERROR", "Permission denied to delete file.", e.toString())
                    } catch (e: Exception) {
                        result.error("DELETE_ERROR", "Generic error deleting file.", e.toString())
                    }
                } else {
                    result.error("INVALID_ARGS", "URI string was null.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

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
