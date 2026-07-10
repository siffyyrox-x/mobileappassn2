package com.example.mobileappassn2

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.mobileappassn2/broadcast"
    private var methodChannel: MethodChannel? = null

    private val CUSTOM_ACTION = "com.example.mobileappassn2.CUSTOM_ACTION"

    private var batteryReceiver: BroadcastReceiver? = null
    private var customReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "sendCustomBroadcast" -> {
                    val message = call.argument<String>("message")
                    val intent = Intent(CUSTOM_ACTION).apply {
                        putExtra("data", message)
                        setPackage(packageName)
                    }
                    sendBroadcast(intent)
                    result.success(null)
                }
                "registerBatteryReceiver" -> {
                    registerBattery()
                    result.success(null)
                }
                "unregisterBatteryReceiver" -> {
                    unregisterBattery()
                    result.success(null)
                }
                "registerCustomReceiver" -> {
                    registerCustom()
                    result.success(null)
                }
                "unregisterCustomReceiver" -> {
                    unregisterCustom()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun registerBattery() {
        if (batteryReceiver == null) {
            batteryReceiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context?, intent: Intent?) {
                    if (intent?.action == Intent.ACTION_BATTERY_CHANGED) {
                        val level = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
                        val scale = intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
                        val pct = level * 100 / scale
                        runOnUiThread {
                            methodChannel?.invokeMethod("onBatteryPercentageReceived", pct)
                        }
                    }
                }
            }
            registerReceiver(batteryReceiver, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        }
    }

    private fun unregisterBattery() {
        batteryReceiver?.let {
            unregisterReceiver(it)
            batteryReceiver = null
        }
    }

    private fun registerCustom() {
        if (customReceiver == null) {
            customReceiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context?, intent: Intent?) {
                    if (intent?.action == CUSTOM_ACTION) {
                        val receivedMessage = intent.getStringExtra("data") ?: ""
                        runOnUiThread {
                            methodChannel?.invokeMethod("onCustomBroadcastReceived", receivedMessage)
                        }
                    }
                }
            }
            val filter = IntentFilter(CUSTOM_ACTION)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(customReceiver, filter, Context.RECEIVER_EXPORTED)
            } else {
                registerReceiver(customReceiver, filter)
            }
        }
    }

    private fun unregisterCustom() {
        customReceiver?.let {
            unregisterReceiver(it)
            customReceiver = null
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterBattery()
        unregisterCustom()
    }
}
