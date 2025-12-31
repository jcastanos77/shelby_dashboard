import 'package:flutter/material.dart';

import '../models/appointment_model.dart';

class AgendaTile extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onDone;
  final VoidCallback onCancel;

  const AgendaTile({
    required this.appointment,
    required this.onDone,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Text(
          appointment.time,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        title: Text(appointment.service),
        subtitle: Text(
          '${appointment.clientName} • \$${appointment.price}',
        ),
        trailing: _buildActions(),
      ),
    );
  }

  Widget _buildActions() {
    if (appointment.status == 'done') {
      return const Icon(Icons.check_circle, color: Colors.green);
    }

    if (appointment.status == 'cancelled') {
      return const Icon(Icons.cancel, color: Colors.red);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.check, color: Colors.green),
          onPressed: onDone,
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: onCancel,
        ),
      ],
    );
  }
}
