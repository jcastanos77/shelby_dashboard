import '../../models/appointment_model.dart';
import '../services/dashboard_service.dart';

class DashboardData {
  final List<Appointment> appointments;
  final int totalCitas;
  final int totalGanancia;
  final int totalWalkins;
  final Appointment? nextAppointment;

  DashboardData({
    required this.appointments,
    required this.totalCitas,
    required this.totalGanancia,
    required this.totalWalkins,
    required this.nextAppointment,
  });
}

class DashboardController {
  final _service = DashboardService();

  Future<DashboardData> load() async {
    final list = await _service.getTodayAppointments();
    final walkins = await _service.getTodayWalkinsCount();

    int total = 0;
    int count = 0;
    Appointment? next;

    final now = DateTime.now();

    for (final a in list) {
      if (a.status != 'cancelled') {
        count++;
        if (a.status == 'done') {
          total += a.price;
        }

        final time = _parseTime(a.time);
        if (time.isAfter(now) && next == null) {
          next = a;
        }
      }
    }

    return DashboardData(
      appointments: list,
      totalCitas: count,
      totalWalkins: walkins,
      totalGanancia: total,
      nextAppointment: next,
    );
  }

  DateTime _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
}
