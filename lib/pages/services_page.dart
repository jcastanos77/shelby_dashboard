import 'package:dashboard_barbershop/services/services_service.dart';
import 'package:dashboard_barbershop/tiles/service_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../ServiceFormPage.dart';
import '../models/ServiceModel.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final BarberServicesService _service = BarberServicesService();
  List<ServiceModel> services = [];
  bool loading = true;
  List<ServiceModel> get clasicos =>
      services.where((s) => s.isSpecial == false).toList();

  List<ServiceModel> get especiales =>
      services.where((s) => s.isSpecial == true).toList();


  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    services = await _service.getServices(uid);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicios'),
        centerTitle: true,
      ),

      // ===== FAB PRO =====
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Agregar servicio'),
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ServiceFormPage(barberId: uid),
            ),
          );

          if (res == true) load();
        },
      ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : services.isEmpty
            ? _emptyState()
            : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (clasicos.isNotEmpty) ...[
              _sectionTitle('Servicios clásicos'),
              const SizedBox(height: 8),
              ...clasicos.map(
                    (s) => ServiceTile(
                  service: s,
                  onChanged: load,
                ),
              ),
              const SizedBox(height: 24),
            ],

            if (especiales.isNotEmpty) ...[
              _sectionTitle('Servicios especiales ⭐'),
              const SizedBox(height: 8),
              ...especiales.map(
                    (s) => ServiceTile(
                  service: s,
                  onChanged: load,
                ),
              ),
            ],
          ],
        ));
        }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // =======================
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.content_cut, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'No hay servicios aún',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            'Agrega tu primer servicio',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
