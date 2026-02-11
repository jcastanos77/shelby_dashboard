import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class EarningsData {
  final int day;
  final int week;
  final int month;

  final int servicesCount; // total servicios
  final String topService; // más vendido

  EarningsData({
    required this.day,
    required this.week,
    required this.month,
    required this.servicesCount,
    required this.topService,
  });
}

class EarningsController {
  final _db = FirebaseDatabase.instance.ref();
  final _uid = FirebaseAuth.instance.currentUser!.uid;

  Future<EarningsData> load() async {
    final snap = await _db.child('appointments').get();

    if (!snap.exists) {
      return EarningsData(
        day: 0,
        week: 0,
        month: 0,
        topService: '-',
        servicesCount: 0,
      );
    }

    final raw = Map<String, dynamic>.from(snap.value as Map);

    final now = DateTime.now();

    int dayTotal = 0;
    int weekTotal = 0;
    int monthTotal = 0;

    int cuts = 0;

    final serviceCount = <String, int>{};

    for (final value in raw.values) {
      final map = Map<String, dynamic>.from(value);

      if (map['barberId'] != _uid) continue;
      if (map['paid'] != true) continue;

      final amount = _toInt(map['amount']);
      final service = (map['service'] ?? '').toString();
      final dateKey = (map['dateKey'] ?? '').toString();

      final date = _parse(dateKey);
      if (date == null) continue;

      cuts++;
      serviceCount[service] = (serviceCount[service] ?? 0) + 1;

      if (_sameDay(now, date)) dayTotal += amount;
      if (_sameWeek(now, date)) weekTotal += amount;
      if (_sameMonth(now, date)) monthTotal += amount;
    }

    final avg = cuts == 0 ? 0 : (monthTotal ~/ cuts);

    String top = '-';
    int max = 0;

    serviceCount.forEach((k, v) {
      if (v > max) {
        max = v;
        top = k;
      }
    });

    return EarningsData(
      servicesCount: cuts,
      day: dayTotal,
      week: weekTotal,
      month: monthTotal,
      topService: top,
    );
  }

  // ================= helpers =================

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  DateTime? _parse(String key) {
    try {
      final parts = key.split('-');
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (_) {
      return null;
    }
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _sameWeek(DateTime now, DateTime d) {
    final start = now.subtract(Duration(days: now.weekday - 1));
    return d.isAfter(start.subtract(const Duration(seconds: 1)));
  }

  bool _sameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;
}
