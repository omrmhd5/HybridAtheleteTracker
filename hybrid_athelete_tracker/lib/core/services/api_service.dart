import 'package:dio/dio.dart';
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

    // Add interceptor to inject JWT token
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
            print('--- API INTERCEPTOR ERROR --- $e');
            // If storage fails (e.g. MissingPluginException), still try to send the request
            // or reject it. For login/register, sending without token is fine.
            return handler.next(options);
          }
        },
        onError: (DioException error, handler) async {
          return handler.next(error);
        },
      ),
    );
  }

  Dio get client => _dio;
}
