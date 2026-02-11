import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BarberGalleryPage extends StatefulWidget {
  const BarberGalleryPage({super.key});

  @override
  State<BarberGalleryPage> createState() => _BarberGalleryPageState();
}

class _BarberGalleryPageState extends State<BarberGalleryPage> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final _db = FirebaseDatabase.instance.ref('barberGallery');
  final picker = ImagePicker();

  bool uploading = false;

  // ==========================
  // 📸 PICK & UPLOAD
  // ==========================
  Future<void> _addPhoto() async {
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1000,
    );

    if (picked == null) return;

    setState(() => uploading = true);

    try {
      final bytes = await picked.readAsBytes();

      final imageId = DateTime.now().millisecondsSinceEpoch.toString();

      final storageRef = FirebaseStorage.instance
          .ref('barbers/$uid/gallery/$imageId.jpg');

      await storageRef.putData(bytes);

      final url = await storageRef.getDownloadURL();

      await _db.child(uid).child(imageId).set({
        'url': url,
        'createdAt': ServerValue.timestamp,
      });

    } catch (e) {
      _snack("Error subiendo imagen", Colors.red);
    }

    setState(() => uploading = false);
  }

  // ==========================
  // 🗑 DELETE
  // ==========================
  Future<void> _deletePhoto(String imageId, String url) async {
    await FirebaseStorage.instance
        .ref('barbers/$uid/gallery/$imageId.jpg')
        .delete();

    await _db.child(uid).child(imageId).remove();
  }

  void _snack(String msg, Color c) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: c));
  }

  // ==========================
  // UI
  // ==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text("Mi Galería"),
        backgroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: uploading ? null : _addPhoto,
        child: uploading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: _db.child(uid).onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.data!.snapshot.value == null) {
            return const Center(
              child: Text(
                "No hay fotos aún",
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          final raw = Map<String, dynamic>.from(
              snapshot.data!.snapshot.value as Map);

          final entries = raw.entries.toList()
            ..sort((a, b) =>
                b.value['createdAt']
                    .compareTo(a.value['createdAt']));

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (_, i) {
              final imageId = entries[i].key;
              final url = entries[i].value['url'];

              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, __, ___) =>
                      const Icon(Icons.error),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () =>
                          _deletePhoto(imageId, url),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius:
                          BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }
}
