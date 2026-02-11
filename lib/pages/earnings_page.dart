import 'package:flutter/material.dart';
import '../controller/earnings_controller.dart';
import '../earning_card.dart';
import '../widget/stat_card.dart';

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
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(title: const Text('Ganancias')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /// 💰 DINERO
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              EarningCard('Hoy', data!.day),
              EarningCard('Semana', data!.week),
              EarningCard('Mes', data!.month),
              EarningCard('Tickets', data!.servicesCount),
            ],
          ),

          const SizedBox(height: 20),

          /// 📊 STATS
          StatCard(
            'Servicio más vendido',
            data!.topService,
            icon: Icons.content_cut,
            color: Colors.orange,
          ),

          const SizedBox(height: 12),

          StatCard(
            'Cortes hoy',
            data!.servicesCount.toString(),
            icon: Icons.people,
            color: Colors.blue,
          ),
        ],
      ),

    );
  }
}
