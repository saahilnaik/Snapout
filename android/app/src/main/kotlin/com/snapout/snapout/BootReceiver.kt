package com.snapout.snapout

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.content.ContextCompat

/** Restarts the detection service after a reboot if the user had protected apps. */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return

        val targets = context
            .getSharedPreferences(DetectionService.PREFS, Context.MODE_PRIVATE)
            .getStringSet(DetectionService.KEY_TARGETS, emptySet()) ?: emptySet()
        if (targets.isEmpty()) return

        val serviceIntent = Intent(context, DetectionService::class.java).apply {
            action = DetectionService.ACTION_START
            putStringArrayListExtra(DetectionService.EXTRA_TARGETS, ArrayList(targets))
        }
        ContextCompat.startForegroundService(context, serviceIntent)
    }
}
