import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AddMaintenanceScreen extends StatefulWidget {
  final String deviceId;
  final String deviceName;

  const AddMaintenanceScreen({
    super.key,
    required this.deviceId,
    required this.deviceName,
  });

  @override
  State<AddMaintenanceScreen> createState() => _AddMaintenanceScreenState();
}

class _AddMaintenanceScreenState extends State<AddMaintenanceScreen> {
  final TextEditingController _noteController = TextEditingController();

  // Yeni: Cihaz durumu için değişken eklendi
  String _selectedStatus = 'Çalışıyor';
  final List<String> _statusOptions = ['Çalışıyor', 'Arızalı', 'Eksik'];

  XFile? _pickedFile;
  dynamic _webImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
    );

    if (image != null) {
      if (kIsWeb) {
        var f = await image.readAsBytes();
        setState(() {
          _webImage = f;
          _pickedFile = image;
        });
      } else {
        setState(() {
          _pickedFile = image;
        });
      }
    }
  }

  Future<void> _submitReport() async {
    // 1. Not alanı her zaman zorunlu
    if (_noteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir açıklama notu girin.')),
      );
      return;
    }

    // 2. MÜLAKAT KRİTERİ: Fotoğraf SADECE 'Arızalı' seçilirse zorunludur!
    if (_selectedStatus == 'Arızalı' && _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cihaz "Arızalı" ise fotoğraf eklemek zorunludur!')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      String? downloadUrl;

      // 3. Sadece fotoğraf seçilmişse Storage'a yükle (Çalışıyor/Eksik için boş geçebilir)
      if (_pickedFile != null) {
        String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        Reference storageRef = FirebaseStorage.instance.ref().child('maintenance_photos/$fileName');

        if (kIsWeb) {
          TaskSnapshot snapshot = await storageRef.putData(_webImage);
          downloadUrl = await snapshot.ref.getDownloadURL();
        } else {
          TaskSnapshot snapshot = await storageRef.putFile(File(_pickedFile!.path));
          downloadUrl = await snapshot.ref.getDownloadURL();
        }
      }

      // 4. Firestore'a Kayıt (Status alanı eklendi)
      await FirebaseFirestore.instance.collection('MaintenanceLogs').add({
        'deviceId': widget.deviceId,
        'deviceName': widget.deviceName,
        'status': _selectedStatus, // Mülakatta istenen durum bilgisi eklendi
        'note': _noteController.text.trim(),
        'photoUrl': downloadUrl, // Fotoğraf yoksa null olarak kaydedilecek
        'timestamp': FieldValue.serverTimestamp(),
        'personnelEmail': FirebaseAuth.instance.currentUser?.email,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rapor başarıyla gönderildi!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kontrol: ${widget.deviceName}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // YENİ EKLENEN DURUM SEÇİCİ (Dropdown)
            DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Cihaz Durumu',
                border: OutlineInputBorder(),
              ),
              items: _statusOptions.map((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStatus = newValue!;
                  // Durum değiştiğinde fotoğrafı temizle (İsteğe bağlı)
                  if (_selectedStatus != 'Arızalı') {
                    _pickedFile = null;
                    _webImage = null;
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            // Fotoğraf Alanı (Sadece Arızalı seçiliyse gösterilir/vurgulanır)
            if (_selectedStatus == 'Arızalı') ...[
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.redAccent, width: 2), // Zorunlu olduğunu belli etmek için kırmızı çerçeve
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _pickedFile == null
                    ? const Center(child: Text('Arıza Tespiti İçin Fotoğraf Zorunludur', style: TextStyle(color: Colors.redAccent)))
                    : kIsWeb
                    ? Image.memory(_webImage, fit: BoxFit.cover)
                    : Image.file(File(_pickedFile!.path), fit: BoxFit.cover),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: Text(kIsWeb ? 'Fotoğraf Seç' : 'Fotoğraf Çek'),
              ),
              const SizedBox(height: 16),
            ],

            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Yapılan işlemi veya arızayı açıklayın...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            _isUploading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('RAPORU GÖNDER', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}