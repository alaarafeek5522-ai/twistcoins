import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String _base = 'https://test-api.twistmena.com';

  static Map<String, String> _headers({String? token, String? accessToken}) {
    final rng = Random();
    final fakeIp =
        '102.62.${rng.nextInt(254) + 1}.${rng.nextInt(254) + 1}';
    final h = {
      'user-agent': 'Dart/3.7 (dart:io)',
      'app_version': '10.10.45',
      'channel': 'mobileapp',
      'content-type': 'application/json',
      'accept-language': 'ar',
      'platform': 'android',
      'host': 'test-api.twistmena.com',
      'device_id': 'AP3A.240905.015.A2',
      'X-Forwarded-For': fakeIp,
    };
    if (token != null) {
      h['authorization'] = 'Bearer $token';
    }
    if (accessToken != null) {
      h['access-token'] = accessToken;
    }
    return h;
  }

  static Future<bool> sendOtp(String phone) async {
    final dial = phone.startsWith('01') ? '2$phone' : phone;
    final res = await http.post(
      Uri.parse('$_base/music/Dlogin/sendCode'),
      headers: _headers(),
      body: jsonEncode({'dial': dial}),
    );
    return res.statusCode == 200;
  }

  static Future<Map<String, dynamic>?> verifyOtp(
      String phone, String otp) async {
    final dial = phone.startsWith('01') ? '2$phone' : phone;
    final res = await http.post(
      Uri.parse('$_base/music/Dlogin/verify'),
      headers: _headers(),
      body: jsonEncode({
        'dial': dial,
        'verifyCode': otp,
        'socialServiceName': '',
        'socialServiceToken': '',
      }),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return null;
  }

  static Future<int> getBalance(String token, String accessToken) async {
    final res = await http.get(
      Uri.parse('$_base/music/user/loyalty/balance/details'),
      headers: _headers(token: token, accessToken: accessToken),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['balance'] ?? 0;
    }
    return 0;
  }

  static Future<List<Map<String, dynamic>>> getPendingTasks(
      String token, String accessToken) async {
    final res = await http.get(
      Uri.parse('$_base/music/user/loyalty/achievements/v2'),
      headers: _headers(token: token, accessToken: accessToken),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final badges = data['badges'] as List? ?? [];
      final day = badges
          .firstWhere(
            (c) => c['duration'] == 'DAY',
            orElse: () => {'badges': []},
          )['badges'] as List? ??
          [];
      return day
          .where((t) => t['rewarded'] == false)
          .map<Map<String, dynamic>>((t) => Map<String, dynamic>.from(t))
          .toList();
    }
    return [];
  }

  static Future<bool> executeTask(
      String tid, String token, String accessToken) async {
    late http.Response res;
    if (tid == 'LIKE_SONG') {
      res = await http.put(
        Uri.parse('$_base/music/favorite/like/192507534'),
        headers: _headers(token: token, accessToken: accessToken),
      );
    } else {
      res = await http.post(
        Uri.parse('$_base/music/loyalty/action/$tid'),
        headers: _headers(token: token, accessToken: accessToken),
      );
    }
    return res.statusCode == 200;
  }

  static Future<bool> redeem(
      String redeemId, String token, String accessToken) async {
    final res = await http.post(
      Uri.parse('$_base/music/loyalty/redeem/$redeemId'),
      headers: _headers(token: token, accessToken: accessToken),
    );
    return res.statusCode == 200;
  }
}
