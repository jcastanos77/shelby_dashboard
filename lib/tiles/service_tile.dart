import 'package:flutter/material.dart';

import '../models/ServiceModel.dart';
import '../services/services_service.dart';


class ServiceTile extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onChanged;

  const ServiceTile({
    super.key,
    required this.service,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          service.isSpecial ? Icons.star : Icons.content_cut,
          color: service.isSpecial ? Colors.amber : Colors.grey,
        ),
        title: Text(service.name),
        subtitle: Text(
          '\$${service.price} • ${service.duration} min',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _editPrice(context),
        ),
      ),
    );
  }

  void _editPrice(BuildContext context) async {
    final ctrl = TextEditingController(text: service.price.toString());

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar precio'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            prefixText: '\$',
            labelText: 'Nuevo precio',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (ok == true && ctrl.text.isNotEmpty) {
      await BarberServicesService()
          .updatePrice(service.id, int.parse(ctrl.text));

      onChanged();
    }
  }
}
