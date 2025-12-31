class Appointment {
  final String time;
  final String clientName;
  final String service;
  final String status;
  final int price;
  final int duration;
  final String phone;
  final int createdAt;

  Appointment({
    required this.time,
    required this.clientName,
    required this.service,
    required this.status,
    required this.price,
    required this.duration,
    required this.phone,
    required this.createdAt,
  });

  factory Appointment.fromMap(String time, Map<dynamic, dynamic> data) {
    return Appointment(
      time: time,
      clientName: (data['clientName'] ?? '').toString(),
      service: (data['service'] ?? '').toString(),
      status: (data['status'] ?? 'pending').toString(),
      phone: (data['phone'] ?? '').toString(),
      price: _toInt(data['price']),
      duration: _toInt(data['duration']),
      createdAt: _toInt(data['createdAt']),
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}
