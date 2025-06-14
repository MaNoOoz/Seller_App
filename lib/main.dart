import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/bindings/app_bindings.dart';
import 'app/utils/constants.dart';
import 'app/utils/theme_service.dart';
import 'app/utils/app_themes.dart'; // Import the new AppThemes class
import 'app/views/user_app/screens/controllers/cart_controller.dart';
import 'firebase_options.dart';
import 'app/routes/app_pages.dart';
import 'app/controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await GetStorage.init(); // Initialize GetStorage for ThemeService

  // Initialize AuthController and ThemeService
  // Get.put(AuthController());
  Get.put(ThemeService()); // Initialize ThemeService
  Get.put(CartController()); // Make it available globally

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeService themeService = Get.find<ThemeService>();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "User App",
      initialRoute: Routes.HOME,
      getPages: AppPages.routes,
      initialBinding:AppBindings(),

      // Theme configuration now references AppThemes class
      themeMode: themeService.themeMode,
      theme: AppThemes.myCustomTheme,
      // Use the light theme from AppThemes
      darkTheme: AppThemes.darkTheme,
      // Use the dark theme from AppThemes

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
    );
  }


// }
}
