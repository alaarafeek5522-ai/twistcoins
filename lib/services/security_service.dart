import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class SecurityService {
  static String get _configUrl =>
      'https://gist.githubusercontent.com/alaarafeek5522-ai/c73988cb4b2b0ae8690cd1f598d440fa/raw/app_config.json?t=${DateTime.now().millisecondsSinceEpoch}';

  static const MethodChannel _channel = MethodChannel('com.alaa.twistcoins/security');

  static Future<Map<String, dynamic>?> fetchConfig() async {
    try {
      final r = await http.get(Uri.parse(_configUrl)).timeout(const Duration(seconds: 10));
      if (r.statusCode == 200) return jsonDecode(r.body);
    } catch (_) {}
    return null;
  }

  static Future<String?> getSignature() async {
    try {
      final sig = await _channel.invokeMethod<String>('getSignature');
      return sig;
    } catch (_) {
      return null;
    }
  }
}

enum SecurityStatus { ok, tampered, stopped, networkError }

class AppConfig {
  final bool updateEnabled;
  final bool forceUpdate;
  final String version;
  final String message;
  final String url;
  final bool active;
  final String stopMessage;
  final String signature;

  AppConfig({
    required this.updateEnabled,
    required this.forceUpdate,
    required this.version,
    required this.message,
    required this.url,
    required this.active,
    required this.stopMessage,
    required this.signature,
  });

  factory AppConfig.fromJson(Map<String, dynamic> j) => AppConfig(
        updateEnabled: j['update']['enabled'] ?? false,
        forceUpdate: j['update']['force'] ?? false,
        version: j['update']['version'] ?? '1.0.0',
        message: j['update']['message'] ?? '',
        url: j['update']['url'] ?? '',
        active: j['active'] ?? true,
        stopMessage: j['stop_message'] ?? 'تم إيقاف التطبيق',
        signature: j['signature'] ?? '',
      );
}
