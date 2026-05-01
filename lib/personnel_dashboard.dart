import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:easy_localization/easy_localization.dart';

import 'package:piton_tracker/login_screen.dart';

class PersonnelDashboard extends StatefulWidget {
  const PersonnelDashboard({super.key});

  @override
  State<PersonnelDashboard> createState() => _PersonnelDashboardState();
}

class _PersonnelDashboardState extends State<PersonnelDashboard> {
  String? _selectedDevice; // Eski _deviceController yerine bu eklendi
  final TextEditingController _noteController = TextEditingController();
  XFile? _imageFile;
  bool _isLoading = false;

  // Veritabanına kaydedilecek orijinal değerler
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
    // Doğrulama kontrolü Dropdown'a göre güncellendi
    if (_selectedDevice == null || _noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('empty_device_note_error'.tr())),
      );
      return;
    }

    if (_selectedStatus == 'Arızalı' && _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('photo_required_error'.tr())),
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
        'deviceName': _selectedDevice, // Artık seçim listesinden geliyor
        'note': _noteController.text.trim(),
        'status': _selectedStatus,
        'photoUrl': imageUrl,
        'personnelEmail': user?.email ?? 'unknown'.tr(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      _noteController.clear();
      setState(() {
        _selectedDevice = null; // Gönderim sonrası seçim sıfırlanıyor
        _imageFile = null;
        _selectedStatus = 'Çalışıyor';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('report_sent_success'.tr())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'error'.tr()}: $e')),
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
    // _deviceController dispose işlemi kaldırıldı
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('personnel_panel'.tr()),
        backgroundColor: Colors.blueGrey,
        actions: [
          // DİL DEĞİŞTİRME BUTONU
          TextButton(
            onPressed: () {
              if (context.locale == const Locale('tr')) {
                context.setLocale(const Locale('en'));
              } else {
                context.setLocale(const Locale('tr'));
              }
            },
            child: Text(
              context.locale.languageCode.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'logout'.tr(),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                );
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
            // --- YENİ EKLENEN CANLI ENVANTER DROPDOWN ALANI ---
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Inventory').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Text('Envanter bulunamadı. Lütfen Firebase\'e cihaz ekleyin.'),
                  );
                }

                // Firebase'den gelen belgeleri Listeye çevir (Artık TYPE bilgisini de alıyoruz)
                final envanterListesi = snapshot.data!.docs.map((doc) {
                  // Veriyi güvenli bir şekilde Map'e çeviriyoruz
                  final data = doc.data() as Map<String, dynamic>;

                  final deviceName = data['deviceName']?.toString() ?? 'Bilinmeyen Cihaz';

                  // Eğer type alanı veritabanında varsa al, yoksa boş bırak (Crash olmasını önler)
                  final type = data.containsKey('type') ? data['type'].toString() : '';

                  // Eğer type doluysa ismin yanına köşeli parantez içinde ekle
                  if (type.isNotEmpty) {
                    return '$deviceName [$type]';
                  }

                  return deviceName; // Type yoksa sadece ismini döndür
                }).toList();

                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'device_name'.tr(), // Dil dosyandaki key'i koruduk
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.devices_other),
                  ),
                  initialValue: _selectedDevice,
                  isExpanded: true,
                  items: envanterListesi.map((String cihaz) {
                    return DropdownMenuItem<String>(
                      value: cihaz,
                      child: Text(cihaz),
                    );
                  }).toList(),
                  onChanged: (String? yeniDeger) {
                    setState(() {
                      _selectedDevice = yeniDeger;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            // --- MEVCUT DURUM SEÇİM ALANI ---
            DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'device_status'.tr(),
                border: const OutlineInputBorder(),
              ),
              items: _statusList.map((String status) {
                // Veritabanı değerine göre ekranda çevirisini gösteriyoruz
                String translatedStatus = status;
                if (status == 'Çalışıyor') translatedStatus = 'working'.tr();
                if (status == 'Arızalı') translatedStatus = 'broken'.tr();
                if (status == 'Eksik') translatedStatus = 'missing'.tr();

                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(translatedStatus),
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
              decoration: InputDecoration(
                labelText: 'note_detail'.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedStatus == 'Arızalı') ...[
              ElevatedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: Text('take_photo_required'.tr()),
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
                  : Text('submit_report'.tr(), style: const TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}