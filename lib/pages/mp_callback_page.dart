import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class MpCallbackPage extends StatefulWidget {
  const MpCallbackPage({super.key});

  @override
  State<MpCallbackPage> createState() => _MpCallbackPageState();
}

class _MpCallbackPageState extends State<MpCallbackPage> {

  @override
  void initState() {
    super.initState();
    _handle();
  }

  Future<void> _handle() async {
    final uri = Uri.base;

    final code = uri.queryParameters['code'];
    final uid = uri.queryParameters['state'];

    if (code == null || uid == null) {
      _goHome();
      return;
    }

    try {
      final callable =
      FirebaseFunctions.instance.httpsCallable('exchangeMpCode');

      await callable.call({
        'code': code,
        'uid': uid,
      });
      _goHome();

    } catch (e) {
      _goHome();
    }
  }

  void _goHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F0F0F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              "Conectando Mercado Pago...",
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
