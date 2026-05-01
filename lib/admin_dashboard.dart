import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart'; // ÇEVİRİ İÇİN EKLENDİ

import 'package:piton_tracker/login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {

  // --- CİHAZ EKLEME FONKSİYONU (ÇEVİRİ DESTEKLİ) ---
  Future<void> _showAddDeviceDialog() async {
    final TextEditingController deviceNameController = TextEditingController();
    final TextEditingController serialNumberController = TextEditingController();
    final TextEditingController typeController = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('add_new_device'.tr()), // ÇEVİRİ EKLENDİ
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: deviceNameController,
                      decoration: InputDecoration(
                        labelText: 'device_name_hint'.tr(), // ÇEVİRİ EKLENDİ
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: typeController,
                      decoration: InputDecoration(
                        labelText: 'device_type_hint'.tr(), // ÇEVİRİ EKLENDİ
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: serialNumberController,
                      decoration: InputDecoration(
                        labelText: 'serial_number_hint'.tr(), // ÇEVİRİ EKLENDİ
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
                  child: Text('cancel'.tr()),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                    if (deviceNameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('empty_device_name_error'.tr())), // ÇEVİRİ EKLENDİ
                      );
                      return;
                    }

                    setDialogState(() {
                      isSaving = true;
                    });

                    try {
                      await FirebaseFirestore.instance.collection('Inventory').add({
                        'deviceName': deviceNameController.text.trim(),
                        'type': typeController.text.trim(),
                        'serialNumber': serialNumberController.text.trim(),
                      });

                      if (context.mounted) {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('device_added_success'.tr())), // ÇEVİRİ EKLENDİ
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${'error'.tr()}: $e')),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setDialogState(() {
                          isSaving = false;
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                  child: isSaving
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : Text('save'.tr(), style: const TextStyle(color: Colors.white)), // ÇEVİRİ EKLENDİ
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- KULLANICI EKLEME FONKSİYONU ---
  Future<void> _showAddUserDialog() async {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    String selectedRole = 'Personel';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('add_new_user'.tr()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'email'.tr()),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: 'password_min_length'.tr()),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    decoration: InputDecoration(labelText: 'user_role'.tr()),
                    items: ['Personel', 'Admin'].map((String role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role == 'Personel' ? 'personnel'.tr() : 'admin'.tr()),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedRole = newValue!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('cancel'.tr()),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                  onPressed: () async {
                    if (emailController.text.trim().isEmpty ||
                        passwordController.text.trim().length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('invalid_email_password'.tr())),
                      );
                      return;
                    }

                    try {
                      FirebaseApp tempApp = await Firebase.initializeApp(
                        name: 'tempUserCreation',
                        options: Firebase.app().options,
                      );

                      UserCredential userCredential = await FirebaseAuth.instanceFor(app: tempApp)
                          .createUserWithEmailAndPassword(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );

                      await FirebaseFirestore.instance
                          .collection('Users')
                          .doc(userCredential.user!.uid)
                          .set({
                        'email': emailController.text.trim(),
                        'role': selectedRole,
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      await tempApp.delete();

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$selectedRole ${'successfully_created'.tr()}')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${'error'.tr()}: $e')),
                        );
                      }
                    }
                  },
                  child: Text('create_user'.tr(), style: const TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('admin_panel'.tr()),
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
          // --- CİHAZ EKLEME BUTONU ---
          IconButton(
            icon: const Icon(Icons.add_to_queue),
            tooltip: 'add_device_tooltip'.tr(), // ÇEVİRİ EKLENDİ
            onPressed: _showAddDeviceDialog,
          ),
          // KULLANICI EKLEME BUTONU
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'add_new_user'.tr(),
            onPressed: _showAddUserDialog,
          ),
          // ÇIKIŞ BUTONU
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('MaintenanceLogs')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('no_reports_yet'.tr()));
          }

          final logs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index].data() as Map<String, dynamic>;
              final deviceName = log['deviceName'] ?? 'unknown'.tr();
              final note = log['note'] ?? 'no_note'.tr();

              // Durumu çevirmek için kontrol
              String statusRaw = log['status'] ?? 'unknown'.tr();
              String statusTranslated = statusRaw;
              if (statusRaw == 'Çalışıyor') statusTranslated = 'working'.tr();
              if (statusRaw == 'Arızalı') statusTranslated = 'broken'.tr();
              if (statusRaw == 'Eksik') statusTranslated = 'missing'.tr();

              final photoUrl = log['photoUrl'];
              final personnelEmail = log['personnelEmail'] ?? 'unknown'.tr();

              final timestamp = log['timestamp'] as Timestamp?;
              String formattedDate = 'unknown_date'.tr();
              if (timestamp != null) {
                DateTime date = timestamp.toDate();
                formattedDate = '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(deviceName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${'status'.tr()}: $statusTranslated'),
                      Text('${'note'.tr()}: $note'),
                      Text('${'personnel'.tr()}: $personnelEmail'),
                      const SizedBox(height: 4),
                      Text('${'date'.tr()}: $formattedDate', style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  trailing: photoUrl != null
                      ? IconButton(
                    icon: const Icon(Icons.image, color: Colors.blueGrey),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          child: Image.network(photoUrl),
                        ),
                      );
                    },
                  )
                      : const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}