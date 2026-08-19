/// سجل أجر مستحق لرجل توصيل
class DeliveryPerson {
  int? id;
  String name;
  double amountDue;
  bool isPaid;
  DateTime createdAt;
  DateTime? paidAt;

  DeliveryPerson({
    this.id,
    required this.name,
    required this.amountDue,
    this.isPaid = false,
    DateTime? createdAt,
    this.paidAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amountDue': amountDue,
      'isPaid': isPaid ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
    };
  }

  factory DeliveryPerson.fromMap(Map<String, dynamic> map) {
    return DeliveryPerson(
      id: map['id'] as int?,
      name: map['name'] as String,
      amountDue: (map['amountDue'] as num).toDouble(),
      isPaid: (map['isPaid'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      paidAt:
          map['paidAt'] != null ? DateTime.parse(map['paidAt'] as String) : null,
    );
  }

  Map<String, dynamic> toSheetJson() {
    return {
      'type': 'delivery_payment',
      'id': id,
      'name': name,
      'amountDue': amountDue,
      'isPaid': isPaid,
      'createdAt': createdAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
    };
  }
}
