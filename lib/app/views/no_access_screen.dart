// lib/seller_app/views/no_access_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart'; // Assuming AuthController handles logout

class NoAccessScreen extends StatelessWidget {
  const NoAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find(); // Get the AuthController

    return Scaffold(
      appBar: AppBar(title: const Text('لا يوجد متجر مرتبط')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.store_mall_directory_outlined,
                size: 100,
                color: Colors.grey,
              ),
              const SizedBox(height: 20),
              const Text(
                'يبدو أنه لا يوجد متجر مرتبط بحسابك الحالي.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'إذا كنت تعتقد أن هذا خطأ، يرجى التواصل مع الإدارة.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  authController.logout(); // Allow user to logout
                },
                child: const Text('تسجيل الخروج'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  // Option to contact admin, e.g., via email or a support form
                  // launchUrl(Uri.parse('mailto:admin@your-app.com?subject=No Store Access'));
                  Get.snackbar('تواصل معنا', 'سيتم تفعيل هذه الميزة قريباً للتواصل مع الإدارة.');
                },
                child: const Text('تواصل مع الإدارة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}