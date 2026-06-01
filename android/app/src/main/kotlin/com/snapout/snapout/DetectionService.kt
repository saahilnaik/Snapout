package com.snapout.snapout

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat

/**
 * Foreground service that polls [UsageStatsManager] to learn which app is in the
 * foreground. When a user-chosen ("protected") package comes forward, it fires the
 * breathing intervention by launching [MainActivity] on top.
 *
 * State machine per package: IDLE -> DETECTED (fire + start cooldown) -> COOLDOWN
 * (ignore the same trigger for [COOLDOWN_MS]) -> IDLE.
 */
class DetectionService : Service() {

    companion object {
        const val ACTION_START = "com.snapout.snapout.action.START"
        const val ACTION_STOP = "com.snapout.snapout.action.STOP"
        const val EXTRA_TARGETS = "targets"

        private const val CHANNEL_ID = "snapout_detection"
        private const val NOTIF_ID = 1001
        private const val POLL_MS = 800L
        private const val COOLDOWN_MS = 30_000L

        const val PREFS = "snapout_prefs"
        const val KEY_TARGETS = "targets"

        /** Packages the user chose to protect. */
        @Volatile
        var targets: Set<String> = emptySet()

        @Volatile
        var isRunning = false

        /** Set by MainActivity to forward detections to the Flutter EventChannel. */
        @Volatile
        var onDetected: ((String) -> Unit)? = null
    }

    private val handler = Handler(Looper.getMainLooper())
    private lateinit var usm: UsageStatsManager
    private var lastForeground: String? = null
    private var lastQueryTime: Long = 0L
    private var cooldownUntil: Long = 0L

    private val poll = object : Runnable {
        override fun run() {
            checkForeground()
            handler.postDelayed(this, POLL_MS)
        }
    }

    override fun onCreate() {
        super.onCreate()
        usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        lastQueryTime = System.currentTimeMillis() - 5_000
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            stopForegroundCompat()
            stopSelf()
            return START_NOT_STICKY
        }

        intent?.getStringArrayListExtra(EXTRA_TARGETS)?.let {
            targets = it.toSet()
            persistTargets(targets)
        } ?: run {
            // Restarted by the system or boot — restore from prefs.
            if (targets.isEmpty()) targets = loadTargets()
        }

        startForegroundCompat()
        isRunning = true
        handler.removeCallbacks(poll)
        handler.post(poll)
        return START_STICKY
    }

    private fun checkForeground() {
        val now = System.currentTimeMillis()
        val events = usm.queryEvents(lastQueryTime, now)
        lastQueryTime = now

        val event = UsageEvents.Event()
        var fg = lastForeground
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            val resumed = event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND ||
                event.eventType == UsageEvents.Event.ACTIVITY_RESUMED
            if (resumed) fg = event.packageName
        }

        if (fg == null || fg == lastForeground) return
        lastForeground = fg

        if (fg == packageName) return // ignore ourselves
        if (fg in targets && now >= cooldownUntil) {
            cooldownUntil = now + COOLDOWN_MS
            onDetected?.invoke(fg)
            launchIntervention(fg)
        }
    }

    private fun launchIntervention(blockedPackage: String) {
        val intent = Intent(this, MainActivity::class.java).apply {
            addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP,
            )
            putExtra(MainActivity.EXTRA_ROUTE, "/breathing?live=1&pkg=$blockedPackage")
            putExtra(MainActivity.EXTRA_BLOCKED_PACKAGE, blockedPackage)
        }
        startActivity(intent)
    }

    // --- Foreground notification ---

    private fun startForegroundCompat() {
        val notification = buildNotification()
        if (Build.VERSION.SDK_INT >= 34) {
            startForeground(NOTIF_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        } else {
            startForeground(NOTIF_ID, notification)
        }
    }

    private fun buildNotification(): Notification {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "SnapOut protection",
                NotificationManager.IMPORTANCE_LOW,
            ).apply { description = "Keeps SnapOut watching your chosen apps." }
            (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
                .createNotificationChannel(channel)
        }

        val openIntent = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("SnapOut is on")
            .setContentText("Watching your chosen apps.")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentIntent(openIntent)
            .build()
    }

    private fun stopForegroundCompat() {
        isRunning = false
        handler.removeCallbacks(poll)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
    }

    // --- Persistence (also read by BootReceiver) ---

    private fun persistTargets(set: Set<String>) {
        getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
            .putStringSet(KEY_TARGETS, set).apply()
    }

    private fun loadTargets(): Set<String> =
        getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getStringSet(KEY_TARGETS, emptySet()) ?: emptySet()

    override fun onDestroy() {
        isRunning = false
        handler.removeCallbacks(poll)
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
