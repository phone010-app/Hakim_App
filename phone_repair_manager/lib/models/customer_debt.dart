/// دين مضاف يدوياً على زبون (غير ناتج عن عملية صيانة)
class CustomerDebt {
  int? id;
  String customerName;
  String customerPhone;
  double amount;
  String note;
  bool isPaid;
  DateTime createdAt;

  CustomerDebt({
    this.id,
    required this.customerName,
    this.customerPhone = '',
    required this.amount,
    this.note = '',
    this.isPaid = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'amount': amount,
      'note': note,
      'isPaid': isPaid ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CustomerDebt.fromMap(Map<String, dynamic> map) {
    return CustomerDebt(
      id: map['id'] as int?,
      customerName: map['customerName'] as String,
      customerPhone: map['customerPhone'] as String? ?? '',
      amount: (map['amount'] as num).toDouble(),
      note: map['note'] as String? ?? '',
      isPaid: (map['isPaid'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toSheetJson() {
    return {
      'type': 'customer_debt',
      'id': id,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'amount': amount,
      'note': note,
      'isPaid': isPaid,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
