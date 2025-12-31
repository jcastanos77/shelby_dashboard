import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/appointment_model.dart';

class AgendaService {
  final String uid;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  AgendaService(this.uid);

  Future<List<Appointment>> getAppointmentsByDate(String dateKey) async {
    final snap = await _db.child('appointments/$uid/$dateKey').get();

    if (!snap.exists) return [];
  print(snap.value);
    final Map data = Map<String, dynamic>.from(snap.value as Map);
    final list = <Appointment>[];

    data.forEach((time, value) {
      list.add(Appointment.fromMap(time, value));
    });

    list.sort((a, b) => a.time.compareTo(b.time));
    return list;
  }

  Future<void> updateStatus(
      String dateKey,
      String time,
      String status,
      ) async {
    await _db
        .child('appointments/$uid/$dateKey/$time/status')
        .set(status);
  }
}
