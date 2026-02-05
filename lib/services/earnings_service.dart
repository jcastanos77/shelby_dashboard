import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class EarningsService {
  final _db = FirebaseDatabase.instance.ref();
  final _uid = FirebaseAuth.instance.currentUser!.uid;

  // =========================
  // GANANCIA DEL DÍA
  // =========================
  Future<int> getDayEarnings(DateTime date) async {
    final key = _keyFromDate(date);

    final snap = await _db.child('appointments').get();

    if (!snap.exists) return 0;

    final Map raw = Map<String, dynamic>.from(snap.value as Map);

    int total = 0;

    raw.forEach((_, value) {
      final map = Map<String, dynamic>.from(value);

      if (map['barberId'] == _uid &&
          map['dateKey'] == key &&
          map['paid'] == true) {
        total += _toInt(map['price'] ?? map['amount']);
      }
    });

    return total;
  }

  // =========================
  // RANGO
  // =========================
  Future<int> getRangeEarnings(DateTime from, DateTime to) async {
    int total = 0;

    for (DateTime d = from;
    !d.isAfter(to);
    d = d.add(const Duration(days: 1))) {
      total += await getDayEarnings(d);
    }

    return total;
  }

  String _keyFromDate(DateTime d) =>
      '${d.year}-${_two(d.month)}-${_two(d.day)}';

  String _two(int n) => n.toString().padLeft(2, '0');
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}