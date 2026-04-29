import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'maintenance_logs_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _serialController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _addDevice() async {
    if (_nameController.text.trim().isEmpty ||
        _serialController.text.trim().isEmpty ||
        _typeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('Inventory').add({
        'deviceName': _nameController.text.trim(),
        'serialNumber': _serialController.text.trim(),
        'type': _typeController.text.trim(),
      });

      _nameController.clear();
      _serialController.clear();
      _typeController.clear();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Device added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding device: $e')),
        );
      }
    }
  }

  void _showAddDeviceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Device'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Device Name'),
              ),
              TextField(
                controller: _serialController,
                decoration: const InputDecoration(labelText: 'Serial Number'),
              ),
              TextField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Device Type (e.g., HMI, LCD)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _addDevice,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _serialController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard - Inventory'),
        backgroundColor: Colors.blueGrey,
        actions: [
          // Bakım Kayıtlarına giden yeni butonumuz
          IconButton(
            icon: const Icon(Icons.history_edu),
            tooltip: 'View Maintenance Logs',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MaintenanceLogsScreen()),
              );
            },
          ),
          // Çıkış yapma butonu
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Inventory').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading inventory'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<QueryDocumentSnapshot> inventoryDocs = snapshot.data!.docs;

          if (inventoryDocs.isEmpty) {
            return const Center(child: Text('No devices found in inventory.'));
          }

          return ListView.builder(
            itemCount: inventoryDocs.length,
            itemBuilder: (context, index) {
              var device = inventoryDocs[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.devices, color: Colors.blueGrey),
                  title: Text(device['deviceName']),
                  subtitle: Text('SN: ${device['serialNumber']} | Type: ${device['type']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('Inventory')
                          .doc(device.id)
                          .delete();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        onPressed: _showAddDeviceDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}