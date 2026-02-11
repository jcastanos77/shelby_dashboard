import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:typed_data';

class BarberFormPage extends StatefulWidget {
  const BarberFormPage({super.key});

  @override
  State<BarberFormPage> createState() => _BarberFormPageState();
}

class _BarberFormPageState extends State<BarberFormPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  Uint8List? previewBytes;

  final _db = FirebaseDatabase.instance.ref('barbers');

  bool saving = false;
  XFile? imageFile;

  final picker = ImagePicker();

  // ============================
  // PICK IMAGE (WEB SAFE)
  // ============================
  Future<void> _pickImage() async {
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 600,
    );

    if (picked == null) return;

    setState(() {
      imageFile = picked;
    });
  }

  // ============================
  // UPLOAD IMAGE (WEB SAFE)
  // ============================
  Future<String?> _uploadImage(String uid) async {
    if (imageFile == null) return null;

    final bytes = await imageFile!.readAsBytes();

    final ref =
    FirebaseStorage.instance.ref('barbers/$uid/profile.jpg');

    await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await ref.getDownloadURL();
  }

  // ============================
  // CREATE BARBER
  // ============================
  Future<void> _save() async {
    if (_name.text.isEmpty || _email.text.isEmpty) return;

    setState(() => saving = true);

    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: "123456",
      );

      final uid = cred.user!.uid;

      final photoUrl = await _uploadImage(uid);

      await _db.child(uid).set({
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'photoUrl': photoUrl ?? '',
        'role': 'barber',
        'active': true,
        'passwordDefault': true,
        'mpConnected': false,
      });

      imageFile = null;
      _name.clear();
      _email.clear();
      _phone.clear();

      _snack("Barbero creado 💈", Colors.green);
    } catch (e) {
      _snack("Error creando barbero", Colors.red);
    }

    if (mounted) {
      setState(() => saving = false);
    }
  }

  // ============================
  // EDIT BARBER
  // ============================
  Future<void> _editBarber(
      String uid,
      Map<String, dynamic> data,
      ) async {
    final name = TextEditingController(text: (data['name'] ?? '').toString());
    final phone = TextEditingController(text: (data['phone'] ?? '').toString());
    final currentPhoto = (data['photoUrl'] ?? '').toString();
    XFile? newImage;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (_, setLocal) {
            return Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  const Text(
                  "Editar barbero",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                GestureDetector(
                    onTap: () async {
                      final picked = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 70,
                      );

                      if (picked == null) return;

                      final bytes = await picked.readAsBytes();

                      setLocal(() {
                        newImage = picked;
                        previewBytes = bytes;
                      });
                    },
                    child: CircleAvatar(
                        radius: 45,
                        backgroundImage: previewBytes != null
                            ? MemoryImage(previewBytes!)
                            : (currentPhoto.isNotEmpty
                            ? CachedNetworkImageProvider(currentPhoto)
                            : null),

            child: (newImage == null &&
            currentPhoto.isEmpty)
            ? const Icon(Icons.camera_alt,
            color: Colors.white)
                : null,
            ),
            ),

            const SizedBox(height: 16),

            _input(name, "Nombre"),
            _input(phone, "Teléfono"),

            const SizedBox(height: 16),

            SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
            style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green),
            onPressed: () async {
            String photoUrl = currentPhoto;

            if (newImage != null) {
            final bytes =
            await newImage!.readAsBytes();

            final ref = FirebaseStorage.instance
                .ref('barbers/$uid/profile.jpg');

            await ref.putData(
            bytes,
            SettableMetadata(
            contentType: 'image/jpeg'),
            );

            photoUrl =
            await ref.getDownloadURL();
            }

            await _db.child(uid).update({
            'name': name.text,
            'phone': phone.text,
            'photoUrl': photoUrl,
            });

            if (mounted) {
            Navigator.pop(context);
            }
            },
            child: const Text(
            "Guardar",
            style: TextStyle(color: Colors.white),
            ),
            ),
            )
            ],
            ),
            );
          },
        );
      },
    );
  }

  // ============================
  // TOGGLE ACTIVE
  // ============================
  Future<void> _toggle(String uid, bool current) async {
    await _db.child(uid).update({'active': !current});
  }

  void _snack(String msg, Color c) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: c));
  }

  // ============================
  // UI
  // ============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barberos')),
      backgroundColor: const Color(0xFF0F0F0F),
      body: Column(
        children: [
          _buildForm(),
          const SizedBox(height: 12),
          Expanded(child: _buildBarbersList()),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[800],
              child: imageFile == null
                  ? const Icon(Icons.camera_alt,
                  color: Colors.white)
                  : const Icon(Icons.check,
                  color: Colors.green),
            ),
          ),
          const SizedBox(height: 16),
          _input(_name, "Nombre"),
          _input(_email, "Correo"),
          _input(_phone, "Teléfono"),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: saving ? null : _save,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green),
              child: saving
                  ? const CircularProgressIndicator(
                  color: Colors.white)
                  : const Text("Crear barbero",
                  style:
                  TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  Widget _input(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
          const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF222222),
          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildBarbersList() {
    return StreamBuilder(
      stream: _db.onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData ||
            snapshot.data!.snapshot.value == null) {
          return const Center(
              child: Text("Sin barberos"));
        }

        final raw = Map<String, dynamic>.from(
            snapshot.data!.snapshot.value as Map);

        final entries = raw.entries.toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (_, i) {
            final uid = entries[i].key;
            final map =
            Map<String, dynamic>.from(entries[i].value);

            final active = map['active'] == true;
            final photo =
            (map['photoUrl'] ?? '').toString();

            return GestureDetector(
              onTap: () => _editBarber(uid, map),
              child: Container(
                margin:
                const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.grey[800],
                    child: ClipOval(
                      child: photo.isNotEmpty
                          ? Image.network(
                        photo,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person, color: Colors.white);
                        },
                      )
                          : const Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                  title: Text(
                    map['name'] ?? '',
                    style: const TextStyle(
                        color: Colors.white),
                  ),
                  subtitle: Text(
                    map['email'] ?? '',
                    style: const TextStyle(
                        color: Colors.white54),
                  ),
                  trailing: Switch(
                    value: active,
                    onChanged: (_) =>
                        _toggle(uid, active),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
