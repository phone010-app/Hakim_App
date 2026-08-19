import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/customer_debt.dart';
import '../models/delivery_person.dart';
import '../models/supplier_debt.dart';
import '../providers/app_state.dart';
import '../utils/formatters.dart';
import '../widgets/labeled_text_field.dart';

/// الواجهة الثانية: قسم الديون (موردين + زبائن) وقسم أجر التوصيل
class DebtsTab extends StatelessWidget {
  const DebtsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الديون والتوصيل'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'يسالوني (موردون)'),
              Tab(text: 'نسالهم (زبائن)'),
              Tab(text: 'أجر التوصيل'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _SupplierDebtsView(),
            _CustomerDebtsView(),
            _DeliveryView(),
          ],
        ),
      ),
    );
  }
}

// ==================== ديون الموردين (يسالوني) ====================

class _SupplierDebtsView extends StatelessWidget {
  const _SupplierDebtsView();

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('إضافة دين لمورد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 14),
            LabeledTextField(label: 'اسم المورد', controller: nameCtrl, icon: Icons.store_outlined, required: true),
            const SizedBox(height: 12),
            LabeledTextField(label: 'المبلغ المستحق عليّ', controller: amountCtrl, icon: Icons.money_off, isNumber: true, required: true),
            const SizedBox(height: 12),
            LabeledTextField(label: 'ملاحظة (اختياري)', controller: noteCtrl, icon: Icons.note_outlined),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(amountCtrl.text) ?? 0;
                if (nameCtrl.text.trim().isEmpty || amount <= 0) return;
                context.read<AppState>().addSupplierDebt(SupplierDebt(
                      supplierName: nameCtrl.text.trim(),
                      amount: amount,
                      note: noteCtrl.text.trim(),
                    ));
                Navigator.pop(ctx);
              },
              child: const Text('حفظ الدين'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final debts = state.supplierDebts;
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('إضافة دين مورد'),
          ),
          body: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_upward, color: Color(0xFFC62828)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('إجمالي ما ندين به للموردين',
                          style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.w600)),
                    ),
                    Text(formatMoney(state.totalSupplierDebt),
                        style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
              Expanded(
                child: debts.isEmpty
                    ? const _EmptyState(text: 'لا توجد ديون على الموردين حالياً')
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: debts.length,
                        itemBuilder: (ctx, i) {
                          final d = debts[i];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: d.isPaid
                                    ? Colors.green.withOpacity(0.15)
                                    : Colors.red.withOpacity(0.15),
                                child: Icon(
                                  d.isPaid ? Icons.check : Icons.store,
                                  color: d.isPaid ? Colors.green : Colors.red,
                                  size: 20,
                                ),
                              ),
                              title: Text(d.supplierName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(d.note.isEmpty ? formatDate(d.createdAt) : '${d.note} · ${formatDate(d.createdAt)}'),
                              trailing: d.isPaid
                                  ? const Text('مدفوع', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(formatMoney(d.amount),
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                                        IconButton(
                                          icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                                          tooltip: 'تم السداد',
                                          onPressed: () => context.read<AppState>().markSupplierDebtPaid(d),
                                        ),
                                      ],
                                    ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 70),
            ],
          ),
        );
      },
    );
  }
}

// ==================== ديون الزبائن (نسالهم) ====================

class _CustomerDebtsView extends StatelessWidget {
  const _CustomerDebtsView();

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('إضافة دين يدوي على زبون', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 14),
            LabeledTextField(label: 'اسم الزبون', controller: nameCtrl, icon: Icons.person_outline, required: true),
            const SizedBox(height: 12),
            LabeledTextField(label: 'رقم الهاتف', controller: phoneCtrl, icon: Icons.phone, isNumber: true),
            const SizedBox(height: 12),
            LabeledTextField(label: 'المبلغ المستحق لي', controller: amountCtrl, icon: Icons.money, isNumber: true, required: true),
            const SizedBox(height: 12),
            LabeledTextField(label: 'ملاحظة (اختياري)', controller: noteCtrl, icon: Icons.note_outlined),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(amountCtrl.text) ?? 0;
                if (nameCtrl.text.trim().isEmpty || amount <= 0) return;
                context.read<AppState>().addCustomerDebt(CustomerDebt(
                      customerName: nameCtrl.text.trim(),
                      customerPhone: phoneCtrl.text.trim(),
                      amount: amount,
                      note: noteCtrl.text.trim(),
                    ));
                Navigator.pop(ctx);
              },
              child: const Text('حفظ الدين'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final items = state.combinedCustomerDebts;
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('إضافة دين يدوي'),
          ),
          body: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_downward, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('إجمالي الكريدي عند الزبائن',
                          style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.w600)),
                    ),
                    Text(formatMoney(state.totalCustomerDebt),
                        style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? const _EmptyState(text: 'لا توجد ديون على الزبائن حالياً')
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: items.length,
                        itemBuilder: (ctx, i) {
                          final item = items[i];
                          final isManual = item['source'] == 'manual';
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isManual
                                    ? Colors.blue.withOpacity(0.15)
                                    : Colors.orange.withOpacity(0.15),
                                child: Icon(
                                  isManual ? Icons.edit_note : Icons.build_outlined,
                                  color: isManual ? Colors.blue : Colors.orange,
                                  size: 20,
                                ),
                              ),
                              title: Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                isManual ? 'دين يدوي · ${item['note']}' : 'من عملية صيانة · ${item['note']}',
                              ),
                              trailing: isManual
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(formatMoney(item['amount'] as double),
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                        IconButton(
                                          icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                                          tooltip: 'تم التحصيل',
                                          onPressed: () => context
                                              .read<AppState>()
                                              .markCustomerDebtPaid(item['debt'] as CustomerDebt),
                                        ),
                                      ],
                                    )
                                  : Text(formatMoney(item['amount'] as double),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 70),
            ],
          ),
        );
      },
    );
  }
}

// ==================== أجر التوصيل ====================

class _DeliveryView extends StatelessWidget {
  const _DeliveryView();

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('إضافة أجر توصيل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 14),
            LabeledTextField(label: 'اسم رجل التوصيل', controller: nameCtrl, icon: Icons.delivery_dining, required: true),
            const SizedBox(height: 12),
            LabeledTextField(label: 'المبلغ المستحق له', controller: amountCtrl, icon: Icons.attach_money, isNumber: true, required: true),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(amountCtrl.text) ?? 0;
                if (nameCtrl.text.trim().isEmpty || amount <= 0) return;
                context.read<AppState>().addDeliveryPerson(DeliveryPerson(
                      name: nameCtrl.text.trim(),
                      amountDue: amount,
                    ));
                Navigator.pop(ctx);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final unpaid = state.deliveryPersons.where((d) => !d.isPaid).toList();
        final paid = state.deliveryPersons.where((d) => d.isPaid).toList();
        final totalDue = unpaid.fold<double>(0, (s, d) => s + d.amountDue);

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('إضافة أجر'),
          ),
          body: state.deliveryPersons.isEmpty
              ? const _EmptyState(text: 'لا توجد أجور توصيل مسجّلة')
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_shipping_outlined, color: Color(0xFFE65100)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text('إجمالي المستحق لعمال التوصيل',
                                style: TextStyle(color: Colors.orange[900], fontWeight: FontWeight.w600)),
                          ),
                          Text(formatMoney(totalDue),
                              style: TextStyle(color: Colors.orange[900], fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (unpaid.isNotEmpty) ...[
                      const Text('غير مدفوع', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...unpaid.map((d) => Card(
                            child: ListTile(
                              leading: const CircleAvatar(child: Icon(Icons.delivery_dining, size: 20)),
                              title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(formatDate(d.createdAt)),
                              trailing: Wrap(
                                spacing: 6,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(formatMoney(d.amountDue),
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                  FilledButton.tonal(
                                    onPressed: () => context.read<AppState>().markDeliveryPaid(d),
                                    child: const Text('تم الدفع'),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ],
                    if (paid.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text('مدفوع سابقاً', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 8),
                      ...paid.map((d) => Opacity(
                            opacity: 0.6,
                            child: Card(
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.green,
                                  child: Icon(Icons.check, color: Colors.white, size: 18),
                                ),
                                title: Text(d.name),
                                subtitle: Text(d.paidAt != null ? formatDate(d.paidAt!) : ''),
                                trailing: Text(formatMoney(d.amountDue)),
                              ),
                            ),
                          )),
                    ],
                  ],
                ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String text;
  const _EmptyState({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 10),
          Text(text, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
