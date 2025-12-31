import 'package:flutter/material.dart';

import '../controller/earnings_controller.dart';
import '../earning_card.dart';

class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  final _controller = EarningsController();
  EarningsData? data;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    data = await _controller.load();
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ganancias')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            EarningCard('Hoy', data!.day),
            EarningCard('Semana', data!.week),
            EarningCard('Mes', data!.month),
          ],
        ),
      ),
    );
  }
}
