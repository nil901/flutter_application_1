package com.example.flutter_application_1

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.telephony.PhoneStateListener
import android.telephony.TelephonyManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.call_tracker"
    private lateinit var telephonyManager: TelephonyManager
    private var callListener: PhoneStateListener? = null
    private lateinit var channel: MethodChannel
    private var callStartTime: Long = 0
    private var isCallActive = false

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startCallTracking" -> {
                    if (startCallTracking()) result.success(true)
                    else result.error("PERMISSION_DENIED", "Need phone permissions", null)
                }
                "makeCall" -> {
                    val number = call.argument<String>("number")
                    if (number != null && makeCall(number)) result.success(true)
                    else result.error("INVALID_NUMBER", "Couldn't dial", null)
                }
                "launchAppFromBackground" -> {
                    bringAppToForeground()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startCallTracking(): Boolean {
        return try {
            telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager

            callListener = object : PhoneStateListener() {
                override fun onCallStateChanged(state: Int, phoneNumber: String?) {
                    when (state) {
                        TelephonyManager.CALL_STATE_RINGING -> {
                            isCallActive = false
                            channel.invokeMethod("onCallRinging", mapOf(
                                "number" to phoneNumber,
                                "isRinging" to true
                            ))
                            bringAppToForeground()
                        }
                        TelephonyManager.CALL_STATE_OFFHOOK -> {
                            if (!isCallActive) {
                                isCallActive = true
                                callStartTime = System.currentTimeMillis()
                                channel.invokeMethod("onCallStarted", mapOf(
                                    "isActive" to true
                                ))
                            }
                        }
                        TelephonyManager.CALL_STATE_IDLE -> {
                            if (isCallActive) {
                                val duration = System.currentTimeMillis() - callStartTime
                                channel.invokeMethod("onCallEnded", mapOf(
                                    "duration" to duration,
                                    "wasActive" to true
                                ))
                                isCallActive = false
                                bringAppToForeground()
                            }
                        }
                    }
                }
            }

            telephonyManager.listen(callListener, PhoneStateListener.LISTEN_CALL_STATE)
            true
        } catch (e: SecurityException) {
            false
        }
    }

    private fun bringAppToForeground() {
        val launchIntent = Intent(this@MainActivity, MainActivity::class.java)
        launchIntent.addFlags(
            Intent.FLAG_ACTIVITY_NEW_TASK or
            Intent.FLAG_ACTIVITY_SINGLE_TOP or
            Intent.FLAG_ACTIVITY_CLEAR_TOP
        )
        startActivity(launchIntent)
    }

    private fun makeCall(number: String): Boolean {
        return try {
            val intent = Intent(Intent.ACTION_CALL).apply {
                data = Uri.parse("tel:$number")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            startActivity(intent)
            true
        } catch (e: Exception) {
            false
        }
    }

    override fun onDestroy() {
        callListener?.let {
            telephonyManager.listen(it, PhoneStateListener.LISTEN_NONE)
        }
        super.onDestroy()
    }
}
