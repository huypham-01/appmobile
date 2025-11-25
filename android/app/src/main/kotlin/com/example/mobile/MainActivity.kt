package com.example.mobile

import android.app.AlarmManager
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val CHANNEL = "maintenance/alarm"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {

                "scheduleAlarm" -> {
                    val hour = call.argument<Int>("hour")!!
                    val minute = call.argument<Int>("minute")!!
                    Log.d("MainActivity", "scheduleAlarm: $hour:$minute")
                    AlarmScheduler(this).scheduleDaily(hour, minute)
                    result.success(true)
                }

                "scheduleAlarmInSeconds" -> {
                    val seconds = call.argument<Int>("seconds") ?: 15
                    Log.d("MainActivity", "scheduleAlarmInSeconds: $seconds")
                    AlarmScheduler(this).scheduleInSeconds(seconds)
                    result.success(true)
                }

                "openExactAlarmSettings" -> {
                    openExactAlarmSettings()
                    result.success(true)
                }

                "canScheduleExactAlarms" -> {
                    val can = canScheduleExactAlarms()
                    result.success(can)
                }

                else -> result.notImplemented()
            }
        }
    }

    // ---------------------------------------------------
    // 🔥 HÀM KIỂM TRA XEM APP ĐÃ CÓ QUYỀN exact alarm CHƯA
    // ---------------------------------------------------
    private fun canScheduleExactAlarms(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val alarmManager = getSystemService(ALARM_SERVICE) as AlarmManager
            alarmManager.canScheduleExactAlarms()
        } else {
            true
        }
    }

    // ---------------------------------------------------
    // 🔥 HÀM XIN QUYỀN exact alarm (mở màn hình hệ thống)
    // ---------------------------------------------------
    private fun openExactAlarmSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val alarmManager = getSystemService(ALARM_SERVICE) as AlarmManager

            if (!alarmManager.canScheduleExactAlarms()) {
                Log.d("MainActivity", "➡ Opening exact alarm permission screen")

                val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                    data = Uri.parse("package:$packageName")
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                startActivity(intent)
            } else {
                Log.d("MainActivity", "✔ Already granted exact alarm permission")
            }
        } else {
            Log.d("MainActivity", "✔ Exact alarm permission not required on this Android version")
        }
    }
}
