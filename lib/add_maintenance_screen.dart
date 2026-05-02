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
  String _selectedStatus = 'Çalışıyor';
  final List<String> _statusOptions = ['Çalışıyor', 'Arızalı', 'Eksik'];

  XFile? _pickedFile;
  dynamic _webImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    // Flutter Web ve Mobil mimarilerinde dosya sistemleri farklı çalışır.
    // kIsWeb kontrolü ile platforma özel doğru veri kaynağına (Galeri veya Kamera) yönlendirme yapıyoruz.
    final XFile? image = await picker.pickImage(
      source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
    );

    if (image != null) {
      if (kIsWeb) {
        // Web ortamında dosyalar doğrudan path üzerinden okunamaz, byte dizisine çevrilmelidir.
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
    // Form Validasyonu
    if (_noteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir açıklama notu girin.')),
      );
      return;
    }

    // Donanım "Arızalı" olarak raporlanıyorsa, süreç güvenliği gereği fotoğraf sunulması zorunludur.
    // Bu kural backend'e gitmeden istemci (client) tarafında yakalanarak gereksiz sunucu yükü engellenir.
    if (_selectedStatus == 'Arızalı' && _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cihaz "Arızalı" ise fotoğraf eklemek zorunludur!')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      String? downloadUrl;

      // Sadece fotoğraf seçilmişse Firebase Storage upload işlemi başlatılır.
      if (_pickedFile != null) {
        // Overwrite (Üzerine yazma) durumlarını engellemek için epoch timestamp ile benzersiz dosya isimleri oluşturulur.
        String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        Reference storageRef = FirebaseStorage.instance.ref().child('maintenance_photos/$fileName');

        // Platforma göre upload türü (Data vs File) dinamik olarak ayarlanır.
        if (kIsWeb) {
          TaskSnapshot snapshot = await storageRef.putData(_webImage);
          downloadUrl = await snapshot.ref.getDownloadURL();
        } else {
          TaskSnapshot snapshot = await storageRef.putFile(File(_pickedFile!.path));
          downloadUrl = await snapshot.ref.getDownloadURL();
        }
      }

      // Timestamp telefonun  yerel saati yerine
      // veritabanı tutarlılığı için FieldValue.serverTimestamp() ile sunucu saatinden alınır.
      await FirebaseFirestore.instance.collection('MaintenanceLogs').add({
        'deviceId': widget.deviceId,
        'deviceName': widget.deviceName,
        'status': _selectedStatus,
        'note': _noteController.text.trim(),
        'photoUrl': downloadUrl,
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
                  // Kullanıcı durumu 'Arızalı'dan başka bir şeye çevirirse,
                  // yanlışlıkla yüklenmiş/çekilmiş fotoğrafı bellekten temizliyoruz.
                  if (_selectedStatus != 'Arızalı') {
                    _pickedFile = null;
                    _webImage = null;
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            // Sadece cihaz durumu 'Arızalı' seçildiğinde render edilir.
            if (_selectedStatus == 'Arızalı') ...[
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.redAccent, width: 2),
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