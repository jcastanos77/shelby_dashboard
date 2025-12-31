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

  Future<List<Appointment>> getTodayAppointments() async {
    final snap = await _db
        .child('appointments/$_uid/$todayKey')
        .get();

    if (!snap.exists) return [];

    final Map data = snap.value as Map;

    final list = <Appointment>[];
    data.forEach((time, value) {
      list.add(Appointment.fromMap(time, value));
    });

    list.sort((a, b) => a.time.compareTo(b.time));
    return list;
  }

  String _two(int n) => n.toString().padLeft(2, '0');
}
