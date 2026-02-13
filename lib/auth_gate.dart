import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authSnap.data;

        if (user == null) {
          return const LoginPage();
        }

        /// 🔥 Usuario autenticado → ahora vemos su rol
        return FutureBuilder(
          future: FirebaseDatabase.instance
              .ref('barbers/${user.uid}/role')
              .get(),
          builder: (context, roleSnap) {
            if (!roleSnap.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final role = roleSnap.data!.value?.toString() ?? '';

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (role == 'owner') {
                context.go('/owner');
              } else {
                context.go('/dashboard');
              }
            });

            return const SizedBox(); // placeholder
          },
        );
      },
    );
  }
}
