import 'package:flutter/foundation.dart';
import 'dart:io';

class ApiConfig {
  static const String _envBase = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_envBase.isNotEmpty) return _envBase;

    if (kIsWeb) {
      return 'http://localhost:4000';
    }

    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:4000';
      }
    } catch (_) {
      // ignore: avoid_catches_without_on_clauses
    }

    return 'http://localhost:4000';
  }

  static String endpoint(String path) {
    if (path.startsWith('/')) {
      return '$baseUrl$path';
    }
    return '$baseUrl/$path';
  }
}