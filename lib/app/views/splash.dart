import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_pages.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  void _checkAuthState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        // No user signed in, go to login
        Get.offAllNamed(Routes.LOGIN);
      } else {
        // User signed in, check if they have a store
        // This is where you'd add logic to check if the current user (user.uid)
        // has an existing store in your 'stores' collection.
        // For now, let's assume they should go to the dashboard if logged in.
        // You might need a check like:
        // bool hasStore = await Get.find<ShopController>().checkIfUserHasStore(user.uid);
        // if (hasStore) {
        //   Get.offAllNamed(Routes.DASHBOARD);
        // } else {
        //   Get.offAllNamed(Routes.CREATE_STORE);
        // }
        Get.offAllNamed(Routes.DASHBOARD); // Default to dashboard for now
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Or a splash image/logo
      ),
    );
  }
}