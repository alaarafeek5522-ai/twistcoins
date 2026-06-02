import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  Map<String, String>? headers;
  int balance = 0;
  bool loading = false;
  String? error;

  Future<bool> sendCode(String phone) async {
    loading = true; error = null; notifyListeners();
    final ok = await ApiService.sendCode(phone);
    loading = false; notifyListeners();
    return ok;
  }

  Future<bool> verify(String phone, String code) async {
    loading = true; error = null; notifyListeners();
    final data = await ApiService.verifyCode(phone, code);
    if (data == null || data['token'] == null) {
      error = 'فشل التحقق'; loading = false; notifyListeners();
      return false;
    }
    headers = ApiService.buildAuthHeaders(data);
    balance = await ApiService.getBalance(headers!);
    loading = false; notifyListeners();
    return true;
  }

  Future<void> refreshBalance() async {
    if (headers == null) return;
    balance = await ApiService.getBalance(headers!);
    notifyListeners();
  }

  Future<int> doTasks() async {
    if (headers == null) return 0;
    loading = true; notifyListeners();
    final done = await ApiService.doTasks(headers!);
    balance = await ApiService.getBalance(headers!);
    loading = false; notifyListeners();
    return done;
  }

  Future<bool> redeem(String pkg) async {
    if (headers == null) return false;
    loading = true; notifyListeners();
    final ok = await ApiService.redeem(headers!, pkg);
    if (ok) balance = await ApiService.getBalance(headers!);
    loading = false; notifyListeners();
    return ok;
  }
}
