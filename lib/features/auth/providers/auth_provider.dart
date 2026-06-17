import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  final String? token;
  final String? phone;
  final String? name;
  final bool otpSent;

  AuthState({
    this.isLoading = false,
    this.error,
    this.token,
    this.phone,
    this.name,
    this.otpSent = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    String? token,
    String? phone,
    String? name,
    bool? otpSent,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      token: token ?? this.token,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      otpSent: otpSent ?? this.otpSent,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(AuthState()) {
    _loadPersistedToken();
  }

  Future<void> _loadPersistedToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    if (token != null) {
      state = state.copyWith(token: token);
    }
  }

  Future<bool> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      await dio.post(ApiEndpoints.login, data: {'phone': phone});
      state = state.copyWith(isLoading: false, phone: phone, otpSent: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> verifyOtp(String otp, {String? name}) async {
    if (state.phone == null) return false;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(ApiEndpoints.verifyOtp, data: {
        'phone': state.phone,
        'otp': otp,
        if (name != null) 'name': name,
      });

      final responseData = response.data['data'];
      final token = responseData['token'];
      final user = responseData['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, token);
      if (user['name'] != null) {
        await prefs.setString(AppConstants.userKey, user['name']);
      }

      state = state.copyWith(
        isLoading: false,
        token: token,
        name: user['name'],
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
    state = AuthState();
  }
}
