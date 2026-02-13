import 'package:dashboard_barbershop/dashboard_home.dart';
import 'package:dashboard_barbershop/pages/change_password_page.dart';
import 'package:dashboard_barbershop/pages/login_page.dart';
import 'package:dashboard_barbershop/pages/mp_callback_page.dart';
import 'package:dashboard_barbershop/pages/owner_dashboard_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'DashboardPage.dart';
import 'auth_gate.dart';
import 'firebase_options.dart';

final _router = GoRouter(
  initialLocation: '/',

  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const AuthGate(),
    ),

    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginPage(),
    ),

    GoRoute(
      path: '/change-password',
      builder: (_, __) => const ChangePasswordPage(),
    ),

    /// Dashboard
    GoRoute(
      path: '/dashboard',
      builder: (_, __) => const DashboardPage(),
    ),

    /// 🔥 OAuth callback MercadoPago
    GoRoute(
      path: '/mp-callback',
      builder: (_, __) => const MpCallbackPage(),
    ),

    GoRoute(
      path: '/owner',
      builder: (_, __) => const OwnerDashboardPage(),
    ),

  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  setUrlStrategy(PathUrlStrategy());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Barbershop',
      theme: ThemeData.dark(),
      routerConfig: _router,
    );
  }
}
