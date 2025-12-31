import 'package:flutter/material.dart';
import '../models/appointment_model.dart';

enum AppointmentStatus { pending, done, cancelled }

class AppointmentTile extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onDone;
  final VoidCallback onCancel;

  const AppointmentTile({
    super.key,
    required this.appointment,
    required this.onDone,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (appointment.status) {
      case 'done':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'cancelled':
        icon = Icons.cancel;
        color = Colors.red;
        break;
      default:
        icon = Icons.access_time;
        color = Colors.orange;
    }

    return ListTile(
      leading: Text(
        appointment.time,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      title: Text(appointment.service),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'done') onDone();
              if (v == 'cancel') onCancel();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'done', child: Text('Marcar done')),
              PopupMenuItem(value: 'cancel', child: Text('Cancelar')),
            ],
          ),
        ],
      ),
    );
  }
}
