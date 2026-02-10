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
    final snap = await _db.child('appointments').get();

    if (!snap.exists || snap.value == null) return [];

    final raw = Map<String, dynamic>.from(
      snap.value as Map<dynamic, dynamic>,
    );

    final list = <Appointment>[];

    raw.forEach((id, value) {
      final map = Map<String, dynamic>.from(value);

      if (map['barberId'] != _uid) return;
      if (map['dateKey'] != todayKey) return;

      // solo citas reales, no walkins
      if (map['type'] == 'walkin') return;

      list.add(Appointment.fromMap(id, map));
    });

    list.sort((a, b) => a.time.compareTo(b.time));

    return list;
  }

  /// ===============================
  /// WALKINS DEL DÍA
  /// ===============================
  Future<int> getTodayWalkinsCount() async {
    final snap = await _db.child('appointments').get();

    if (!snap.exists || snap.value == null) return 0;

    final raw = Map<String, dynamic>.from(
      snap.value as Map<dynamic, dynamic>,
    );

    int count = 0;

    raw.forEach((_, value) {
      final map = Map<String, dynamic>.from(value);

      if (map['barberId'] == _uid &&
          map['dateKey'] == todayKey &&
          map['type'] == 'walkin') {
        count++;
      }
    });

    return count;
  }

  /// ===============================
  /// TOTAL GANANCIA DEL DÍA
  /// ===============================
  Future<int> getTodayTotal() async {
    final snap = await _db.child('appointments').get();

    if (!snap.exists || snap.value == null) return 0;

    final raw = Map<String, dynamic>.from(
      snap.value as Map<dynamic, dynamic>,
    );

    int total = 0;

    raw.forEach((_, value) {
      final map = Map<String, dynamic>.from(value);

      if (map['barberId'] == _uid &&
          map['dateKey'] == todayKey &&
          map['paid'] == true) {
        total += _toInt(map['amount'] ?? map['price']);
      }
    });

    return total;
  }

  Future<List<Appointment>> getAppointmentsByDate(String dateKey) async {
    final snap = await _db.child('appointments').get();

    if (!snap.exists || snap.value == null) return [];

    final raw = Map<String, dynamic>.from(
      snap.value as Map<dynamic, dynamic>,
    );

    final list = <Appointment>[];

    raw.forEach((id, value) {
      final map = Map<String, dynamic>.from(value);

      if (map['barberId'] != _uid) return;
      if (map['dateKey'] != dateKey) return;

      list.add(Appointment.fromMap(id, map));
    });

    list.sort((a, b) => a.time.compareTo(b.time));

    return list;
  }


  String _two(int n) => n.toString().padLeft(2, '0');
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}
