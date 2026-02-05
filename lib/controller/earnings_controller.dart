import '../services/earnings_service.dart';

class EarningsData {
  final int day;
  final int week;
  final int month;

  EarningsData({
    required this.day,
    required this.week,
    required this.month,
  });
}

class EarningsController {
  final _service = EarningsService();

  Future<EarningsData> load() async {
    final now = DateTime.now();

    final day = await _service.getDayEarnings(now);

    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final week = await _service.getRangeEarnings(weekStart, weekEnd);

    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd =
    DateTime(now.year, now.month + 1, 0);
    final month =
    await _service.getRangeEarnings(monthStart, monthEnd);

    return EarningsData(day: day, week: week, month: month);
  }
}
