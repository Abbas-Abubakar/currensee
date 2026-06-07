class RateAlert {
  final int? id;
  final String uid;
  final String baseCurrency;
  final String targetCurrency;
  final double targetRate;
  final bool isAbove; // true = alert when rate goes ABOVE target
  final bool isActive;
  final DateTime createdAt;

  const RateAlert({
    this.id,
    required this.uid,
    required this.baseCurrency,
    required this.targetCurrency,
    required this.targetRate,
    required this.isAbove,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'base_currency': baseCurrency,
      'target_currency': targetCurrency,
      'target_rate': targetRate,
      'is_above': isAbove ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory RateAlert.fromMap(Map<String, dynamic> map) {
    return RateAlert(
      id: map['id'] as int?,
      uid: map['uid'] as String,
      baseCurrency: map['base_currency'] as String,
      targetCurrency: map['target_currency'] as String,
      targetRate: map['target_rate'] as double,
      isAbove: (map['is_above'] as int) == 1,
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  RateAlert copyWith({
    int? id,
    String? uid,
    String? baseCurrency,
    String? targetCurrency,
    double? targetRate,
    bool? isAbove,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return RateAlert(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      targetCurrency: targetCurrency ?? this.targetCurrency,
      targetRate: targetRate ?? this.targetRate,
      isAbove: isAbove ?? this.isAbove,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}