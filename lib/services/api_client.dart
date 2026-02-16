// ============================================================================
// FILE: api_client.dart
// DESCRIPTION: HTTP client wrapper for API communication with backend
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: AI Assistant
// WEBSITE: https://www.stellantis.com/
// VERSION: 1.0.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

import 'dart:io';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'storage_service.dart';

/// HTTP Client wrapper for API communication
///
/// Provides:
/// - Automatic token management
/// - Request/response logging
/// - Error handling
/// - Retry logic
/// - Timeout management
/// - Dynamic URL detection (local vs remote)
class ApiClient {
  // Singleton pattern
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late final Dio _dio;
  final StorageService _storage = StorageService();
  String? _baseUrl;

  /// Initialize Dio with dynamic base URL detection
  Future<void> initialize() async {
    _baseUrl = await ApiConfig.getBaseUrl();
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl ?? 'http://52.90.100.90:8000',
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: ApiConfig.defaultHeaders,
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_createLoggingInterceptor());
    _dio.interceptors.add(_createAuthInterceptor());
    _dio.interceptors.add(_createRetryInterceptor());
  }

  /// Logging interceptor for debugging
  Interceptor _createLoggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        if (ApiConfig.debugMode) {
          print('🚀 [API Request] ${options.method} ${options.path}');
          print('   Headers: ${options.headers}');
          if (options.data != null) {
            print('   Data: ${options.data}');
          }
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (ApiConfig.debugMode) {
          print('✅ [API Response] ${response.statusCode} ${response.requestOptions.path}');
          print('   Data: ${response.data}');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (ApiConfig.debugMode) {
          print('❌ [API Error] ${error.requestOptions.path}');
          print('   Message: ${error.message}');
          print('   Response: ${error.response?.data}');
        }
        handler.next(error);
      },
    );
  }

  /// Authentication interceptor - adds token to requests
  Interceptor _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Get token from storage
        final token = await _storage.get<String>('auth_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 Unauthorized - token expired
        if (error.response?.statusCode == 401) {
          // Clear token and user data
          await _storage.remove('auth_token');
          await _storage.remove('user_data');

          // Could trigger logout navigation here
          print('🔒 Token expired - user needs to re-authenticate');
        }
        handler.next(error);
      },
    );
  }

  /// Retry interceptor for failed requests
  Interceptor _createRetryInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        if (_shouldRetry(error)) {
          try {
            // Retry the request
            final response = await _retry(error.requestOptions);
            handler.resolve(response);
          } catch (e) {
            handler.next(error);
          }
        } else {
          handler.next(error);
        }
      },
    );
  }

  /// Check if request should be retried
  bool _shouldRetry(DioException error) {
    // Retry on network errors and server errors (5xx)
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        (error.response?.statusCode != null &&
            error.response!.statusCode! >= 500);
  }

  /// Retry failed request
  Future<Response> _retry(RequestOptions requestOptions) async {
    int attempts = 0;

    while (attempts < ApiConfig.maxRetries) {
      try {
        await Future.delayed(ApiConfig.retryDelay * (attempts + 1));
        return await _dio.request(
          requestOptions.path,
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
          options: Options(
            method: requestOptions.method,
            headers: requestOptions.headers,
          ),
        );
      } catch (e) {
        attempts++;
        if (attempts >= ApiConfig.maxRetries) {
          rethrow;
        }
      }
    }

    throw DioException(
      requestOptions: requestOptions,
      error: 'Max retries exceeded',
    );
  }

  // === HTTP Methods ===

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Multipart file upload
  Future<Response> uploadFile(
    String path, {
    required File file,
    required String fieldName,
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        ...?data,
        fieldName: await MultipartFile.fromFile(file.path),
      });

      return await _dio.post(
        path,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors and convert to user-friendly messages
  Exception _handleError(DioException error) {
    String message = 'An error occurred';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;

        if (statusCode == 400) {
          message = responseData?['detail'] ?? 'Invalid request';
        } else if (statusCode == 401) {
          message = 'Unauthorized. Please login again.';
        } else if (statusCode == 403) {
          message = 'Access forbidden';
        } else if (statusCode == 404) {
          message = 'Resource not found';
        } else if (statusCode == 413) {
          message = 'File too large. Maximum size is 15MB.';
        } else if (statusCode == 500) {
          message = 'Server error. Please try again later.';
        } else {
          message = responseData?['detail'] ?? 'Request failed';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled';
        break;
      case DioExceptionType.unknown:
        message = 'Network error. Please check your connection.';
        break;
      default:
        message = error.message ?? 'An error occurred';
    }

    return Exception(message);
  }

  /// Clear all cached data
  void clearCache() {
    _dio.close();
    _initializeDio();
  }
}

// ============================================================================
// END OF FILE: api_client.dart
// ============================================================================


