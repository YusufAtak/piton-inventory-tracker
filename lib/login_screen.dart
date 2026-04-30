import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart'; // ÇEVİRİ İÇİN EKLENDİ
import 'admin_dashboard.dart';
import 'personnel_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();

    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('empty_fields_error'.tr())), // ÇEVİRİ EKLENDİ
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      var userQuery = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: _emailController.text.trim())
          .get();

      if (userQuery.docs.isNotEmpty) {
        String userRole = userQuery.docs.first.get('role');

        if (mounted) {
          if (userRole.toLowerCase() == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminDashboard()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PersonnelDashboard()),
            );
          }
        }
      } else {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('role_error'.tr())), // ÇEVİRİ EKLENDİ
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        // Firebase Auth hataları için basit hata yönetimi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'unexpected_error'.tr()} ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'unexpected_error'.tr()} $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // DİL DEĞİŞTİRME BUTONU BURAYA EKLENDİ
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {
              // Mevcut dil Türkçe ise İngilizce yap, İngilizce ise Türkçe yap
              if (context.locale == const Locale('tr')) {
                context.setLocale(const Locale('en'));
              } else {
                context.setLocale(const Locale('tr'));
              }
            },
            icon: const Icon(Icons.language, color: Colors.blueGrey),
            label: Text(
              context.locale.languageCode.toUpperCase(), // Ekranda TR veya EN yazar
              style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.build_circle_outlined, size: 100, color: Colors.blueGrey),
                const SizedBox(height: 24),
                Text(
                  'app_title'.tr(), // ÇEVİRİ EKLENDİ
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),
                const SizedBox(height: 48),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  decoration: InputDecoration(
                    labelText: 'email'.tr(), // ÇEVİRİ EKLENDİ
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _login(),
                  decoration: InputDecoration(
                    labelText: 'password'.tr(), // ÇEVİRİ EKLENDİ
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blueGrey,
                  ),
                  child: Text(
                    'login_button'.tr(), // ÇEVİRİ EKLENDİ
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}