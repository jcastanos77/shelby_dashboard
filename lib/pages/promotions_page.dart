import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  final ref = FirebaseDatabase.instance.ref('announcements');
  final picker = ImagePicker();

  Future<void> _addAnnouncement() async {
    final XFile? picked =
    await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final ctaController = TextEditingController();

    String selectedType = "promo";
    DateTime? expires;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text("Nuevo anuncio"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration:
                      const InputDecoration(labelText: "Tipo"),
                      items: const [
                        DropdownMenuItem(
                            value: "promo",
                            child: Text("Promoción")),
                        DropdownMenuItem(
                            value: "aviso", child: Text("Aviso")),
                        DropdownMenuItem(
                            value: "clase",
                            child: Text("Clase / Curso")),
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          selectedType = value!;
                        });
                      },
                    ),
                    TextField(
                      controller: titleController,
                      decoration:
                      const InputDecoration(labelText: "Título"),
                    ),
                    TextField(
                      controller: subtitleController,
                      decoration:
                      const InputDecoration(labelText: "Subtítulo"),
                    ),
                    TextField(
                      controller: ctaController,
                      decoration:
                      const InputDecoration(labelText: "Texto botón (opcional)"),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                          initialDate: DateTime.now()
                              .add(const Duration(days: 7)),
                        );
                        if (date != null) {
                          setModalState(() {
                            expires = date;
                          });
                        }
                      },
                      child: const Text("Seleccionar expiración"),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, false),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(context, true),
                  child: const Text("Guardar"),
                )
              ],
            );
          },
        );
      },
    );

    if (confirmed != true) return;

    final id = ref.push().key!;
    final storageRef =
    FirebaseStorage.instance.ref('announcements/$id.jpg');

    await storageRef.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final imageUrl = await storageRef.getDownloadURL();

    await ref.child(id).set({
      "type": selectedType,
      "title": titleController.text,
      "subtitle": subtitleController.text,
      "ctaText": ctaController.text,
      "imageUrl": imageUrl,
      "active": true,
      "expiresAt": expires?.millisecondsSinceEpoch,
      "createdAt": DateTime.now().millisecondsSinceEpoch
    });
  }

  Future<void> _delete(String key) async {
    await FirebaseStorage.instance
        .ref('announcements/$key.jpg')
        .delete()
        .catchError((_) {});
    await ref.child(key).remove();
  }

  bool _isExpired(Map data) {
    if (data['expiresAt'] == null) return false;
    return DateTime.now().millisecondsSinceEpoch >
        data['expiresAt'];
  }

  Color _typeColor(String type) {
    switch (type) {
      case "promo":
        return Colors.red;
      case "clase":
        return Colors.amber;
      case "aviso":
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: const Text("Anuncios y Novedades")),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAnnouncement,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: ref.onValue,
        builder: (_, snapshot) {
          if (!snapshot.hasData ||
              snapshot.data!.snapshot.value == null) {
            return const Center(
                child: Text("Sin anuncios"));
          }

          final raw = Map<String, dynamic>.from(
              snapshot.data!.snapshot.value as Map);

          final items = raw.entries.toList()
            ..sort((a, b) =>
                b.value['createdAt']
                    .compareTo(a.value['createdAt']));

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final key = items[i].key;
              final data =
              Map<String, dynamic>.from(items[i].value);

              final expired = _isExpired(data);

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: Image.network(
                    data['imageUrl'],
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                  title: Text(data['title'] ?? ""),
                  subtitle: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(data['subtitle'] ?? ""),
                      const SizedBox(height: 4),
                      Container(
                        padding:
                        const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _typeColor(
                              data['type'] ?? "aviso")
                              .withOpacity(.2),
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        child: Text(
                          data['type']
                              .toString()
                              .toUpperCase(),
                          style: TextStyle(
                            color: _typeColor(
                                data['type'] ?? "aviso"),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (expired)
                        const Text(
                          "EXPIRADO",
                          style: TextStyle(
                              color: Colors.red),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: data['active'] == true &&
                            !expired,
                        onChanged: expired
                            ? null
                            : (val) {
                          ref
                              .child(key)
                              .update(
                              {'active': val});
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () =>
                            _delete(key),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}