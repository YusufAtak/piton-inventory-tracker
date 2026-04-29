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
    if (_noteController.text.isEmpty || _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a note and a photo')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child('maintenance_photos/$fileName');

      String downloadUrl;
      if (kIsWeb) {
        TaskSnapshot snapshot = await storageRef.putData(_webImage);
        downloadUrl = await snapshot.ref.getDownloadURL();
      } else {
        TaskSnapshot snapshot = await storageRef.putFile(File(_pickedFile!.path));
        downloadUrl = await snapshot.ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('MaintenanceLogs').add({
        'deviceId': widget.deviceId,
        'deviceName': widget.deviceName,
        'note': _noteController.text.trim(),
        'photoUrl': downloadUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'personnelEmail': FirebaseAuth.instance.currentUser?.email,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maintenance report submitted!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Repair: ${widget.deviceName}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _pickedFile == null
                  ? const Center(child: Text('No photo selected.'))
                  : kIsWeb
                  ? Image.memory(_webImage, fit: BoxFit.cover)
                  : Image.file(File(_pickedFile!.path), fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt),
              label: Text(kIsWeb ? 'Select Photo' : 'Take Photo'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe the maintenance done...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            _isUploading
                ? const CircularProgressIndicator()
                : SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitReport,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                child: const Text('SUBMIT REPORT', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}