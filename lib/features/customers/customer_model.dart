class Customer {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;
  final String? billingCurrencyCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;

  Customer({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.notes,
    this.billingCurrencyCode,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'pendingCreate',
  });

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      notes: map['notes'] as String?,
      billingCurrencyCode: map['billing_currency_code'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      syncStatus: map['sync_status'] as String? ?? 'synced',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'notes': notes,
      'billing_currency_code': billingCurrencyCode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sync_status': syncStatus,
      'version': 1,
    };
  }

  Customer copyWith({
    String? name,
    String? phone,
    String? email,
    String? address,
    String? notes,
    String? billingCurrencyCode,
  }) {
    return Customer(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      billingCurrencyCode: billingCurrencyCode ?? this.billingCurrencyCode,
      createdAt: createdAt,
      updatedAt: DateTime.now().toUtc(),
      syncStatus: 'pendingUpdate',
    );
  }
}
