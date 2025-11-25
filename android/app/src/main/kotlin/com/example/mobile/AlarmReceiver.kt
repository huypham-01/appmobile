package com.example.mobile

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.app.NotificationChannel
import android.app.NotificationManager
import android.util.Log
import androidx.core.app.NotificationCompat

class AlarmReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        Log.d("AlarmReceiver", "🔥 AlarmReceiver triggered!")

        // Đọc message bảo trì mà Flutter đã lưu
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val message = prefs.getString("flutter.maintenance_message", "No maintenance data available")
        val title = prefs.getString("flutter.maintenance_title", "Maintenance Reminder")

        val channelId = "maintenance_alarm_channel"
        val channelName = "Maintenance Alarm"

        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Tạo channel nếu chưa có
        val channel = NotificationChannel(
            channelId,
            channelName,
            NotificationManager.IMPORTANCE_HIGH
        )
        notificationManager.createNotificationChannel(channel)

        // Build notification
        val notification = NotificationCompat.Builder(context, channelId)
            .setContentTitle(title)
            .setContentText(message)
            .setStyle(
                NotificationCompat.BigTextStyle()
                    .bigText(message)
            )
            .setSmallIcon(R.mipmap.ic_launcher)
            .build()

        Log.d("AlarmReceiver", "Sending notification: $message")
        notificationManager.notify(10001, notification)

        // 🔁 schedule lại cho ngày hôm sau
        val scheduler = AlarmScheduler(context)
        scheduler.scheduleDaily(7, 0)
        scheduler.scheduleDaily(19, 0)
    }
}
