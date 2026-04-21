import 'dart:convert';

import 'package:http/http.dart' as http;

import 'app_config.dart';

class ApiResult {
  ApiResult({
    required this.statusCode,
    required this.ok,
    required this.data,
    required this.message,
    this.scaffolded = false,
  });

  final int statusCode;
  final bool ok;
  final dynamic data;
  final String message;
  final bool scaffolded;
}

class ApiClient {
  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;

  Uri _uri(String path) => Uri.parse('${AppConfig.baseUrl}$path');

  Future<ApiResult> getHealth() => _request('GET', AppConfig.healthPath);

  Future<ApiResult> login(String email, String password) => _request(
        'POST',
        AppConfig.authLoginPath,
        body: {'email': email, 'password': password},
      );

  Future<ApiResult> loginWithOtp({
    required String email,
    required String password,
    required String otp,
  }) =>
      _request(
        'POST',
        AppConfig.authLoginPath,
        body: {'email': email, 'password': password, 'otp': otp},
      );

  Future<ApiResult> loginWithGoogle({required String idToken}) => _request(
        'POST',
        AppConfig.authLoginPath,
        body: {'provider': 'google', 'id_token': idToken},
      );

  Future<ApiResult> register(String name, String email, String password) => _request(
        'POST',
        AppConfig.authRegisterPath,
        body: {'name': name, 'email': email, 'password': password},
      );

  Future<ApiResult> getProducts({String? token}) =>
      _request('GET', AppConfig.productsPath, token: token);

  Future<ApiResult> getCategories({String? token}) =>
      _request('GET', AppConfig.categoriesPath, token: token);

  Future<ApiResult> getCart({String? token}) =>
      _request('GET', AppConfig.cartPath, token: token);

  Future<ApiResult> addToCart({required int productId, String? token}) => _request(
        'POST',
        AppConfig.cartAddPath,
        token: token,
        body: {'product_id': productId, 'quantity': 1},
      );

  Future<ApiResult> getOrders({String? token}) =>
      _request('GET', AppConfig.ordersPath, token: token);

  Future<ApiResult> createOrder({String? token}) =>
      _request('POST', AppConfig.ordersPath, token: token);

  Future<ApiResult> getProfile({String? token}) =>
      _request('GET', AppConfig.profilePath, token: token);

  Future<ApiResult> _request(
    String method,
    String path, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    try {
      final headers = <String, String>{'Accept': 'application/json'};
      if (body != null) {
        headers['Content-Type'] = 'application/json';
      }
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      late final http.Response response;
      if (method == 'GET') {
        response = await _http.get(_uri(path), headers: headers);
      } else if (method == 'POST') {
        response = await _http.post(
          _uri(path),
          headers: headers,
          body: jsonEncode(body ?? <String, dynamic>{}),
        );
      } else {
        throw UnsupportedError('Method $method is not supported.');
      }

      final decoded = _decodeBody(response.body);
      final message = _extractMessage(decoded, fallback: 'Request finished.');
      final scaffolded = decoded is Map<String, dynamic> &&
          (decoded['message'] == 'Endpoint scaffolded but not implemented yet.');

      return ApiResult(
        statusCode: response.statusCode,
        ok: response.statusCode >= 200 && response.statusCode < 300,
        data: decoded,
        message: message,
        scaffolded: scaffolded,
      );
    } catch (e) {
      return ApiResult(
        statusCode: 0,
        ok: false,
        data: null,
        message: 'Network error: $e',
      );
    }
  }

  dynamic _decodeBody(String body) {
    if (body.isEmpty) {
      return null;
    }
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  String _extractMessage(dynamic decoded, {required String fallback}) {
    if (decoded is Map<String, dynamic>) {
      if (decoded['message'] != null) {
        return '${decoded['message']}';
      }
      if (decoded['status'] != null) {
        return 'Status: ${decoded['status']}';
      }
    }
    return fallback;
  }
}
