import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/barber_model.dart';

class BarbersService {
  final _db = FirebaseDatabase.instance.ref();

  Future<List<BarberModel>> getBarbers() async {
    final snap = await _db.child('barbers').get();
    if (!snap.exists) return [];

    return snap.children.map((e) {
      final data = Map<dynamic, dynamic>.from(e.value as Map);
      return BarberModel.fromMap(e.key!, data);
    }).toList();
  }

  Future<void> addBarber(BarberModel barber) async {
    await _db
        .child('barbers')
        .push()
        .set(barber.toMap());
  }

  Future<void> updateBarber(BarberModel barber) async {
    await _db
        .child('barbers/${barber.id}')
        .update(barber.toMap());
  }

  Future<void> deleteBarber(String barberId) async {
    await _db.child('barbers/$barberId').remove();
  }

  Future<bool> isAdmin() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final snap = await FirebaseDatabase.instance
        .ref('barbers/$uid/role')
        .get();

    return snap.exists && snap.value == 'admin';
  }
}
