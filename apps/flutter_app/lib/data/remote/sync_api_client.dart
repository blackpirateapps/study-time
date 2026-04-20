import 'package:dio/dio.dart';

import '../../core/config/app_env.dart';
import '../../core/services/auth_token_provider.dart';
import '../models/study_log.dart';

class SyncApiException implements Exception {
  const SyncApiException({
    required this.message,
    this.statusCode,
  });

  final String message;
  final int? statusCode;

  bool get isServerError => statusCode != null && statusCode! >= 500;

  @override
  String toString() {
    if (statusCode == null) {
      return 'SyncApiException($message)';
    }

    return 'SyncApiException($statusCode: $message)';
  }
}

class SyncApiClient {
  SyncApiClient(this._tokenProvider, {Dio? dio})
      : _dio =
            dio ?? Dio(BaseOptions(baseUrl: AppEnv.apiBaseUrl, contentType: 'application/json'));

  final Dio _dio;
  final AuthTokenProvider _tokenProvider;

  Future<int> syncStudyLogs(List<StudyLog> logs) async {
    if (logs.isEmpty) {
      return 0;
    }

    final token = await _tokenProvider.getBearerToken();
    if (token == null || token.isEmpty) {
      throw const SyncApiException(
        message: 'Missing Firebase bearer token or development override token.',
      );
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/sync',
        data: {
          'study_logs': logs.map((log) => log.toSyncJson()).toList(),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final payload = response.data;
      if (payload == null) {
        throw const SyncApiException(
          message: 'Sync response body was empty.',
          statusCode: 502,
        );
      }

      final createdCount = payload['created_count'];
      if (createdCount is num) {
        return createdCount.toInt();
      }

      throw const SyncApiException(
        message: 'Sync response did not include created_count.',
      );
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      final responsePayload = error.response?.data;

      String message = 'Sync request failed.';
      if (responsePayload is Map<String, dynamic> && responsePayload['error'] is String) {
        message = responsePayload['error'] as String;
      } else if (error.message != null && error.message!.isNotEmpty) {
        message = error.message!;
      }

      throw SyncApiException(
        message: message,
        statusCode: statusCode,
      );
    }
  }
}
