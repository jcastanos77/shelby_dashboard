import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../models/barber_model.dart';
import '../../services/barbers_service.dart';

class BarberFormPage extends StatefulWidget {
  const BarberFormPage({super.key});

  @override
  State<BarberFormPage> createState() => _BarberFormPageState();
}

class _BarberFormPageState extends State<BarberFormPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();

  bool saving = false;

  Future<void> _save() async {
    if (_name.text.isEmpty || _email.text.isEmpty) return;

    setState(() => saving = true);

    final cred = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: _email.text.trim(),
      password: "123456",
    );

    final uid = cred.user!.uid;

    await FirebaseDatabase.instance
        .ref('barbers/$uid')
        .set({
      'name': _name.text,
      'email': _email.text,
      'phone': _phone.text,
      'role': 'barber',
      'active': true,
      'passwordDefault': true
    });

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo barbero')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Correo')),
            TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Teléfono')),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: saving ? null : _save,
              child: const Text('Crear barbero'),
            )
          ],
        ),
      ),
    );
  }
}
