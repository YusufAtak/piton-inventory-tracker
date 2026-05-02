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
  String? _selectedDevice;
  final TextEditingController _noteController = TextEditingController();
  XFile? _imageFile;
  bool _isLoading = false;

  // Firestore'da raporların tutarlı olması için
  // veritabanına yazılacak çekirdek verileri (raw data) sabit tutuyoruz.
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
    // Form Doğrulama
    if (_selectedDevice == null || _noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('empty_device_note_error'.tr())),
      );
      return;
    }

    // Eğer cihaz 'Arızalı' olarak raporlanıyorsa,
    // saha personelinin görsel kanıt (fotoğraf) sunması zorunludur.
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

      // Eğer fotoğraf çekildiyse Firebase Storage'a yüklenir.
      if (_imageFile != null) {
        // Dosyaların birbiri üzerine yazılmasını (overwrite) engellemek için benzersiz bir timestamp ismi kullanıyoruz.
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('maintenance_photos')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        // Flutter Web ve Mobil platformlarının dosya okuma mimarileri farklıdır.
        // Çökmeleri önlemek için kIsWeb ile platforma özel upload işlemi yapıyoruz.
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

      // Raporun Kaydedilmesi
      // Verinin güvenliğini sağlamak için cihazın yerel saati yerine sunucu saati (serverTimestamp) kullanılır.
      await FirebaseFirestore.instance.collection('MaintenanceLogs').add({
        'deviceName': _selectedDevice,
        'note': _noteController.text.trim(),
        'status': _selectedStatus,
        'photoUrl': imageUrl,
        'personnelEmail': user?.email ?? 'unknown'.tr(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Başarılı işlem sonrası Form (UI) temizlenir.
      _noteController.clear();
      setState(() {
        _selectedDevice = null;
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
          TextButton(
            onPressed: () {
              // Uygulama yeniden başlatılmadan anlık dil değişimi.
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
              // Oturumu kapatıp Navigation Stack'i tamamen temizliyoruz.
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
            // Saha personelinin cihaz listesi koda gömülü değildir. Doğrudan Firestore'dan alınır.
            // Bu sayede Admin sisteme yeni bir cihaz eklediğinde, personelin ekranı anında güncellenir.
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

                // Veritabanındaki eski kayıtlarda 'type' alanı olmayabilir.
                // Uygulamanın NullPointerException ile çökmesini engellemek için güvenli parsing yapıyoruz.
                final envanterListesi = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final deviceName = data['deviceName']?.toString() ?? 'Bilinmeyen Cihaz';
                  final type = data.containsKey('type') ? data['type'].toString() : '';

                  if (type.isNotEmpty) {
                    return '$deviceName [$type]';
                  }
                  return deviceName;
                }).toList();

                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'device_name'.tr(),
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

            // Durum Seçimi
            DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'device_status'.tr(),
                border: const OutlineInputBorder(),
              ),
              items: _statusList.map((String status) {
                // Veritabanında veri bütünlüğünü sağlamak için kayıtlar standart (TR) tutulur,
                // ancak ekranda kullanıcının seçtiği dile (Locale) göre çevrilerek gösterilir.
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
                  // Cihaz durumu 'Arızalı' olmaktan çıkarsa, yüklenmiş olan fotoğrafı bellekten temizleriz.
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