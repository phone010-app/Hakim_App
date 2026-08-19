import 'package:flutter/material.dart';
import '../services/pin_service.dart';
import '../services/sheets_service.dart';

/// شاشة الإعدادات: ربط Google Sheets + إدارة رمز PIN
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _urlCtrl = TextEditingController();
  bool _loading = true;
  bool _savingUrl = false;

  @override
  void initState() {
    super.initState();
    _loadUrl();
  }

  Future<void> _loadUrl() async {
    final url = await SheetsService.instance.getScriptUrl();
    setState(() {
      _urlCtrl.text = url ?? '';
      _loading = false;
    });
  }

  Future<void> _saveUrl() async {
    setState(() => _savingUrl = true);
    await SheetsService.instance.setScriptUrl(_urlCtrl.text.trim());
    setState(() => _savingUrl = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ رابط Google Sheets ✅')),
    );
  }

  Future<void> _changePin() async {
    await PinService.instance.clearPin();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم مسح الرمز، سيُطلب منك إنشاء رمز جديد عند إعادة فتح التطبيق')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.cloud_sync_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('ربط Google Sheets', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'الصق هنا رابط Web App الناتج من نشر Google Apps Script '
                          '(انظر ملف README لطريقة الإعداد الكاملة).',
                          style: TextStyle(fontSize: 12.5, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _urlCtrl,
                          decoration: const InputDecoration(
                            labelText: 'رابط Web App',
                            hintText: 'https://script.google.com/macros/s/.../exec',
                            prefixIcon: Icon(Icons.link),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _savingUrl ? null : _saveUrl,
                          icon: const Icon(Icons.save_outlined),
                          label: Text(_savingUrl ? 'جارٍ الحفظ...' : 'حفظ الرابط'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.lock_outline, size: 18),
                            SizedBox(width: 8),
                            Text('حماية البيانات (PIN)', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'يمكنك إعادة تعيين رمز الدخول؛ سيُطلب منك إنشاء رمز جديد في المرة القادمة.',
                          style: TextStyle(fontSize: 12.5, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _changePin,
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة تعيين رمز PIN'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
