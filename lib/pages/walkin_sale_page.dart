import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/ServiceModel.dart';
import '../services/services_service.dart';

class WalkinSalePage extends StatefulWidget {
  const WalkinSalePage({super.key});

  @override
  State<WalkinSalePage> createState() => _WalkinSalePageState();
}

class _WalkinSalePageState extends State<WalkinSalePage> {
  final priceCtrl = TextEditingController();
  final clientCtrl = TextEditingController();

  String service = "Corte clásico";
  String paymentMethod = "cash";

  bool saving = false;
  final BarberServicesService _service = BarberServicesService();
  List<ServiceModel> services = [];
  final uid = FirebaseAuth.instance.currentUser!.uid;


  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    priceCtrl.dispose();
    clientCtrl.dispose();
    super.dispose();
  }

  Future<void> load() async {
    final result = await _service.getServices(uid);

    setState(() {
      services = result;

      if (services.isNotEmpty) {
        service = services.first.name;
        priceCtrl.text = services.first.price.toString();
      }
    });
  }

  Future<void> _saveSale() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final price = int.tryParse(priceCtrl.text) ?? 0;

    if (price <= 0) {
      _snack("Precio inválido", Colors.orange);
      return;
    }

    setState(() => saving = true);

    try {
      final id = FirebaseDatabase.instance.ref().push().key;

      await FirebaseDatabase.instance
          .ref('appointments/$id') // 🔥 PLANO
          .set({
        "type": "walkin",
        "barberId": uid,           // 🔥 CLAVE
        "clientName": clientCtrl.text.isEmpty ? "Walk-in" : clientCtrl.text.trim(),
        "service": service,
        "amount": price,           // 🔥 MISMO CAMPO QUE MP
        "paymentStatus": "done",   // 🔥 MISMO STATUS
        "paid": true,
        "dateKey": _todayKey(),
        "hourKey": TimeOfDay.now().format(context),
        "createdAt": ServerValue.timestamp,
      });

      _snack("Venta registrada 💸", Colors.green);
      Navigator.pop(context);
    } catch (e) {
      _snack("Error guardando venta", Colors.red);
    }

    setState(() => saving = false);
  }

  String _todayKey() {
    final d = DateTime.now();
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text("Venta rápida"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _card(
              child: Column(
                children: [
                  _title("Servicio"),
                  DropdownButtonFormField<String>(
                    value: service,
                    dropdownColor: Colors.black,
                    items: services
                        .map((s) =>
                        DropdownMenuItem(value: s.name, child: Text(s.name)))
                        .toList(),
                    onChanged: (v) {
                      final s = services.firstWhere((e) => e.name == v);

                      setState(() {
                        service = v!;
                        priceCtrl.text = s.price.toString();
                      });
                    },

                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            _card(
              child: Column(
                children: [
                  _title("Precio"),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "Ej. 200",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            _card(
              child: Column(
                children: [
                  _title("Cliente (opcional)"),
                  TextField(
                    controller: clientCtrl,
                    decoration: const InputDecoration(
                      hintText: "Nombre",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            _card(
              child: Column(
                children: [
                  _title("Método de pago"),
                  Row(
                    children: [
                      _paymentBtn("cash", "Efectivo"),
                      _paymentBtn("card", "Tarjeta"),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: saving ? null : _saveSale,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Registrar venta",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentBtn(String value, String label) {
    final selected = paymentMethod == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => paymentMethod = value),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? Colors.blue : Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(label)),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }

  Widget _title(String t) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        t,
        style: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
