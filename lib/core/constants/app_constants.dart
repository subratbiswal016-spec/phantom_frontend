class AppConstants {
  AppConstants._();
  
  static const String appName = 'Phantom';
  static const String appTagline = 'Go Invisible. Stay Connected.';
  static const String appDescription = 'Appear switched off to everyone except your VIP contacts.';
  
  // Subscription Plans
  static const String freePlan = 'free';
  static const String basicPlan = 'basic';
  static const String proPlan = 'pro';
  static const String businessPlan = 'business';
  
  // Plan Limits
  static const int freeVipLimit = 3;
  static const int basicVipLimit = 10;
  static const int proVipLimit = -1; // unlimited
  static const int businessVipLimit = -1; // unlimited
  
  // Plan Prices (INR)
  static const int basicPrice = 49;
  static const int proPrice = 99;
  static const int businessPrice = 199;
  
  // Local storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String invisibleKey = 'is_invisible';
  static const String vipCacheKey = 'vip_cache';
  static const String onboardingKey = 'onboarding_complete';
  static const String themeKey = 'app_theme';
  
  // Call Status
  static const String callBlocked = 'blocked';
  static const String callForwarded = 'forwarded';
}
