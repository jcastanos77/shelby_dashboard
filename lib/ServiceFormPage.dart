import 'package:flutter/material.dart';
import 'package:dashboard_barbershop/services/services_service.dart';
import 'models/ServiceModel.dart';

class ServiceFormPage extends StatefulWidget {
  final String barberId;

  const ServiceFormPage({super.key, required this.barberId});

  @override
  State<ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends State<ServiceFormPage> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  final _service = BarberServicesService();

  bool isSpecial = false;
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo servicio'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildField(
                  controller: _nameCtrl,
                  label: 'Nombre del servicio',
                  icon: Icons.content_cut,
                ),
                const SizedBox(height: 12),

                _buildField(
                  controller: _descriptionCtrl,
                  label: 'Descripción breve',
                  icon: Icons.notes,
                  maxLines: 2,
                  maxLength: 280
                ),
                const SizedBox(height: 12),

                _buildField(
                  controller: _priceCtrl,
                  label: 'Precio',
                  icon: Icons.attach_money,
                  keyboard: TextInputType.number,
                ),
                const SizedBox(height: 12),

                _buildField(
                  controller: _durationCtrl,
                  label: 'Duración (min)',
                  icon: Icons.timer,
                  keyboard: TextInputType.number,
                ),

                const SizedBox(height: 20),

                // ===== SWITCH CLASICO / ESPECIAL =====
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSpecial ? Icons.star : Icons.check_circle,
                        color: isSpecial ? Colors.amber : Colors.green,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isSpecial ? 'Servicio especial' : 'Servicio clásico',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Switch(
                        value: isSpecial,
                        activeColor: Colors.amber,
                        onChanged: (v) => setState(() => isSpecial = v),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: saving ? null : _save,
                    child: saving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Guardar servicio',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =====================
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    int maxLength = 50,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // =====================
  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty ||
        _priceCtrl.text.isEmpty ||
        _durationCtrl.text.isEmpty ||
        _descriptionCtrl.text.isEmpty) return;

    setState(() => saving = true);

    final service = ServiceModel(
      id: '',
      name: _nameCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      price: int.parse(_priceCtrl.text),
      duration: int.parse(_durationCtrl.text),
      isSpecial: isSpecial,
    );

    await _service.addService(widget.barberId, service);

    if (mounted) Navigator.pop(context, true);
  }
}
