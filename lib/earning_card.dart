import 'package:flutter/material.dart';

class EarningCard extends StatelessWidget {
  final String label;
  final int amount;

  const EarningCard(this.label, this.amount, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A), // dark moderno
        borderRadius: BorderRadius.circular(16),

        // 🔥 sombrita suave premium
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// label chico
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          /// número grande protagonista
          Text(
            '\$${amount}',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.greenAccent,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
