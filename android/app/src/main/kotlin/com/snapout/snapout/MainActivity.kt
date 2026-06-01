package com.snapout.snapout

import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Process
import android.provider.Settings
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        const val EXTRA_ROUTE = "snapout_route"
        const val EXTRA_BLOCKED_PACKAGE = "blocked_package"
        private const val METHOD_CHANNEL = "snapout/detection"
        private const val EVENT_CHANNEL = "snapout/events"
    }

    private var methodChannel: MethodChannel? = null
    private var eventSink: EventChannel.EventSink? = null
    private var pendingRoute: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        methodChannel = MethodChannel(messenger, METHOD_CHANNEL).apply {
            setMethodCallHandler { call, result -> handleMethod(call.method, call, result) }
        }

        EventChannel(messenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    DetectionService.onDetected = { pkg ->
                        runOnUiThread { eventSink?.success(pkg) }
                    }
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                    DetectionService.onDetected = null
                }
            },
        )

        // Cold launch by the detection service: stash the route; Dart pulls it via
        // consumeLaunchRoute once its handler/router is ready (avoids a startup race).
        pendingRoute = intent?.getStringExtra(EXTRA_ROUTE) ?: pendingRoute
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        intent.getStringExtra(EXTRA_ROUTE)?.let { route ->
            if (methodChannel != null) deliverRoute(route) else pendingRoute = route
        }
    }

    private fun deliverRoute(route: String) {
        methodChannel?.invokeMethod("onLaunchRoute", route)
        pendingRoute = null
    }

    private fun handleMethod(method: String, call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        when (method) {
            "hasUsageAccess" -> result.success(hasUsageAccess())
            "requestUsageAccess" -> {
                startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                result.success(null)
            }
            "hasOverlayPermission" -> result.success(Settings.canDrawOverlays(this))
            "requestOverlayPermission" -> {
                startActivity(
                    Intent(
                        Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        Uri.parse("package:$packageName"),
                    ),
                )
                result.success(null)
            }
            "startService" -> {
                @Suppress("UNCHECKED_CAST")
                val targets = (call.argument<List<String>>("targets") ?: emptyList())
                val intent = Intent(this, DetectionService::class.java).apply {
                    action = DetectionService.ACTION_START
                    putStringArrayListExtra(DetectionService.EXTRA_TARGETS, ArrayList(targets))
                }
                ContextCompat.startForegroundService(this, intent)
                result.success(true)
            }
            "stopService" -> {
                val intent = Intent(this, DetectionService::class.java).apply {
                    action = DetectionService.ACTION_STOP
                }
                startService(intent)
                result.success(true)
            }
            "isServiceRunning" -> result.success(DetectionService.isRunning)
            "consumeLaunchRoute" -> {
                result.success(pendingRoute)
                pendingRoute = null
            }
            else -> result.notImplemented()
        }
    }

    private fun hasUsageAccess(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName,
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName,
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }
}
