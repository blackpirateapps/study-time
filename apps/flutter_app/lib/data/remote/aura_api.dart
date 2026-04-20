import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/app_env.dart';
import '../../core/services/auth_token_provider.dart';
import '../models/feed_session.dart';
import '../models/profile_aggregate.dart';
import '../models/study_log.dart';

class AuraApiException implements Exception {
  const AuraApiException({
    required this.message,
    this.statusCode,
  });

  final String message;
  final int? statusCode;

  @override
  String toString() {
    if (statusCode == null) {
      return 'AuraApiException($message)';
    }

    return 'AuraApiException($statusCode: $message)';
  }
}

class AuraApi {
  AuraApi(this._tokenProvider, {http.Client? client})
      : _client = client ?? http.Client(),
        _baseUri = Uri.parse(AppEnv.apiBaseUrl);

  final AuthTokenProvider _tokenProvider;
  final http.Client _client;
  final Uri _baseUri;

  Uri _uri(String path) => _baseUri.resolve(path);

  Future<Map<String, String>> _headers() async {
    final token = await _tokenProvider.getBearerToken();
    if (token == null || token.isEmpty) {
      throw const AuraApiException(
        message: 'Missing Firebase bearer token or development override token.',
      );
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static String _decodeErrorMessage(http.Response response) {
    if (response.body.isEmpty) {
      return 'Request failed without an error body.';
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['error'] is String) {
        return decoded['error'] as String;
      }
    } catch (_) {
      return response.body;
    }

    return response.body;
  }

  static Map<String, dynamic> _decodeMap(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw const AuraApiException(message: 'API response was not a JSON object.');
  }

  Future<void> syncLogs(List<StudyLog> logs) async {
    if (logs.isEmpty) {
      return;
    }

    final response = await _client.post(
      _uri('/v1/sync'),
      headers: await _headers(),
      body: jsonEncode({
        'study_logs': logs.map((log) => log.toSyncJson()).toList(),
      }),
    );

    if (response.statusCode != 200) {
      throw AuraApiException(
        message: _decodeErrorMessage(response),
        statusCode: response.statusCode,
      );
    }
  }

  Future<List<FeedSession>> fetchFeed() async {
    final response = await _client.get(
      _uri('/v1/feed'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw AuraApiException(
        message: _decodeErrorMessage(response),
        statusCode: response.statusCode,
      );
    }

    final payload = _decodeMap(response);
    final list = payload['data'];

    if (list is! List<dynamic>) {
      throw const AuraApiException(
        message: 'Feed response did not include a data list.',
      );
    }

    return list
        .whereType<Map<String, dynamic>>()
        .map(FeedSession.fromJson)
        .toList();
  }

  Future<ProfileAggregate> fetchProfile(String uid) async {
    final response = await _client.get(
      _uri('/v1/profile/$uid'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw AuraApiException(
        message: _decodeErrorMessage(response),
        statusCode: response.statusCode,
      );
    }

    final payload = _decodeMap(response);
    return ProfileAggregate.fromJson(payload);
  }

  Future<void> follow(String targetUid) async {
    final response = await _client.post(
      _uri('/v1/follow'),
      headers: await _headers(),
      body: jsonEncode({'target_uid': targetUid}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw AuraApiException(
        message: _decodeErrorMessage(response),
        statusCode: response.statusCode,
      );
    }
  }
}
