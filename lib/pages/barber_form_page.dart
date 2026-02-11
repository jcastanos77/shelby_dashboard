import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class BarberFormPage extends StatefulWidget {
  const BarberFormPage({super.key});

  @override
  State<BarberFormPage> createState() => _BarberFormPageState();
}

class _BarberFormPageState extends State<BarberFormPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();

  final _db = FirebaseDatabase.instance.ref('barbers');

  bool saving = false;

  // ============================
  // CREATE BARBER
  // ============================
  Future<void> _save() async {
    if (_name.text.isEmpty || _email.text.isEmpty) return;

    setState(() => saving = true);

    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: "123456",
      );

      final uid = cred.user!.uid;

      await _db.child(uid).set({
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'role': 'barber',
        'active': true,
        'passwordDefault': true,
      });

      _name.clear();
      _email.clear();
      _phone.clear();

      _snack("Barbero creado 💈", Colors.green);
    } catch (e) {
      _snack("Error creando barbero", Colors.red);
    }

    setState(() => saving = false);
  }

  // ============================
  // TOGGLE ACTIVE
  // ============================
  Future<void> _toggle(String uid, bool current) async {
    await _db.child(uid).update({'active': !current});
  }

  void _snack(String msg, Color c) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: c));
  }

  // ============================
  // UI
  // ============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barberos')),
      backgroundColor: const Color(0xFF0F0F0F),

      body: Column(
        children: [
          _buildForm(),

          const SizedBox(height: 12),

          /// 🔥 LISTA DE BARBEROS
          Expanded(child: _buildBarbersList()),
        ],
      ),
    );
  }

  // ============================
  // FORM CARD
  // ============================
  Widget _buildForm() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _input(_name, "Nombre"),
          _input(_email, "Correo"),
          _input(_phone, "Teléfono"),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: saving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Crear barbero", style: TextStyle(color: Colors.white),),
            ),
          )
        ],
      ),
    );
  }

  Widget _input(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF222222),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ============================
  // BARBERS LIST
  // ============================
  Widget _buildBarbersList() {
    return StreamBuilder(
      stream: _db.onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(child: Text("Sin barberos"));
        }

        final raw =
        Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);

        final entries = raw.entries.toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (_, i) {
            final uid = entries[i].key;
            final map = Map<String, dynamic>.from(entries[i].value);

            final active = map['active'] == true;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                  active ? Colors.green : Colors.grey,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  map['name'] ?? '',
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  map['email'] ?? '',
                  style: const TextStyle(color: Colors.white54),
                ),
                trailing: Switch(
                  value: active,
                  onChanged: (_) => _toggle(uid, active),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
