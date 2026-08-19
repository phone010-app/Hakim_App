import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/repair_order.dart';
import '../models/weekly_report.dart';
import '../providers/app_state.dart';
import '../utils/formatters.dart';
import '../widgets/status_badge.dart';

/// الواجهة الثالثة: قائمة طلبات الصيانة النشطة + زر الغلق الأسبوعي
class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  Future<void> _confirmAndCloseWeek(BuildContext context) async {
    final state = context.read<AppState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('غلق جلسة الأعمال الأسبوعية'),
        content: const Text(
          'سيتم احتساب كل الطلبات المُسلَّمة هذا الأسبوع ضمن التقرير، ثم أرشفتها، '
          'وتصفير عدادات الأسبوع الحالي للبدء من جديد. هل تريد المتابعة؟',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('تأكيد الغلق')),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final report = await state.closeCurrentWeek();

    if (!context.mounted) return;
    _showReportDialog(context, report);
  }

  void _showReportDialog(BuildContext context, WeeklyReport report) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.fact_check_outlined, color: Colors.green),
            SizedBox(width: 8),
            Text('تقرير الغلق الأسبوعي'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الأسبوع رقم ${report.weekNumber}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text('${formatDate(report.startDate)} → ${formatDate(report.endDate)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const Divider(height: 24),
              _reportRow('عدد العمليات المغلقة', '${report.ordersCount}'),
              _reportRow('إجمالي المبالغ المقبوضة', formatMoney(report.totalCollected)),
              _reportRow('صافي فائدتي المقبوضة', formatMoney(report.myProfitCollected)),
              _reportRow('صافي فائدة الشريك المقبوضة', formatMoney(report.partnerProfitCollected)),
              const Divider(height: 24),
              _reportRow('الكريدي المتبقي عند الزبائن', formatMoney(report.totalCustomerDebtRemaining),
                  color: Colors.green),
              _reportRow('الديون المتبقية للموردين', formatMoney(report.totalSupplierDebtRemaining),
                  color: Colors.red),
              const SizedBox(height: 8),
              const Text('تم حفظ التقرير في الأرشيف وإرساله إلى Google Sheets ✅',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('حسناً')),
        ],
      ),
    );
  }

  Widget _reportRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final orders = state.orders;
        return Scaffold(
          appBar: AppBar(
            title: Text('إدارة الطلبات · الأسبوع ${state.currentWeekNumber}'),
          ),
          body: Column(
            children: [
              Expanded(
                child: orders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 10),
                            Text('لا توجد طلبات في الأسبوع الحالي',
                                style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: orders.length,
                        itemBuilder: (ctx, i) => _OrderCard(order: orders[i]),
                      ),
              ),
              _CloseWeekButton(onTap: () => _confirmAndCloseWeek(context)),
            ],
          ),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final RepairOrder order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(order.customerName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 4),
            Text('${order.partName} · ${formatDate(order.createdAt)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12.5)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                _miniInfo('سعر البيع', formatMoney(order.sellingPrice)),
                _miniInfo('المتبقي', formatMoney(order.remaining),
                    color: order.remaining > 0 ? Colors.red : Colors.green),
                _miniInfo('فائدتي', formatMoney(order.myProfit), color: Colors.green[700]),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _statusButton(
                    context,
                    label: 'قيد التصليح',
                    active: order.status == OrderStatus.pending,
                    color: const Color(0xFFEF6C00),
                    onTap: () => context.read<AppState>().updateOrderStatus(order, OrderStatus.pending),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _statusButton(
                    context,
                    label: 'بانتظار الزبون',
                    active: order.status == OrderStatus.ready,
                    color: const Color(0xFF1976D2),
                    onTap: () => context.read<AppState>().updateOrderStatus(order, OrderStatus.ready),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _statusButton(
                    context,
                    label: 'تم التسليم والقبض',
                    active: order.status == OrderStatus.delivered,
                    color: const Color(0xFF2E7D32),
                    onTap: () => _confirmDelivery(context, order),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelivery(BuildContext context, RepairOrder order) async {
    if (order.status == OrderStatus.delivered) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد التسليم والقبض'),
        content: Text(
          'هل تم تسليم الجهاز لـ "${order.customerName}" وقبض كامل المبلغ '
          '(${formatMoney(order.remaining)}) منه؟\nسيصبح المبلغ المتبقي صفراً وتدخل الأرباح في صندوق الأسبوع.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('نعم، تم القبض')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AppState>().updateOrderStatus(order, OrderStatus.delivered);
    }
  }

  Widget _miniInfo(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10.5, color: Colors.grey[500])),
        Text(value, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _statusButton(
    BuildContext context, {
    required String label,
    required bool active,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 40,
      child: active
          ? FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                textStyle: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
              ),
              child: Text(label, textAlign: TextAlign.center, maxLines: 2),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color.withOpacity(0.4)),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                textStyle: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
              ),
              child: Text(label, textAlign: TextAlign.center, maxLines: 2),
            ),
    );
  }
}

class _CloseWeekButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CloseWeekButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -3)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: FilledButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.lock_clock_outlined),
          label: const Text('غلق جلسة الأعمال الأسبوعية'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0B6E4F),
            minimumSize: const Size.fromHeight(52),
          ),
        ),
      ),
    );
  }
}
