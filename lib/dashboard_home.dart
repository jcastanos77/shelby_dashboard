import 'package:dashboard_barbershop/DashboardPage.dart';
import 'package:dashboard_barbershop/pages/services_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'pages/agenda_page.dart';
import 'pages/earnings_page.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  int index = 0;

  final pages = const [
    DashboardPage(),
    AgendaPage(),
    ServicesPage(),
    EarningsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, color: Colors.white,), label: 'Home', ),
          BottomNavigationBarItem(icon: Icon(Icons.event, color: Colors.white), label: 'Agenda'),
          BottomNavigationBarItem(icon: Icon(Icons.cut, color: Colors.white), label: 'Servicios'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money, color: Colors.white), label: 'Ganancias'),
        ],
      ),
    );
  }
}
