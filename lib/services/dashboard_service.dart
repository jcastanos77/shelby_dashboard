import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/appointment_model.dart';

class DashboardService {
  final _db = FirebaseDatabase.instance.ref();
  final _uid = FirebaseAuth.instance.currentUser!.uid;

  String get todayKey {
    final now = DateTime.now();
    return '${now.year}-${_two(now.month)}-${_two(now.day)}';
  }

  /// ===============================
  /// TODAS las citas del día (walkin + booking)
  /// ===============================
  Future<List<Appointment>> getTodayAppointments() async {
    final snap = await _db
        .child('appointments/$_uid/$todayKey')
        .get();

    if (!snap.exists) return [];

    final raw = Map<String, dynamic>.from(snap.value as Map);

    final list = <Appointment>[];

    raw.forEach((hour, value) {
      final map = Map<String, dynamic>.from(value);

      if (map['type'] == 'walkin') return;

      list.add(Appointment.fromMap(hour, map));
    });

    list.sort((a, b) => a.time.compareTo(b.time));

    return list;
  }

  Future<int> getTodayWalkinsCount() async {
    final snap = await _db
        .child('appointments/$_uid/$todayKey')
        .get();

    if (!snap.exists) return 0;

    final raw = Map<String, dynamic>.from(snap.value as Map);

    int count = 0;

    raw.forEach((_, value) {
      final map = Map<String, dynamic>.from(value);

      if (map['type'] == 'walkin') {
        count++;
      }
    });
    return count;
  }

  /// ===============================
  /// TOTAL GANANCIA DEL DÍA
  /// ===============================
  Future<int> getTodayTotal() async {
    final snap = await _db
        .child('appointments/$_uid/$todayKey')
        .get();

    if (!snap.exists) return 0;

    final raw = Map<String, dynamic>.from(snap.value as Map);

    int total = 0;

    raw.forEach((_, value) {
      final map = Map<String, dynamic>.from(value);

      if (map['paid'] == true) {
        total += _toInt(map['price'] ?? map['amount']);
      }
    });

    return total;
  }

  String _two(int n) => n.toString().padLeft(2, '0');
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}
