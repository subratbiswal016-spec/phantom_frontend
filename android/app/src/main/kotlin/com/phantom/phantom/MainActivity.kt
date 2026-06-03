package com.phantom.phantom

import android.app.role.RoleManager
import android.content.Context
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.phantom.app/call_blocker"
    private val ROLE_REQUEST_CODE = 4321

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestCallScreeningRole" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        val roleManager = getSystemService(Context.ROLE_SERVICE) as RoleManager
                        val isSupported = roleManager.isRoleAvailable(RoleManager.ROLE_CALL_SCREENING)
                        val isHeld = roleManager.isRoleHeld(RoleManager.ROLE_CALL_SCREENING)
                        
                        if (isSupported && !isHeld) {
                            val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_CALL_SCREENING)
                            startActivityForResult(intent, ROLE_REQUEST_CODE)
                            result.success(true)
                        } else {
                            result.success(isHeld)
                        }
                    } else {
                        // Not supported on < Android 10
                        result.error("UNSUPPORTED", "Android version must be 10 (Q) or higher", null)
                    }
                }
                "checkCallScreeningRole" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        val roleManager = getSystemService(Context.ROLE_SERVICE) as RoleManager
                        result.success(roleManager.isRoleHeld(RoleManager.ROLE_CALL_SCREENING))
                    } else {
                        result.success(false)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}

