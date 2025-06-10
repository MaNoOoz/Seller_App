// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart'; // <--- NEW IMPORT: Import the generated Firebase options file
import 'app/routes/app_pages.dart';
import 'app/controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // <--- IMPORTANT CHANGE: Initialize Firebase with options ---
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Pass the current platform's options
  );
  // --- END IMPORTANT CHANGE ---

  await GetStorage.init(); // Initialize GetStorage

  Get.put(AuthController());

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Store Management App",
      initialRoute: Routes.SPLASH,
      getPages: AppPages.routes,

      locale: const Locale('ar', 'AE'),
      fallbackLocale: const Locale('en', 'US'),

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'AE'),
        Locale('en', 'US'),
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade800),
        useMaterial3: true,
      ),
    ),
  );
}