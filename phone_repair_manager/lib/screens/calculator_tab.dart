import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/repair_order.dart';
import '../providers/app_state.dart';
import '../utils/formatters.dart';
import '../widgets/labeled_text_field.dart';
import '../widgets/stat_tile.dart';

/// الواجهة الأولى: إدخال بيانات عملية صيانة، وحساب الأرباح والعربون تلقائياً
class CalculatorTab extends StatefulWidget {
  const CalculatorTab({super.key});

  @override
  State<CalculatorTab> createState() => _CalculatorTabState();
}

class _CalculatorTabState extends State<CalculatorTab> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _partCtrl = TextEditingController();
  final _purchaseCtrl = TextEditingController();
  final _sellingCtrl = TextEditingController();
  final _depositCtrl = TextEditingController();

  double get _purchase => double.tryParse(_purchaseCtrl.text) ?? 0;
  double get _selling => double.tryParse(_sellingCtrl.text) ?? 0;
  double get _deposit => double.tryParse(_depositCtrl.text) ?? 0;

  double get _remaining => _selling - _deposit;
  double get _totalProfit => _selling - _purchase;
  double get _myProfit => _totalProfit / 2;
  double get _partnerProfit => _totalProfit / 2;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _partCtrl.dispose();
    _purchaseCtrl.dispose();
    _sellingCtrl.dispose();
    _depositCtrl.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _nameCtrl.text.trim().isNotEmpty &&
      _partCtrl.text.trim().isNotEmpty &&
      _selling > 0;

  Future<void> _save() async {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال اسم الزبون والقطعة وسعر البيع على الأقل')),
      );
      return;
    }

    final order = RepairOrder(
      customerName: _nameCtrl.text.trim(),
      customerPhone: _phoneCtrl.text.trim(),
      partName: _partCtrl.text.trim(),
      purchasePrice: _purchase,
      sellingPrice: _selling,
      deposit: _deposit,
    );

    await context.read<AppState>().addOrder(order);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ العملية بنجاح ✅ (قيد الانتظار في واجهة الطلبات)'),
      ),
    );

    setState(() {
      _nameCtrl.clear();
      _phoneCtrl.clear();
      _partCtrl.clear();
      _purchaseCtrl.clear();
      _sellingCtrl.clear();
      _depositCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حاسبة الصيانة والأرباح')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionCard(
            title: 'بيانات الزبون',
            icon: Icons.person_outline,
            children: [
              LabeledTextField(
                label: 'اسم الزبون',
                controller: _nameCtrl,
                icon: Icons.person,
                required: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              LabeledTextField(
                label: 'رقم الهاتف',
                controller: _phoneCtrl,
                icon: Icons.phone,
                isNumber: true,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _sectionCard(
            title: 'بيانات القطعة والأسعار',
            icon: Icons.build_outlined,
            children: [
              LabeledTextField(
                label: 'اسم قطعة الغيار / نوع الهاتف',
                controller: _partCtrl,
                icon: Icons.smartphone,
                required: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              LabeledTextField(
                label: 'سعر شراء القطعة',
                controller: _purchaseCtrl,
                icon: Icons.shopping_cart_outlined,
                isNumber: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              LabeledTextField(
                label: 'سعر البيع النهائي المتفق عليه',
                controller: _sellingCtrl,
                icon: Icons.sell_outlined,
                isNumber: true,
                required: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              LabeledTextField(
                label: 'المبلغ المدفوع مسبقاً (العربون)',
                controller: _depositCtrl,
                icon: Icons.payments_outlined,
                isNumber: true,
                hint: '0 إذا لم يدفع شيء',
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _sectionCard(
            title: 'النتائج التلقائية',
            icon: Icons.calculate_outlined,
            children: [
              StatTile(
                label: 'المبلغ المتبقي على الزبون',
                value: formatMoney(_remaining),
                color: const Color(0xFFD84315),
                icon: Icons.hourglass_bottom,
              ),
              const SizedBox(height: 10),
              StatTile(
                label: 'صافي الفائدة الإجمالية المتوقعة',
                value: formatMoney(_totalProfit),
                color: const Color(0xFF1565C0),
                icon: Icons.trending_up,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      label: 'فائدتي (50%)',
                      value: formatMoney(_myProfit),
                      color: const Color(0xFF2E7D32),
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatTile(
                      label: 'فائدة الشريك (50%)',
                      value: formatMoney(_partnerProfit),
                      color: const Color(0xFF6A1B9A),
                      icon: Icons.handshake_outlined,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            label: const Text('حفظ العملية'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}
