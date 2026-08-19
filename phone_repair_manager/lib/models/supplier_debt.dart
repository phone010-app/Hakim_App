/// دين نحن مدينون به لمورد (اشترينا منه قطع كريدي)
class SupplierDebt {
  int? id;
  String supplierName;
  double amount;
  String note;
  bool isPaid;
  DateTime createdAt;

  SupplierDebt({
    this.id,
    required this.supplierName,
    required this.amount,
    this.note = '',
    this.isPaid = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplierName': supplierName,
      'amount': amount,
      'note': note,
      'isPaid': isPaid ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SupplierDebt.fromMap(Map<String, dynamic> map) {
    return SupplierDebt(
      id: map['id'] as int?,
      supplierName: map['supplierName'] as String,
      amount: (map['amount'] as num).toDouble(),
      note: map['note'] as String? ?? '',
      isPaid: (map['isPaid'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toSheetJson() {
    return {
      'type': 'supplier_debt',
      'id': id,
      'supplierName': supplierName,
      'amount': amount,
      'note': note,
      'isPaid': isPaid,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
