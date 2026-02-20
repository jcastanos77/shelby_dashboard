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

  Future<void> blockFullDayV2({
    required String barberId,
    required DateTime date,
  }) async {
    final db = FirebaseDatabase.instance.ref();
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    await db
        .child('blockedDays')
        .child(barberId)
        .child(dateKey)
        .set(true);
  }

  Future<void> unblockFullDay({
    required String barberId,
    required String dateKey,
  }) async {
    final db = FirebaseDatabase.instance.ref();

    await db
        .child('blockedDays')
        .child(barberId)
        .child(dateKey)
        .remove();
  }

  Future<void> unblockDay({
    required String barberId,
    required String dateKey,
  }) async {
    final db = FirebaseDatabase.instance.ref();

    final snapshot = await db.child('appointments').get();

    if (!snapshot.exists) return;

    final data = snapshot.value as Map;

    for (final entry in data.entries) {
      final key = entry.key;
      final value = Map<String, dynamic>.from(entry.value);

      if (value['barberId'] == barberId &&
          value['dateKey'] == dateKey &&
          value['type'] == 'block') {
        await db.child('appointments').child(key).remove();
      }
    }
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${_two(d.month)}-${_two(d.day)}';

  String _two(int n) => n.toString().padLeft(2, '0');
}
