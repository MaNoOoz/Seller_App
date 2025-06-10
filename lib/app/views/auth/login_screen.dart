import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../routes/app_pages.dart';

class LoginScreen extends StatelessWidget {
  final AuthController authController = Get.find(); // Change here

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('تسجيل الدخول')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'البريد الإلكتروني'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'كلمة المرور'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                authController.login(emailController.text.trim(), passwordController.text.trim());
              },
              child: Text('دخول'),
            ),
            SizedBox(height: 24),
            TextButton(
              onPressed: () {
                Get.toNamed(Routes.REGISTER);
              },
              child: Text('ليس لديك حساب؟ سجل الآن'),
            ),
            Obx(() {
              if (authController.isLoading.value) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                );
              }
              return Container();
            }),
            Obx(() {
              if (authController.error.value.isNotEmpty) {
                return Text(authController.error.value, style: TextStyle(color: Colors.red));
              }
              return Container();
            }),
          ],
        ),
      ),
    );
  }
}
