package com.phantom.phantom

import android.content.Context
import android.net.Uri
import android.provider.ContactsContract
import android.telecom.Call
import android.telecom.CallScreeningService
import android.util.Log
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL
import org.json.JSONObject

class PhantomCallScreeningService : CallScreeningService() {
    private val TAG = "PhantomCallScreening"

    override fun onScreenCall(callDetails: Call.Details) {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val isBlockUnknownEnabled = prefs.getBoolean("flutter.block_unknown_enabled", false)
        val isInvisibleModeEnabled = prefs.getBoolean("flutter.invisible_mode_enabled", false)
        val vipList = prefs.getStringSet("flutter.vip_list", emptySet()) ?: emptySet()

        Log.d(TAG, "Incoming call. InvisibleMode: $isInvisibleModeEnabled, BlockUnknown: $isBlockUnknownEnabled")

        if (callDetails.callDirection == Call.Details.DIRECTION_INCOMING) {
            val handle: Uri? = callDetails.handle
            val phoneNumber = handle?.schemeSpecificPart

            if (phoneNumber != null) {
                // If Phantom (Invisible) Mode is ON, block EVERYONE except VIPs.
                if (isInvisibleModeEnabled) {
                    val cleanPhone = phoneNumber.replace(Regex("[^0-9+]"), "")
                    // Check if the clean phone matches any VIP clean phone (or roughly matches)
                    val isVip = vipList.any { vipPhone ->
                        val cleanVip = vipPhone.replace(Regex("[^0-9+]"), "")
                        cleanPhone.endsWith(cleanVip.takeLast(10)) || cleanVip.endsWith(cleanPhone.takeLast(10))
                    }
                    
                    Log.d(TAG, "Phantom Mode ON. Phone: $cleanPhone. Is VIP: $isVip")
                    if (!isVip) {
                        Log.d(TAG, "Phantom Mode: Blocking non-VIP caller.")
                        blockCall(callDetails, phoneNumber)
                        return
                    }
                } 
                // If Phantom Mode is OFF, but Block Unknown is ON, block non-contacts.
                else if (isBlockUnknownEnabled) {
                    val isContact = isPhoneNumberInContacts(phoneNumber)
                    Log.d(TAG, "Block Unknown ON. Is contact: $isContact")

                    if (!isContact) {
                        Log.d(TAG, "Blocking unknown caller.")
                        blockCall(callDetails, phoneNumber)
                        return
                    }
                }
            }
        }

        // Allow the call by default
        val defaultResponse = CallResponse.Builder().build()
        respondToCall(callDetails, defaultResponse)
    }

    private fun blockCall(callDetails: Call.Details, phoneNumber: String) {
        val response = CallResponse.Builder()
            .setDisallowCall(true)
            .setRejectCall(true)
            .setSkipCallLog(false)
            .setSkipNotification(true)
            .build()
        respondToCall(callDetails, response)

        val name = getContactName(phoneNumber)
        reportBlockedCallToBackend(phoneNumber, name)
    }

    private fun reportBlockedCallToBackend(phoneNumber: String, name: String) {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val token = prefs.getString("flutter.auth_token", null)
        if (token == null) {
            Log.w(TAG, "Cannot report blocked call: auth_token is null")
            return
        }

        Thread {
            try {
                val url = URL("https://phantom-backend-eli0.onrender.com/api/calls/log")
                val conn = url.openConnection() as HttpURLConnection
                conn.requestMethod = "POST"
                conn.setRequestProperty("Content-Type", "application/json")
                conn.setRequestProperty("Accept", "application/json")
                conn.setRequestProperty("Authorization", "Bearer $token")
                conn.doOutput = true

                val jsonBody = JSONObject().apply {
                    put("callerPhone", phoneNumber)
                    put("callerName", name)
                    put("status", "blocked")
                }

                conn.outputStream.use { os ->
                    OutputStreamWriter(os, "UTF-8").use { writer ->
                        writer.write(jsonBody.toString())
                        writer.flush()
                    }
                }

                val responseCode = conn.responseCode
                Log.d(TAG, "Reported blocked call. Response code: $responseCode")
                conn.disconnect()
            } catch (e: Exception) {
                Log.e(TAG, "Failed to report blocked call to backend: ${e.message}", e)
            }
        }.start()
    }

    private fun getContactName(phoneNumber: String): String {
        var name = "Unknown"
        val uri = Uri.withAppendedPath(
            ContactsContract.PhoneLookup.CONTENT_FILTER_URI,
            Uri.encode(phoneNumber)
        )
        val projection = arrayOf(ContactsContract.PhoneLookup.DISPLAY_NAME)
        try {
            contentResolver.query(uri, projection, null, null, null)?.use { cursor ->
                if (cursor.moveToFirst()) {
                    val nameIndex = cursor.getColumnIndex(ContactsContract.PhoneLookup.DISPLAY_NAME)
                    if (nameIndex != -1) {
                        name = cursor.getString(nameIndex) ?: "Unknown"
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error querying contact name: ${e.message}")
        }
        return name
    }

    private fun isPhoneNumberInContacts(phoneNumber: String): Boolean {
        var isContact = false
        val uri = Uri.withAppendedPath(
            ContactsContract.PhoneLookup.CONTENT_FILTER_URI,
            Uri.encode(phoneNumber)
        )
        
        val projection = arrayOf(ContactsContract.PhoneLookup._ID)
        
        try {
            contentResolver.query(uri, projection, null, null, null)?.use { cursor ->
                if (cursor.moveToFirst()) {
                    isContact = true
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error querying contacts: ${e.message}")
        }
        
        return isContact
    }
}
