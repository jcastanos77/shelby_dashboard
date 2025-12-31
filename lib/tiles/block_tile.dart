import 'package:flutter/material.dart';

class BlockTile extends StatelessWidget {
  final String from;
  final String to;
  final String reason;

  const BlockTile({
    super.key,
    required this.from,
    required this.to,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.block, color: Colors.red),
      title: const Text('Horario bloqueado'),
      subtitle: Text('$from - $to\n$reason'),
    );
  }
}
