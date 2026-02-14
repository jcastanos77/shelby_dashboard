import 'package:firebase_database/firebase_database.dart';
import '../models/credit_model.dart';

class CreditService {
  final String uid;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  CreditService(this.uid);

  Future<List<Credit>> getPendingCredits() async {
    final snap = await _db.child('credits').get();

    if (!snap.exists || snap.value == null) return [];

    final raw = Map<String, dynamic>.from(
        snap.value as Map<dynamic, dynamic>);

    final list = <Credit>[];

    raw.forEach((id, value) {
      final map = Map<String, dynamic>.from(value);

      if (map['barberId'] != uid) return;
      if (map['status'] != 'pending') return;

      list.add(Credit.fromMap(id, map));
    });

    return list;
  }

  Future<void> markAsResolved(String id) async {
    await _db.child('credits/$id').update({
      'status': 'resolved',
      'resolvedAt': ServerValue.timestamp,
    });
  }
}
