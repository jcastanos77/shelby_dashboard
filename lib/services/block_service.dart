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

    await _db
        .child('appointments/$_uid/$dateKey/$from')
        .set({
      'type': 'block',
      'from': from,
      'to': to,
      'reason': reason,
    });
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${_two(d.month)}-${_two(d.day)}';

  String _two(int n) => n.toString().padLeft(2, '0');
}
