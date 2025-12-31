import 'package:flutter/material.dart';

class EarningCard extends StatelessWidget {
  final String label;
  final int amount;

  const EarningCard(this.label, this.amount);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(label),
        trailing: Text(
          '\$${amount}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
