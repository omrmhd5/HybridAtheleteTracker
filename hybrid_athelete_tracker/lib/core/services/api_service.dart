import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import 'storage_service.dart';

class ApiService {
  late final Dio _dio;
  final StorageService _storageService;

  ApiService(this._storageService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await _storageService.getToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            return handler.next(options);
          } catch (e) {
            debugPrint('--- API INTERCEPTOR ERROR --- $e');
            // If storage fails (e.g. MissingPluginException), still try to send the request
            // or reject it. For login/register, sending without token is fine.
            return handler.next(options);
          }
        },
        onError: (DioException error, handler) async {
          final response = error.response;
          final requestPath = error.requestOptions.path;
          final alreadyRetried =
              error.requestOptions.extra['__retried__'] == true;

          // On a 401 (expired access token), try to refresh once and retry the
          // original request. Skip auth endpoints to avoid loops.
          final isAuthCall = requestPath.contains(ApiConstants.refresh) ||
              requestPath.contains(ApiConstants.login) ||
              requestPath.contains(ApiConstants.register);

          if (response?.statusCode == 401 && !alreadyRetried && !isAuthCall) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              try {
                final newToken = await _storageService.getToken();
                final opts = error.requestOptions;
                opts.extra['__retried__'] = true;
                opts.headers['Authorization'] = 'Bearer $newToken';
                final retryResponse = await _dio.fetch(opts);
                return handler.resolve(retryResponse);
              } catch (e) {
                debugPrint('--- API RETRY FAILED --- $e');
              }
            } else {
              // Refresh failed — clear tokens so the app falls back to login.
              await _storageService.clearTokens();
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  /// Calls /auth/refresh with the stored refresh token on a bare Dio client
  /// (no interceptors) to avoid recursion. Returns true on success.
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final bare = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      final res = await bare.post(
        ApiConstants.refresh,
        data: {'refreshToken': refreshToken},
      );

      final data = res.data['data'];
      final newToken = data?['token'];
      final newRefresh = data?['refreshToken'];
      if (newToken == null) return false;

      await _storageService.saveToken(newToken);
      if (newRefresh != null) {
        await _storageService.saveRefreshToken(newRefresh);
      }
      return true;
    } catch (e) {
      debugPrint('--- API TOKEN REFRESH ERROR --- $e');
      return false;
    }
  }

  Dio get client => _dio;
}
