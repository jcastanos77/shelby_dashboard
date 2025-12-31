import 'package:dashboard_barbershop/services/agenda_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/appointment_model.dart';
import '../../services/block_service.dart';
import '../../tiles/appointment_tile.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  late final AgendaService _agenda;

  late String selectedDate;
  bool loading = true;

  List<Appointment> appointments = [];

  @override
  void initState() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    super.initState();
    _agenda = AgendaService(uid);
    selectedDate = _todayKey();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;

    setState(() => loading = true);

    final data = await _agenda.getAppointmentsByDate(selectedDate);

    if (!mounted) return;

    setState(() {
      appointments = data;
      loading = false;
    });
  }



  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.block),
            tooltip: 'Bloquear horario',
            onPressed: () => _openBlockDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (appointments.isEmpty) {
      return const Center(
        child: Text(
          'No hay citas este día',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: appointments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final a = appointments[i];
        return AppointmentTile(
          appointment: a,
          onDone: () async {
            await _agenda.updateStatus(selectedDate, a.time, 'done');
            if (!mounted) return;
            _load();
          },
          onCancel: () async {
            await _agenda.updateStatus(selectedDate, a.time, 'cancelled');
            if (!mounted) return;
            _load();
          },
        );
      },
    );
  }

  // ================= Date =================

  Widget _buildDateHeader() {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _prettyDate(selectedDate),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  selectedDate,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _changeDay(-1),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => _changeDay(1),
            ),
          ],
        ),
      ),
    );
  }

  void _changeDay(int diff) {
    final date = DateTime.parse(selectedDate).add(Duration(days: diff));
    selectedDate = _keyFromDate(date);
    if (!mounted) return;
    _load();
  }

  // ================= Block Dialog =================

  void _openBlockDialog(BuildContext context) {
    TimeOfDay? from;
    TimeOfDay? to;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: const Text('Bloquear horario'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('Desde'),
                    trailing: Text(from?.format(context) ?? '--:--'),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setLocal(() => from = picked);
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('Hasta'),
                    trailing: Text(to?.format(context) ?? '--:--'),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setLocal(() => to = picked);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: from == null || to == null
                      ? null
                      : () async {
                    await BlockService().blockTime(
                      date: DateTime.parse(selectedDate),
                      from: _fmt(from!),
                      to: _fmt(to!),
                      reason: 'Bloqueado manual',
                    );

                    if (!mounted) return;

                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    _load();
                  },
                  child: const Text('Bloquear'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================= Utils =================

  String _todayKey() => _keyFromDate(DateTime.now());

  String _keyFromDate(DateTime d) =>
      '${d.year}-${_two(d.month)}-${_two(d.day)}';

  String _two(int n) => n.toString().padLeft(2, '0');

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _prettyDate(String key) {
    final d = DateTime.parse(key);
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${d.day} de ${months[d.month - 1]} ${d.year}';
  }
}
