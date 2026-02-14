class Credit {
  final String id;
  final String barberId;
  final String clientName;
  final String clientPhone;
  final String serviceName;
  final int amount;
  final String originalDate;
  final String status;

  Credit({
    required this.id,
    required this.barberId,
    required this.clientName,
    required this.clientPhone,
    required this.serviceName,
    required this.amount,
    required this.originalDate,
    required this.status,
  });

  factory Credit.fromMap(String id, Map<String, dynamic> map) {
    return Credit(
      id: id,
      barberId: map['barberId'] ?? '',
      clientName: map['clientName'] ?? '',
      clientPhone: map['clientPhone'] ?? '',
      serviceName: map['serviceName'] ?? '',
      amount: map['amount'] ?? 0,
      originalDate: map['originalDate'] ?? '',
      status: map['status'] ?? '',
    );
  }
}
