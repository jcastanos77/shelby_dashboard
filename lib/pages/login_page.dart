import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../DashboardPage.dart';
import 'change_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool loading = false;
  String? error;

  Future<void> login(BuildContext context) async {
    final cred = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: emailCtrl.text.trim(),
      password: passCtrl.text.trim(),
    );

    final uid = cred.user!.uid;

    final snap = await FirebaseDatabase.instance
        .ref('barbers/$uid')
        .get();

    final isDefault = snap.child('passwordDefault').value == true;

    if (isDefault) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 32),

                _buildInput(
                  controller: emailCtrl,
                  label: 'Correo',
                  icon: Icons.email,
                ),
                const SizedBox(height: 16),

                _buildInput(
                  controller: passCtrl,
                  label: 'Contraseña',
                  icon: Icons.lock,
                  obscure: true,
                ),

                if (error != null) ...[
                  const SizedBox(height: 16),
                  Text(error!, style: const TextStyle(color: Colors.red)),
                ],

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: loading ? null : () => login(context),
                    child: loading
                        ? const CircularProgressIndicator()
                        : const Text('Entrar'),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _buildHeader() {
    return Column(
      children: const [
        Icon(Icons.content_cut, size: 72),
        SizedBox(height: 12),
        Text(
          'Barber Dashboard',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          'Inicia sesión para continuar',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
