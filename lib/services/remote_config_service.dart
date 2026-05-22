import 'package:http/http.dart' as http;
import 'dart:convert';

class RemoteConfig {
  static const String _url =
      'https://raw.githubusercontent.com/alaarafeek5522-ai/twistcoins/master/assets/config.json';

  static Future<Map<String, dynamic>> fetch() async {
    try {
      final res = await http.get(Uri.parse(_url)).timeout(
            const Duration(seconds: 6),
          );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (_) {}
    return {'status': 'active'};
  }
}
