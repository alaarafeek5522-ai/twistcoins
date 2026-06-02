import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String _base = 'https://api.twistmena.com/music';

  static Map<String, String> _headers({String? token, String? accessToken, Map<String, String>? extra}) {
    final r = Random();
    final ip = '102.62.${r.nextInt(255)}.${r.nextInt(255)}';
    final h = {
      'user-agent': 'Dart/3.7 (dart:io)',
      'app_version': '10.10.45',
      'appversion': '10.10.45',
      'channel': 'mobileapp',
      'content-type': 'application/json',
      'platform': 'android',
      'accept': 'application/json',
      'accept-language': 'ar',
      'host': 'api.twistmena.com',
      'device_id': 'AP3A.240905.015.${r.nextInt(900) + 100}',
      'X-Forwarded-For': ip,
      'X-Real-IP': ip,
      'customer-ip': ip,
    };
    if (token != null) h['authorization'] = 'Bearer $token';
    if (accessToken != null) h['access-token'] = accessToken;
    if (extra != null) h.addAll(extra);
    return h;
  }

  static Future<bool> sendCode(String phone) async {
    if (phone.startsWith('01')) phone = '2$phone';
    final r = await http.post(
      Uri.parse('$_base/Dlogin/sendCode'),
      headers: _headers(),
      body: jsonEncode({'dial': phone}),
    );
    return r.statusCode == 200;
  }

  static Future<Map<String, dynamic>?> verifyCode(String phone, String code) async {
    if (phone.startsWith('01')) phone = '2$phone';
    final r = await http.post(
      Uri.parse('$_base/Dlogin/verify'),
      headers: _headers(),
      body: jsonEncode({'dial': phone, 'verifyCode': code}),
    );
    if (r.statusCode != 200) return null;
    return jsonDecode(r.body);
  }

  static Future<int> getBalance(Map<String, String> headers) async {
    final r = await http.get(
      Uri.parse('$_base/user/loyalty/balance/details'),
      headers: headers,
    );
    if (r.statusCode == 200) {
      return jsonDecode(r.body)['balance'] ?? 0;
    }
    return 0;
  }

  static Future<List<dynamic>> getTasks(Map<String, String> headers) async {
    final r = await http.get(
      Uri.parse('$_base/user/loyalty/achievements/v2'),
      headers: headers,
    );
    if (r.statusCode != 200) return [];
    final data = jsonDecode(r.body);
    List<dynamic> tasks = [];
    for (var cat in data['badges'] ?? []) {
      for (var task in cat['badges'] ?? []) {
        if (task['rewarded'] != true) tasks.add(task);
      }
    }
    return tasks;
  }

  static Future<int> doTasks(Map<String, String> headers) async {
    final tasks = await getTasks(headers);
    int done = 0;
    for (var task in tasks) {
      try {
        final r = await http.post(
          Uri.parse('$_base/loyalty/action/${task['id']}'),
          headers: headers,
        ).timeout(const Duration(seconds: 5));
        if (r.statusCode == 200) done++;
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (_) {}
    }
    return done;
  }

  static Future<bool> redeem(Map<String, String> headers, String pkg) async {
    final r = await http.post(
      Uri.parse('$_base/loyalty/redeem/$pkg'),
      headers: headers,
    );
    return r.statusCode == 200;
  }

  static Map<String, String> buildAuthHeaders(Map<String, dynamic> data) {
    final r = Random();
    final ip = '102.62.${r.nextInt(255)}.${r.nextInt(255)}';
    return {
      'user-agent': 'Dart/3.7 (dart:io)',
      'app_version': '10.10.45',
      'appversion': '10.10.45',
      'channel': 'mobileapp',
      'content-type': 'application/json',
      'platform': 'android',
      'accept': 'application/json',
      'accept-language': 'ar',
      'host': 'api.twistmena.com',
      'device_id': 'AP3A.240905.015.${r.nextInt(900) + 100}',
      'X-Forwarded-For': ip,
      'X-Real-IP': ip,
      'customer-ip': ip,
      'authorization': 'Bearer ${data['token'] ?? ''}',
      'access-token': data['accessToken'] ?? '',
      'tgdeviceid': data['tgdeviceid'] ?? '22913102',
      'device_token': data['deviceToken'] ?? '',
      'tg-token': data['tgToken'] ?? '',
      'tg-refresh-token': data['tgRefreshToken'] ?? '',
    };
  }
}
