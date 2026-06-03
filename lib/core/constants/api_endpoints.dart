

class ApiEndpoints {
  ApiEndpoints._();
  
  // Base URL - Change this to your server URL
  static String get baseUrl {
    // if (Platform.isAndroid) {
    //   return 'http://192.168.0.73:5000/api';
    // }
    // return 'http://localhost:5000/api';
    return 'https://phantom-backend-eli0.onrender.com/api';
  }

  // Auth
  static const String login = '/auth/login';
  static const String verifyOtp = '/auth/verify';
  static const String me = '/auth/me';
  
  // VIP Contacts
  static const String vipList = '/vip/list';
  static const String vipAdd = '/vip/add';
  static String vipRemove(String id) => '/vip/remove/$id';
  
  // Invisible Mode
  static const String invisibleToggle = '/invisible/toggle';
  static const String invisibleStatus = '/invisible/status';
  
  // Call Logs
  static const String callLog = '/calls/log';
  static const String callStats = '/calls/stats';
  
  // Schedules
  static const String scheduleList = '/schedule/list';
  static const String scheduleSet = '/schedule/set';
  static String scheduleUpdate(String id) => '/schedule/update/$id';
  static String scheduleDelete(String id) => '/schedule/delete/$id';
  
  // Subscription
  static const String subscriptionPlans = '/subscription/plans';
  static const String subscriptionUpgrade = '/subscription/upgrade';
  
  // User
  static const String updateProfile = '/user/profile';
  static const String updateCustomMessage = '/user/custom-message';
}
