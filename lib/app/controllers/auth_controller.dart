import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../routes/app_pages.dart';
import '../testers.dart';
import '../utils/constants.dart';
import '../views/no_access_screen.dart'; // New screen import

class AuthController extends GetxController {
  var isLoading = false.obs;
  var error = ''.obs;
  var logger = Logger();

  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void onInit() async {
    // await methodTset().generateTestStoreForCurrentUser();

    super.onInit();
    auth.authStateChanges().listen((User? user) async {
      if (user == null) {
        logger.d('المستخدم غير مسجل الدخول');
        Get.offAllNamed(Routes.LOGIN);
      } else {
        logger.d('المستخدم مسجل الدخول: ${user.uid}');
        bool hasStore = await _checkIfUserHasStore(user.uid);
        if (hasStore) {
          Get.offNamed(Routes.DASHBOARD);
        } else {
          // If the user doesn't have a store, redirect to no access screen
          Get.offNamed(Routes.NO_ACCESS); // Redirect to the NO_ACCESS route
        }
      }
    });

  }


  Future<bool> _checkIfUserHasStore(String uid) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection(AppConstants.storesCollection) // Use the stores collection constant
          .where('created_by', isEqualTo: uid) // Use 'created_by'
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      logger.e('Error checking for user store: $e');
      return false; // Assume no store on error
    }
  }

  void login(String email, String password) async {
    isLoading.value = true;
    error.value = '';
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      // Navigation handled by authStateChanges listener in onInit
    } on FirebaseAuthException catch (e) {
      error.value = e.message ?? 'حدث خطأ عند تسجيل الدخول';
    } catch (e) {
      error.value = 'حدث خطأ غير متوقع: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void register(String email, String password) async {
    try {
      isLoading.value = true;
      error.value = '';
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // After registration, the authStateChanges listener will trigger,
      // check for store, and then route to NO_ACCESS.
    } on FirebaseAuthException catch (e) {
      error.value = e.message ?? 'حدث خطأ عند إنشاء الحساب';
    } catch (e) {
      error.value = 'حدث خطأ غير متوقع: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    isLoading.value = true;
    try {
      await auth.signOut();
      // Navigation handled by authStateChanges listener
    } catch (e) {
      logger.e('Error during logout: $e');
      error.value = 'حدث خطأ عند تسجيل الخروج: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
