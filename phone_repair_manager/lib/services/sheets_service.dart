import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة الاتصال بـ Google Apps Script Web App لإرسال البيانات
/// إلى Google Sheets. يتم تخزين رابط الـ Web App في shared_preferences
/// حتى يستطيع صاحب المحل تغييره من شاشة الإعدادات دون تعديل الكود.
class SheetsService {
  SheetsService._internal();
  static final SheetsService instance = SheetsService._internal();

  static const _prefKey = 'google_script_url';

  Future<String?> getScriptUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKey);
  }

  Future<void> setScriptUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, url.trim());
  }

  /// يرسل أي JSON إلى الـ Web App. يرجع true عند النجاح.
  /// لا يوقف التطبيق أبداً عند الفشل (لا إنترنت مثلاً) — البيانات
  /// محفوظة أصلاً محلياً، والإرسال لجوجل شيت مجرد نسخة احتياطية.
  Future<bool> sendData(Map<String, dynamic> payload) async {
    final url = await getScriptUrl();
    if (url == null || url.isEmpty) {
      return false;
    }
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
