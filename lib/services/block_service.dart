import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class BlockService {
  final _db = FirebaseDatabase.instance.ref();
  final _uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> blockTime({
    required DateTime date,
    required String from,
    required String to,
    String reason = 'Bloqueado',
  }) async {

    final dateKey = _dateKey(date);

    await _db.child('appointments').push().set({
      'barberId': _uid,
      'dateKey': dateKey,
      'hourKey': from,
      'type': 'block',
      'reason': reason,
      'createdAt': ServerValue.timestamp,
    });
  }

  Future<void> blockFullDay({
    required String barberId,
    required DateTime date,
  }) async {

    final db = FirebaseDatabase.instance.ref();
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final workingHours = {
      1: [9,10,11,12,13,14,15,16,17,18,19,20],
      2: [9,10,11,12,13,14,15,16,17,18,19,20],
      3: [9,10,11,12,13,14,15,16,17,18,19,20],
      4: [9,10,11,12,13,14,15,16,17,18,19,20],
      5: [9,10,11,12,13,14,15,16,17,18,19,20],
      6: [9,10,11,12,13,14,15,16,17,18,19,20],
      7: [10,11,12,13,14,15,16],
    };

    for (final hour in workingHours[date.weekday]!) {
      final hourKey = '${hour.toString().padLeft(2, '0')}:00';

      await db.child('appointments').push().set({
        'barberId': barberId,
        'dateKey': dateKey,
        'hourKey': hourKey,
        'type': 'block',
        'createdAt': ServerValue.timestamp,
        'paymentStatus': 'blocked_day',
      });
    }
  }




  String _dateKey(DateTime d) =>
      '${d.year}-${_two(d.month)}-${_two(d.day)}';

  String _two(int n) => n.toString().padLeft(2, '0');
}
