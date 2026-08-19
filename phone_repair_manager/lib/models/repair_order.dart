/// حالات طلب الصيانة
class OrderStatus {
  static const String pending = 'pending'; // قيد التصليح
  static const String ready = 'ready'; // تم التصليح - بانتظار الزبون
  static const String delivered = 'delivered'; // تم التسليم وقبض الثمن كاملاً
}

/// يمثل عملية صيانة واحدة (زبون + قطعة + أسعار + حالة)
class RepairOrder {
  int? id;
  String customerName;
  String customerPhone;
  String partName; // اسم قطعة الغيار / نوع الهاتف
  double purchasePrice; // سعر شراء القطعة
  double sellingPrice; // سعر البيع المتفق عليه
  double deposit; // العربون المدفوع مسبقاً
  String status;
  DateTime createdAt;
  DateTime? deliveredAt;
  int? archivedWeekId; // null = ضمن الأسبوع الحالي (غير مؤرشف بعد)
  bool syncedToSheet; // هل تم رفعها لجوجل شيت

  RepairOrder({
    this.id,
    required this.customerName,
    required this.customerPhone,
    required this.partName,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.deposit,
    this.status = OrderStatus.pending,
    DateTime? createdAt,
    this.deliveredAt,
    this.archivedWeekId,
    this.syncedToSheet = false,
  }) : createdAt = createdAt ?? DateTime.now();

  /// المبلغ المتبقي على الزبون. يصبح صفراً بمجرد التسليم والقبض الكامل.
  double get remaining =>
      status == OrderStatus.delivered ? 0 : (sellingPrice - deposit);

  /// صافي الفائدة الإجمالية المتوقعة
  double get totalProfit => sellingPrice - purchasePrice;

  /// فائدتي الخاصة (50%)
  double get myProfit => totalProfit / 2;

  /// فائدة صاحب المحل / الشريك (50%)
  double get partnerProfit => totalProfit / 2;

  RepairOrder copyWith({
    int? id,
    String? customerName,
    String? customerPhone,
    String? partName,
    double? purchasePrice,
    double? sellingPrice,
    double? deposit,
    String? status,
    DateTime? createdAt,
    DateTime? deliveredAt,
    int? archivedWeekId,
    bool? syncedToSheet,
  }) {
    return RepairOrder(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      partName: partName ?? this.partName,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      deposit: deposit ?? this.deposit,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      archivedWeekId: archivedWeekId ?? this.archivedWeekId,
      syncedToSheet: syncedToSheet ?? this.syncedToSheet,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'partName': partName,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'deposit': deposit,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'archivedWeekId': archivedWeekId,
      'syncedToSheet': syncedToSheet ? 1 : 0,
    };
  }

  factory RepairOrder.fromMap(Map<String, dynamic> map) {
    return RepairOrder(
      id: map['id'] as int?,
      customerName: map['customerName'] as String,
      customerPhone: map['customerPhone'] as String,
      partName: map['partName'] as String,
      purchasePrice: (map['purchasePrice'] as num).toDouble(),
      sellingPrice: (map['sellingPrice'] as num).toDouble(),
      deposit: (map['deposit'] as num).toDouble(),
      status: map['status'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      deliveredAt: map['deliveredAt'] != null
          ? DateTime.parse(map['deliveredAt'] as String)
          : null,
      archivedWeekId: map['archivedWeekId'] as int?,
      syncedToSheet: (map['syncedToSheet'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toSheetJson() {
    return {
      'type': 'operation',
      'id': id,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'partName': partName,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'deposit': deposit,
      'remaining': remaining,
      'totalProfit': totalProfit,
      'myProfit': myProfit,
      'partnerProfit': partnerProfit,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
