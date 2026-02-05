import 'package:dashboard_barbershop/pages/agenda_page.dart';
import 'package:dashboard_barbershop/pages/earnings_page.dart';
import 'package:dashboard_barbershop/pages/login_page.dart';
import 'package:dashboard_barbershop/pages/services_page.dart';
import 'package:dashboard_barbershop/pages/walkin_sale_page.dart';
import 'package:dashboard_barbershop/quick_action.dart';
import 'package:dashboard_barbershop/services/barbers_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Metric.dart';
import 'pages/barber_form_page.dart';
import 'pages/change_password_page.dart';
import 'controller/dashboard_controller.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _controller = DashboardController();
  DashboardData? data;
  bool loading = true;
  bool isAdmin = false;
  bool mpConnected = false;


  @override
  void initState() {
    super.initState();
    load();
    _checkPasswordStatus();
  }

  Future<void> connectMercadoPago() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final url =
        "https://auth.mercadopago.com.mx/authorization"
        "?response_type=code"
        "&client_id=APP_USR-006b239a-880b-4167-8487-02c6286dadf3"
        "&redirect_uri=https://neon-seahorse-b85142.netlify.app/mp-callback"
        "&state=$uid";

    await launchUrl(
      Uri.parse(url),
      webOnlyWindowName: '_self',
    );
  }

  Future<void> load() async {
    try {
    data = await _controller.load();
    isAdmin = await BarbersService().isAdmin();
    await _loadMpStatus();
    } catch (e) {
      debugPrint("🔥 dashboard error: $e");
    }
    setState(() => loading = false);
  }

  Future<void> _loadMpStatus() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final snap = await FirebaseDatabase.instance
        .ref('barbers/$uid/mpConnected')
        .get();

    mpConnected = snap.value == true;
  }

  Future<void> _checkPasswordStatus() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final snap = await FirebaseDatabase.instance
        .ref('barbers/$uid/passwordDefault')
        .get();

    if (snap.value == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
      );
    }
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading || data == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shelby´s Barber'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              logout(context);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),

            _buildTodaySummary(),
            const SizedBox(height: 20),

            _buildNextAppointmentCard(),
            const SizedBox(height: 24),

            _buildQuickActions(context),
            const SizedBox(height: 24),

            _buildMpConnectButton(),

            const SizedBox(height: 24),

            const SizedBox(height: 32),
            if (isAdmin) _buildAdminSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMpConnectButton() {
    return Card(
      child: ListTile(
        leading: Icon(
          mpConnected ? Icons.check_circle : Icons.link,
          color: mpConnected ? Colors.green : Colors.orange,
        ),
        title: Text(
          mpConnected
              ? "Cuenta Mercado Pago conectada"
              : "Conectar Mercado Pago",
        ),
        subtitle: Text(
          mpConnected
              ? "Recibes pagos directamente"
              : "Recibe pagos en tu cuenta",
        ),
        trailing: mpConnected
            ? null
            : const Icon(Icons.chevron_right),
        onTap: mpConnected ? null : connectMercadoPago,
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Buen día 👋',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          'Aquí está tu resumen de hoy',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildTodaySummary() {
    return Row(
      children: [
        Expanded(
          child: MetricCard(
            title: 'Citas hoy',
            value: data!.totalCitas.toString(),
            icon: Icons.calendar_today,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MetricCard(
            title: 'Walk-ins',
            value: data!.totalWalkins.toString(),
            icon: Icons.flash_on,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MetricCard(
            title: 'Ganancia',
            value: '\$${data!.totalGanancia}',
            icon: Icons.attach_money,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildNextAppointmentCard() {
    if (data!.nextAppointment == null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.check_circle, color: Colors.green),
          title: const Text('No tienes más citas hoy'),
        ),
      );
    }

    final a = data!.nextAppointment!;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const Icon(Icons.schedule, size: 32),
        title: Text('${a.time} • ${a.service}'),
        subtitle: Text('${a.clientName} • \$${a.price}'),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        QuickAction(
          icon: Icons.flash_on,
          label: 'Venta rápida',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => WalkinSalePage()),
            );
          },
        ),
        QuickAction(
          icon: Icons.calendar_month,
          label: 'Agenda',
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=> AgendaPage()));
          },
        ),
        QuickAction(
          icon: Icons.content_cut,
          label: 'Servicios',
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=> ServicesPage()));
          },
        ),
        QuickAction(
          icon: Icons.attach_money,
          label: 'Ganancias',
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=> EarningsPage()));
          },
        ),
      ],
    );
  }

  Widget _buildAdminSection(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Administración',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Barberos'),
            subtitle: const Text('Agregar y administrar barberos'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BarberFormPage()),
              );
            },
          ),
        ),
      ],
    );
  }
}
