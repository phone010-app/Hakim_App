import 'package:flutter/material.dart';
import '../models/repair_order.dart';

class StatusInfo {
  final String label;
  final Color color;
  final IconData icon;
  const StatusInfo(this.label, this.color, this.icon);
}

StatusInfo statusInfoOf(String status) {
  switch (status) {
    case OrderStatus.pending:
      return const StatusInfo('قيد التصليح', Color(0xFFEF6C00), Icons.build_circle);
    case OrderStatus.ready:
      return const StatusInfo(
          'بانتظار الزبون', Color(0xFF1976D2), Icons.check_circle);
    case OrderStatus.delivered:
      return const StatusInfo(
          'تم التسليم والقبض', Color(0xFF2E7D32), Icons.verified);
    default:
      return const StatusInfo('غير معروف', Colors.grey, Icons.help);
  }
}

/// شارة صغيرة ملونة تعرض حالة طلب الصيانة الحالية
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final info = statusInfoOf(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: info.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(info.icon, size: 14, color: info.color),
          const SizedBox(width: 4),
          Text(
            info.label,
            style: TextStyle(
              color: info.color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
