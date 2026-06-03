package com.phantom.phantom

import android.content.Context
import android.net.Uri
import android.provider.ContactsContract
import android.telecom.Call
import android.telecom.CallScreeningService
import android.util.Log

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
                        blockCall(callDetails)
                        return
                    }
                } 
                // If Phantom Mode is OFF, but Block Unknown is ON, block non-contacts.
                else if (isBlockUnknownEnabled) {
                    val isContact = isPhoneNumberInContacts(phoneNumber)
                    Log.d(TAG, "Block Unknown ON. Is contact: $isContact")

                    if (!isContact) {
                        Log.d(TAG, "Blocking unknown caller.")
                        blockCall(callDetails)
                        return
                    }
                }
            }
        }

        // Allow the call by default
        val defaultResponse = CallResponse.Builder().build()
        respondToCall(callDetails, defaultResponse)
    }

    private fun blockCall(callDetails: Call.Details) {
        val response = CallResponse.Builder()
            .setDisallowCall(true)
            .setRejectCall(true)
            .setSkipCallLog(false)
            .setSkipNotification(true)
            .build()
        respondToCall(callDetails, response)
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
