package com.phantom.phantom

import android.app.role.RoleManager
import android.content.Context
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.phantom.phantom/call_blocking"
    private val REQUEST_ID_CALL_SCREENING = 1001
    
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestCallScreeningRole" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        val roleManager = getSystemService(Context.ROLE_SERVICE) as RoleManager
                        if (!roleManager.isRoleHeld(RoleManager.ROLE_CALL_SCREENING)) {
                            val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_CALL_SCREENING)
                            pendingResult = result
                            startActivityForResult(intent, REQUEST_ID_CALL_SCREENING)
                        } else {
                            result.success(true)
                        }
                    } else {
                        // For older versions, this feature is not supported in the same way via RoleManager
                        result.error("UNSUPPORTED", "Call screening role requires Android 10+", null)
                    }
                }
                "setBlockUnknown" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                    prefs.edit().putBoolean("flutter.block_unknown_enabled", enabled).apply()
                    result.success(true)
                }
                "setInvisibleMode" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                    prefs.edit().putBoolean("flutter.invisible_mode_enabled", enabled).apply()
                    result.success(true)
                }
                "syncVipList" -> {
                    val vipList = call.argument<List<String>>("vipList") ?: emptyList()
                    val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                    prefs.edit().putStringSet("flutter.vip_list", vipList.toSet()).apply()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == REQUEST_ID_CALL_SCREENING) {
            if (resultCode == RESULT_OK) {
                pendingResult?.success(true)
            } else {
                pendingResult?.success(false)
            }
            pendingResult = null
        }
        super.onActivityResult(requestCode, resultCode, data)
    }
}
