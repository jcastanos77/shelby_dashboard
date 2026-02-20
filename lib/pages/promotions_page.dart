import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PromotionsPage extends StatefulWidget {
  const PromotionsPage({super.key});

  @override
  State<PromotionsPage> createState() => _PromotionsPageState();
}

class _PromotionsPageState extends State<PromotionsPage> {
  final ref = FirebaseDatabase.instance.ref('promotions');
  final picker = ImagePicker();

  Future<void> _addPromo() async {
    final XFile? picked =
    await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final bytes = await picked.readAsBytes(); // 🔥 clave para web

    final id = ref.push().key!;
    final storageRef =
    FirebaseStorage.instance.ref('promotions/$id.jpg');

    await storageRef.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final imageUrl = await storageRef.getDownloadURL();

    await ref.child(id).set({
      "imageUrl": imageUrl,
      "title": "Promo prueba",
      "ctaText": "Reserva ahora",
      "active": true,
      "order": DateTime.now().millisecondsSinceEpoch,
      "createdAt": DateTime.now().millisecondsSinceEpoch
    });
  }

  Future<void> _deletePromo(String key) async {
    await FirebaseStorage.instance
        .ref('promotions/$key.jpg')
        .delete()
        .catchError((_) {});
    await ref.child(key).remove();
  }

  bool _isExpired(Map data) {
    if (data['expiresAt'] == null) return false;
    return DateTime.now().millisecondsSinceEpoch >
        data['expiresAt'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Promociones")),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPromo,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: ref.orderByChild('order').onValue,
        builder: (_, snapshot) {
          if (!snapshot.hasData ||
              snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("Sin promociones"));
          }

          final raw = Map<String, dynamic>.from(
              snapshot.data!.snapshot.value as Map);

          final promos = raw.entries.toList()
            ..sort((a, b) =>
                b.value['order'].compareTo(a.value['order']));

          return ListView.builder(
            itemCount: promos.length,
            itemBuilder: (_, i) {
              final key = promos[i].key;
              final data =
              Map<String, dynamic>.from(promos[i].value);

              final expired = _isExpired(data);

              return Card(
                child: ListTile(
                  leading: Image.network(
                    data['imageUrl'],
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                  title: Text(data['title'] ?? "Sin título"),
                  subtitle: Text(
                    expired
                        ? "Expirada"
                        : data['active']
                        ? "Activa"
                        : "Inactiva",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: data['active'] && !expired,
                        onChanged: expired
                            ? null
                            : (val) {
                          ref.child(key)
                              .update({'active': val});
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red),
                        onPressed: () => _deletePromo(key),
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