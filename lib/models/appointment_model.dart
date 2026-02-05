class Appointment {
  final String id;
  final String time;
  final String clientName;
  final String service;
  final String status; // confirmed | done | cancelled | no-show

  final int price;     // precio total
  final int advance;   // anticipo
  final bool paid;     // true si pagó anticipo
  final String paymentMethod; // card | cash | ''

  final int duration;
  final String phone;
  final int createdAt;


  Appointment({
    required this.id,
    required this.time,
    required this.clientName,
    required this.service,
    required this.status,
    required this.price,
    required this.advance,
    required this.paid,
    required this.paymentMethod,
    required this.duration,
    required this.phone,
    required this.createdAt,
  });


  factory Appointment.fromMap(String id, Map<dynamic, dynamic> data) {
    final safeTime = _safeTime((data['hourKey'] ?? '').toString());
    return Appointment(
      id: id,
      time: safeTime,
      clientName: (data['clientName'] ?? '').toString(),
      service: (data['service'] ?? '').toString(),

      status: (data['paymentStatus'] ?? 'pending').toString(),

      price: _toInt(data['amount']),

      advance: data['paid'] == true ? _toInt(data['amount']) : 0,

      paid: _toBool(data['paid']),

      paymentMethod: '',

      duration: _toInt(data['duration']),
      phone: (data['phone'] ?? '').toString(),
      createdAt: _toInt(data['createdAt']),
    );
  }

  int get remaining => price - advance;

  bool get isConfirmed => paid;

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static bool _toBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is String) return v == 'true';
    if (v is int) return v == 1;
    return false;
  }

  static String _safeTime(String? t) {
    if (t == null) return "00:00";

    // formato correcto HH:mm
    final regex = RegExp(r'^\d{2}:\d{2}$');

    if (regex.hasMatch(t)) return t;

    // walk-in o basura → fallback
    return "00:00";
  }

}
