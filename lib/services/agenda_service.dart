import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/appointment_model.dart';

class AgendaService {
  final String uid;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  AgendaService(this.uid);

  Future<List<Appointment>> getAppointmentsByDate(String dateKey) async {
    final snap = await _db.child('appointments').get();

    if (!snap.exists) return [];

    final Map raw = Map<String, dynamic>.from(snap.value as Map);

    final list = <Appointment>[];

    raw.forEach((id, value) {
      final map = Map<String, dynamic>.from(value);

      if (map['barberId'] == uid && map['dateKey'] == dateKey) {
        list.add(
          Appointment.fromMap(id, map), // 🔥 FIX REAL
        );
      }
    });

    list.sort((a, b) => a.time.compareTo(b.time));

    return list;
  }

  Future<void> updateStatus(String id, String status) async {
    await _db
        .child('appointments/$id/paymentStatus')
        .set(status);
  }

}
