package com.phantom.phantom

import android.content.Context
import android.net.Uri
import android.os.Build
import android.telecom.Call
import android.telecom.CallScreeningService
import android.telecom.CallScreeningService.CallResponse
import androidx.annotation.RequiresApi
import org.json.JSONArray

@RequiresApi(Build.VERSION_CODES.Q)
class CallBlockerService : CallScreeningService() {

    override fun onScreenCall(callDetails: Call.Details) {
        if (callDetails.callDirection == Call.Details.DIRECTION_INCOMING) {
            val handle: Uri? = callDetails.handle
            val rawNumber = handle?.schemeSpecificPart ?: ""
            
            val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            
            // Read active status config. Key matching Riverpod settings.
            // Format for SharedPreferences when using shared_preferences plugin is usually "flutter.key"
            val isInvisible = prefs.getBoolean("flutter.isInvisible", false)
            val blockDirectCalls = prefs.getBoolean("flutter.blockDirectCalls", false)
            
            if (isInvisible && blockDirectCalls) {
                // Read VIP Contacts from shared preferences (stored as JSON string of phone numbers list)
                val vipListJson = prefs.getString("flutter.vipListCached", "[]") ?: "[]"
                var isVip = false
                try {
                    val jsonArray = JSONArray(vipListJson)
                    val normalizedIncoming = normalizePhoneNumber(rawNumber)
                    for (i in 0 until jsonArray.length()) {
                        val vipNum = jsonArray.optString(i, "")
                        if (normalizePhoneNumber(vipNum) == normalizedIncoming) {
                            isVip = true
                            break
                        }
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }

                if (!isVip) {
                    // Decline/Terminates the call instantly on the device!
                    val response = CallResponse.Builder()
                        .setDisallowCall(true)
                        .setRejectCall(true)
                        .setSkipCallLog(false) // Still keep in device call history as missed
                        .build()
                    respondToCall(callDetails, response)
                    return
                }
            }
        }
        
        // Allow the call normally
        respondToCall(callDetails, CallResponse.Builder().build())
    }

    private fun normalizePhoneNumber(phone: String): String {
        val cleaned = phone.replace(Regex("[^0-9]"), "")
        // Match last 10 digits to bypass varying country codes
        return if (cleaned.length >= 10) cleaned.substring(cleaned.length - 10) else cleaned
    }
}
