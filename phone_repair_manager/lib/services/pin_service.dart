import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة إدارة رمز PIN لحماية بيانات المحل (يُخزَّن مُشفَّراً فقط، وليس نصاً صريحاً)
class PinService {
  PinService._internal();
  static final PinService instance = PinService._internal();

  static const _pinHashKey = 'pin_hash';

  String _hash(String pin) {
    return sha256.convert(utf8.encode(pin)).toString();
  }

  Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_pinHashKey);
  }

  Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinHashKey, _hash(pin));
  }

  Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_pinHashKey);
    if (saved == null) return false;
    return saved == _hash(pin);
  }

  Future<void> clearPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinHashKey);
  }
}
