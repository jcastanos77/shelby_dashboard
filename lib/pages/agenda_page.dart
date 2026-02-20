import 'package:dashboard_barbershop/services/agenda_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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
  bool isFullDayBlocked = false;

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

  Future<void> _unblockFullDay() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final db = FirebaseDatabase.instance.ref();

    final snapshot = await db.child('appointments').get();

    if (!snapshot.exists) return;

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    for (final entry in data.entries) {
      final key = entry.key;
      final value = Map<String, dynamic>.from(entry.value);

      if (value['barberId'] == uid &&
          value['dateKey'] == selectedDate &&
          value['type'] == 'block') {
        await db.child('appointments').child(key).remove();
      }
    }

    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;

    setState(() => loading = true);

    final data = await _agenda.getAppointmentsByDate(selectedDate);

    // 🔥 verificar si todas son tipo block
    bool fullBlocked = false;

    if (data.isNotEmpty) {
      final blocks = data.where((a) =>
      a.status == 'blocked_day' ||
          a.type == 'block');

      if (blocks.length >= _workingHoursCount(DateTime.parse(selectedDate))) {
        fullBlocked = true;
      }
    }

    if (!mounted) return;

    setState(() {
      appointments = data;
      isFullDayBlocked = fullBlocked;
      loading = false;
    });
  }


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

          if (isFullDayBlocked)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.red.shade700,
              child: Column(
                children: [
                  const Text(
                    "🔴 DÍA COMPLETAMENTE BLOQUEADO",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                    ),
                    onPressed: _unblockFullDay,
                    child: const Text("Desbloquear día"),
                  ),
                ],
              ),
            ),

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

    if (isFullDayBlocked) {
      return const Center(
        child: Text(
          "No se pueden agendar citas este día",
          style: TextStyle(fontSize: 16, color: Colors.red),
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
            await _agenda.updateStatus(a.id, 'done');
            if (!mounted) return;
            _load();
          },
          onCancel: () async {
            await _agenda.updateStatus(a.id, 'cancelled');
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

    final uid = FirebaseAuth.instance.currentUser!.uid;

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

                  /// 🔥 BOTÓN BLOQUEAR DÍA COMPLETO
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.event_busy),
                      label: const Text("Bloquear día completo"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {

                        await BlockService().blockFullDay(
                          barberId: uid,
                          date: DateTime.parse(selectedDate),
                        );

                        if (!mounted) return;

                        Navigator.pop(context);
                        _load();
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),

                  /// 🔥 BLOQUEO POR RANGO NORMAL
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

                    Navigator.pop(context);
                    _load();
                  },
                  child: const Text('Bloquear rango'),
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

  int _workingHoursCount(DateTime date) {
    final workingHours = {
      1: [9,10,11,12,13,14,15,16,17,18,19,20],
      2: [9,10,11,12,13,14,15,16,17,18,19,20],
      3: [9,10,11,12,13,14,15,16,17,18,19,20],
      4: [9,10,11,12,13,14,15,16,17,18,19,20],
      5: [9,10,11,12,13,14,15,16,17,18,19,20],
      6: [9,10,11,12,13,14,15,16,17,18,19,20],
      7: [10,11,12,13,14,15,16],
    };

    return workingHours[date.weekday]?.length ?? 0;
  }

}
