import 'dart:developer';

import 'package:dulcetdash/components/Helpers/SecureStorageService.dart';
import 'package:http/http.dart' as http;

class SuperHttp extends http.BaseClient {
  final http.Client _inner = http.Client();
  final SecureStorageService secureStorage = SecureStorageService();

  // Singleton instance
  static final SuperHttp _instance = SuperHttp._internal();

  // Factory constructor
  factory SuperHttp() {
    return _instance;
  }

  // Internal constructor
  SuperHttp._internal();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    String? token = await secureStorage.getValue('sessionToken');
    String? permaToken = await secureStorage.getValue('permaToken');

    if (token != null) {
      request.headers['authorization'] = 'Bearer $token';
    }

    if (permaToken != null) {
      request.headers['x-perma-token'] = permaToken;
    }

    final response = await _inner.send(request);

    String? sessionToken = response.headers['x-session-token'];
    String? pToken = response.headers['x-perma-token'];

    if (sessionToken != null) {
      await secureStorage.storeValue('sessionToken', sessionToken);
    }

    if (pToken != null) {
      await secureStorage.storeValue('permaToken', pToken);
    }

    return response;
  }

  // Optional: Create a method to close the client if needed
  void closeClient() {
    _inner.close();
  }
}
