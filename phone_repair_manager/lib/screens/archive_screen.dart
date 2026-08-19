import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/weekly_report.dart';
import '../providers/app_state.dart';
import '../utils/formatters.dart';

/// شاشة أرشيف تعرض كل التقارير الأسبوعية المُغلقة سابقاً
class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('أرشيف التقارير الأسبوعية')),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          final reports = state.weeklyReports;
          if (reports.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.archive_outlined, size: 52, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text('لا توجد تقارير مؤرشفة بعد', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text('ستظهر هنا كل أسبوع بعد الضغط على "غلق جلسة الأعمال الأسبوعية"',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (ctx, i) => _ReportCard(report: reports[i]),
          );
        },
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final WeeklyReport report;
  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF0B6E4F).withOpacity(0.12),
          child: Text('${report.weekNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B6E4F))),
        ),
        title: Text('الأسبوع رقم ${report.weekNumber}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${formatDate(report.startDate)} → ${formatDate(report.endDate)}'),
        trailing: Text(formatMoney(report.totalCollected),
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B6E4F))),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _row('عدد العمليات المغلقة', '${report.ordersCount}'),
                _row('إجمالي المبالغ المقبوضة', formatMoney(report.totalCollected)),
                _row('صافي فائدتي المقبوضة', formatMoney(report.myProfitCollected), color: Colors.green),
                _row('صافي فائدة الشريك', formatMoney(report.partnerProfitCollected), color: Colors.purple),
                const Divider(),
                _row('الكريدي المتبقي عند الزبائن', formatMoney(report.totalCustomerDebtRemaining),
                    color: Colors.teal),
                _row('الديون المتبقية للموردين', formatMoney(report.totalSupplierDebtRemaining),
                    color: Colors.red),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('أُرشف في: ${formatDateTime(report.closedAt)}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
        ],
      ),
    );
  }
}
