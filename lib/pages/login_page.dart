import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


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

  Future<void> _resetPassword() async {
    final email = emailCtrl.text.trim();

    if (email.isEmpty) {
      setState(() => error = "Escribe tu correo primero");
      return;
    }

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Te enviamos un correo para restablecer contraseña 📩"),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          error = "No existe una cuenta con ese correo";
        } else if (e.code == 'invalid-email') {
          error = "Correo inválido";
        } else {
          error = "Error al enviar correo";
        }
      });
    }
  }

  Future<void> login(BuildContext context) async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      final uid = cred.user!.uid;

      final snap = await FirebaseDatabase.instance
          .ref('barbers/$uid')
          .get();

      final role = snap.child('role').value?.toString() ?? 'barber';
      final isDefault = snap.child('passwordDefault').value == true;

      if (!mounted) return;

      if (role == 'owner') {
        context.go('/owner');
        return;
      }

      if (isDefault) {
        context.go('/change-password');
        return;
      }

      context.go('/dashboard');

    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          error = "Usuario no encontrado";
        } else if (e.code == 'wrong-password') {
          error = "Contraseña incorrecta";
        } else {
          error = "Error al iniciar sesión";
        }
      });
    }

    if (mounted) {
      setState(() => loading = false);
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
                  textType: TextInputType.emailAddress
                ),
                const SizedBox(height: 16),

                _buildInput(
                  controller: passCtrl,
                  label: 'Contraseña',
                  icon: Icons.lock,
                  obscure: true,
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _resetPassword,
                    child: const Text("¿Olvidaste tu contraseña?"),
                  ),
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
          'Shelby´s Dashboard',
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
    TextInputType textType = TextInputType.text
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: textType,
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
