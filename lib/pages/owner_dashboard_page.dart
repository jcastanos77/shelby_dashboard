import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OwnerDashboardPage extends StatefulWidget {
  const OwnerDashboardPage({super.key});

  @override
  State<OwnerDashboardPage> createState() => _OwnerDashboardPageState();
}

class _OwnerDashboardPageState extends State<OwnerDashboardPage> {

  final _appointmentsDb = FirebaseDatabase.instance.ref('appointments');
  final _barbersDb = FirebaseDatabase.instance.ref('barbers');

  final int commissionPerCut = 5;

  bool loading = true;

  Map<String, int> barberCuts = {};
  Map<String, int> barberDebt = {};
  Map<String, String> barberNames = {};

  int totalWeekDebt = 0;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {

    final appointmentsSnap = await _appointmentsDb.get();
    final barbersSnap = await _barbersDb.get();

    if (!appointmentsSnap.exists || !barbersSnap.exists) {
      setState(() => loading = false);
      return;
    }

    final appointmentsRaw =
    Map<String, dynamic>.from(appointmentsSnap.value as Map);

    final barbersRaw =
    Map<String, dynamic>.from(barbersSnap.value as Map);

    /// 🔥 Cargar nombres
    barbersRaw.forEach((uid, value) {
      if (value is Map) {
        final map = Map<String, dynamic>.from(value);
        barberNames[uid] = map['name'] ?? 'Sin nombre';
      }
    });

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartClean =
    DateTime(weekStart.year, weekStart.month, weekStart.day);

    Map<String, int> tempCuts = {};
    Map<String, int> tempDebt = {};

    appointmentsRaw.forEach((key, value) {

      /// 🔥 WALK-IN
      if (value is Map && value.containsKey('barberId')) {

        final map = Map<String, dynamic>.from(value);

        if (map['paymentStatus'] != 'done') return;

        DateTime? appointmentDate;

        try {
          appointmentDate = DateTime.parse(map['dateKey']);
        } catch (_) {
          return;
        }

        if (appointmentDate.isBefore(weekStartClean)) return;

        final barberId = map['barberId'];

        tempCuts[barberId] = (tempCuts[barberId] ?? 0) + 1;
        tempDebt[barberId] =
            (tempDebt[barberId] ?? 0) + commissionPerCut;

        return;
      }

      /// 🔥 BOOKINGS
      if (value is! Map) return;

      final dateMap = Map<String, dynamic>.from(value);

      dateMap.forEach((dateKey, dateValue) {

        if (dateValue is! Map) return;

        DateTime? appointmentDate;

        try {
          appointmentDate = DateTime.parse(dateKey);
        } catch (_) {
          return;
        }

        if (appointmentDate.isBefore(weekStartClean)) return;

        final hourMap = Map<String, dynamic>.from(dateValue);

        hourMap.forEach((_, appointmentValue) {

          if (appointmentValue is! Map) return;

          final map = Map<String, dynamic>.from(appointmentValue);

          if (map['paymentStatus'] != 'done') return;

          tempCuts[key] = (tempCuts[key] ?? 0) + 1;
          tempDebt[key] =
              (tempDebt[key] ?? 0) + commissionPerCut;
        });
      });
    });

    int total = 0;
    tempDebt.values.forEach((v) => total += v);

    setState(() {
      barberCuts = tempCuts;
      barberDebt = tempDebt;
      totalWeekDebt = total;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final sorted = barberDebt.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text("👑 Owner Fintech"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              logout(context);
            },
          )
        ]
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// 🔥 RESUMEN TOTAL
            _buildTotalCard(),

            const SizedBox(height: 24),

            Expanded(
              child: ListView.builder(
                itemCount: sorted.length,
                itemBuilder: (_, i) {
                  final barberId = sorted[i].key;
                  final debt = sorted[i].value;
                  final cuts = barberCuts[barberId] ?? 0;
                  final name = barberNames[barberId] ?? barberId;

                  return _buildBarberCard(
                    name: name,
                    cuts: cuts,
                    debt: debt,
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Colors.green, Colors.teal],
        ),
      ),
      child: Column(
        children: [
          const Text(
            "Comisión semanal total",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            "\$$totalWeekDebt",
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBarberCard({
    required String name,
    required int cuts,
    required int debt,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [

          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.green.withOpacity(0.2),
            child: const Icon(Icons.person, color: Colors.green),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "$cuts cortes esta semana",
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "Te debe",
                style: TextStyle(color: Colors.white54),
              ),
              Text(
                "\$$debt",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    context.go('/login');
  }
}
