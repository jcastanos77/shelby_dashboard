import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/credit_model.dart';
import '../services/credit_service.dart';

class CreditsPage extends StatefulWidget {
  const CreditsPage({super.key});

  @override
  State<CreditsPage> createState() => _CreditsPageState();
}

class _CreditsPageState extends State<CreditsPage> {
  late CreditService _service;
  List<Credit> credits = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _service = CreditService(uid);
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final data = await _service.getPendingCredits();
    setState(() {
      credits = data;
      loading = false;
    });
  }

  int get totalAmount =>
      credits.fold(0, (sum, c) => sum + c.amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créditos Pendientes')),
      body: Column(
        children: [
          _buildSummaryCard(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "\$${totalAmount}",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${credits.length} clientes pendientes",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (credits.isEmpty) {
      return const Center(
        child: Text(
          'No hay créditos pendientes',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: credits.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final c = credits[i];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.clientName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text("Tel: ${c.clientPhone}"),
                const SizedBox(height: 4),
                Text("Servicio: ${c.serviceName}"),
                const SizedBox(height: 4),
                Text("Monto: \$${c.amount}"),
                const SizedBox(height: 4),
                Text("Fecha original: ${c.originalDate}"),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _service.markAsResolved(c.id);
                      _load();
                    },
                    child: const Text("Marcar como resuelto"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
