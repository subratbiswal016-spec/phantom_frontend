import 'package:flutter/services.dart';

class CallBlockingService {
  static const MethodChannel _channel =
      MethodChannel('com.phantom.phantom/call_blocking');

  /// Requests the user to set this app as the default call screening app.
  /// Returns true if the user granted the role, false otherwise.
  static Future<bool> requestCallScreeningRole() async {
    try {
      final bool? result = await _channel.invokeMethod('requestCallScreeningRole');
      return result ?? false;
    } catch (e) {
      print('Error requesting call screening role: $e');
      return false;
    }
  }

  /// Tells the native Android service whether to block unknown numbers or not.
  static Future<void> setBlockUnknown(bool enabled) async {
    try {
      await _channel.invokeMethod('setBlockUnknown', {'enabled': enabled});
    } catch (e) {
      print('Error setting block unknown natively: $e');
    }
  }

  /// Tells the native Android service whether Phantom Mode is ON.
  static Future<void> setInvisibleMode(bool enabled) async {
    try {
      await _channel.invokeMethod('setInvisibleMode', {'enabled': enabled});
    } catch (e) {
      print('Error setting invisible mode natively: $e');
    }
  }

  /// Syncs the VIP list to native Android for Phantom Mode filtering.
  static Future<void> syncVipList(List<String> vipList) async {
    try {
      await _channel.invokeMethod('syncVipList', {'vipList': vipList});
    } catch (e) {
      print('Error syncing VIP list natively: $e');
    }
  }
}
