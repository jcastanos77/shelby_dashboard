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
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final now = DateTime.now();
    final dateKey =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final snap = await FirebaseDatabase.instance
        .ref('appointments') // 🔥 IMPORTANTE: raíz, no anidado
        .get();

    if (!snap.exists) return [];

    final Map raw = Map<String, dynamic>.from(snap.value as Map);

    final list = <Appointment>[];

    raw.forEach((id, value) {
      final map = Map<String, dynamic>.from(value);

      /// 🔥 filtro manual (porque tu DB es plana)
      if (map['barberId'] == uid && map['dateKey'] == dateKey) {
        list.add(
          Appointment.fromMap(map['hourKey'], map),
        );
      }
    });

    list.sort((a, b) => a.time.compareTo(b.time));

    return list;
  }

  String _two(int n) => n.toString().padLeft(2, '0');
}
