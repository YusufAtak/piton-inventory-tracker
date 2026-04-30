import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class PersonnelDashboard extends StatefulWidget {
  const PersonnelDashboard({super.key});

  @override
  State<PersonnelDashboard> createState() => _PersonnelDashboardState();
}

class _PersonnelDashboardState extends State<PersonnelDashboard> {
  final TextEditingController _deviceController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  XFile? _imageFile;
  bool _isLoading = false;

  String _selectedStatus = 'Çalışıyor';
  final List<String> _statusList = ['Çalışıyor', 'Arızalı', 'Eksik'];

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      setState(() {
        _imageFile = photo;
      });
    }
  }

  Future<void> _submitReport() async {
    if (_deviceController.text.trim().isEmpty || _noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen cihaz adını ve notunuzu girin.')),
      );
      return;
    }

    if (_selectedStatus == 'Arızalı' && _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cihaz arızalıysa fotoğraf eklemek zorunludur!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl;

      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('maintenance_photos')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        if (kIsWeb) {
          final bytes = await _imageFile!.readAsBytes();
          final uploadTask = await storageRef.putData(bytes);
          imageUrl = await uploadTask.ref.getDownloadURL();
        } else {
          final uploadTask = await storageRef.putFile(File(_imageFile!.path));
          imageUrl = await uploadTask.ref.getDownloadURL();
        }
      }

      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('MaintenanceLogs').add({
        'deviceName': _deviceController.text.trim(),
        'note': _noteController.text.trim(),
        'status': _selectedStatus,
        'photoUrl': imageUrl,
        'personnelEmail': user?.email ?? 'Bilinmiyor',
        'timestamp': FieldValue.serverTimestamp(),
      });

      _deviceController.clear();
      _noteController.clear();
      setState(() {
        _imageFile = null;
        _selectedStatus = 'Çalışıyor';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rapor başarıyla gönderildi!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata oluştu: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _deviceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personel Paneli - Rapor Ekle'),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _deviceController,
              decoration: const InputDecoration(
                labelText: 'Cihaz Adı',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Cihaz Durumu',
                border: OutlineInputBorder(),
              ),
              items: _statusList.map((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStatus = newValue!;
                  if (_selectedStatus != 'Arızalı') {
                    _imageFile = null;
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Not / Arıza Detayı',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedStatus == 'Arızalı') ...[
              ElevatedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Fotoğraf Çek (Zorunlu)'),
              ),
              const SizedBox(height: 16),
              if (_imageFile != null)
                kIsWeb
                    ? Image.network(
                  _imageFile!.path,
                  height: 200,
                  fit: BoxFit.cover,
                )
                    : Image.file(
                  File(_imageFile!.path),
                  height: 200,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: _isLoading ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('RAPORU GÖNDER', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}