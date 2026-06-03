import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_endpoints.dart';

final dioProvider = Provider<Dio>((ref) {
  return ApiClient.createDio();
});

class ApiClient {
  static Dio createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Request interceptor — attach auth token
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // TODO: Get token from secure storage
        // final token = await SecureStorage.getToken();
        // if (token != null) {
        //   options.headers['Authorization'] = 'Bearer $token';
        // }
        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (error, handler) {
        _handleError(error);
        handler.next(error);
      },
    ));
    
    // Logging in debug mode
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => print('📡 API: $obj'),
    ));
    
    return dio;
  }
  
  static void _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        print('⏰ Connection timeout');
        break;
      case DioExceptionType.receiveTimeout:
        print('⏰ Receive timeout');
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        print('❌ Bad response: $statusCode');
        if (statusCode == 401) {
          // Token expired — redirect to login
          print('🔐 Unauthorized — token expired');
        }
        break;
      case DioExceptionType.connectionError:
        print('🌐 No internet connection');
        break;
      default:
        print('❌ Unknown error: ${error.message}');
    }
  }
}
