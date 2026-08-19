/// تقرير غلق أسبوعي مؤرشف
class WeeklyReport {
  int? id;
  int weekNumber;
  DateTime startDate;
  DateTime endDate;
  double totalCollected; // إجمالي المبالغ المقبوضة فعلياً
  double myProfitCollected; // صافي فائدتي المقبوضة
  double partnerProfitCollected; // صافي فائدة الشريك المقبوضة
  double totalCustomerDebtRemaining; // مجموع الكريدي المتبقي عند الزبائن
  double totalSupplierDebtRemaining; // مجموع الديون التي علينا للموردين
  int ordersCount; // عدد العمليات المغلقة هذا الأسبوع
  DateTime closedAt;

  WeeklyReport({
    this.id,
    required this.weekNumber,
    required this.startDate,
    required this.endDate,
    required this.totalCollected,
    required this.myProfitCollected,
    required this.partnerProfitCollected,
    required this.totalCustomerDebtRemaining,
    required this.totalSupplierDebtRemaining,
    required this.ordersCount,
    DateTime? closedAt,
  }) : closedAt = closedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weekNumber': weekNumber,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalCollected': totalCollected,
      'myProfitCollected': myProfitCollected,
      'partnerProfitCollected': partnerProfitCollected,
      'totalCustomerDebtRemaining': totalCustomerDebtRemaining,
      'totalSupplierDebtRemaining': totalSupplierDebtRemaining,
      'ordersCount': ordersCount,
      'closedAt': closedAt.toIso8601String(),
    };
  }

  factory WeeklyReport.fromMap(Map<String, dynamic> map) {
    return WeeklyReport(
      id: map['id'] as int?,
      weekNumber: map['weekNumber'] as int,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      totalCollected: (map['totalCollected'] as num).toDouble(),
      myProfitCollected: (map['myProfitCollected'] as num).toDouble(),
      partnerProfitCollected: (map['partnerProfitCollected'] as num).toDouble(),
      totalCustomerDebtRemaining:
          (map['totalCustomerDebtRemaining'] as num).toDouble(),
      totalSupplierDebtRemaining:
          (map['totalSupplierDebtRemaining'] as num).toDouble(),
      ordersCount: map['ordersCount'] as int,
      closedAt: DateTime.parse(map['closedAt'] as String),
    );
  }

  Map<String, dynamic> toSheetJson() {
    return {
      'type': 'weekly_report',
      'weekNumber': weekNumber,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalCollected': totalCollected,
      'myProfitCollected': myProfitCollected,
      'partnerProfitCollected': partnerProfitCollected,
      'totalCustomerDebtRemaining': totalCustomerDebtRemaining,
      'totalSupplierDebtRemaining': totalSupplierDebtRemaining,
      'ordersCount': ordersCount,
      'closedAt': closedAt.toIso8601String(),
    };
  }
}
