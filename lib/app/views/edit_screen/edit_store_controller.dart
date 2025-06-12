import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // For TextEditingController
import 'package:get/get.dart' hide MultipartFile, FormData; // hide to avoid conflict with dio
import 'package:file_selector/file_selector.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../routes/app_pages.dart';
import '../../utils/constants.dart'; // Import Routes for navigation

class EditStoreController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger logger = Logger();

  // Observable state for UI
  var isLoading = false.obs;
  var error = ''.obs;
  var logoFile = Rx<XFile?>(null); // For new selected logo
  var currentLogoUrl = ''.obs; // To display current logo from Firestore

  // Text editing controllers for form fields
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController phoneController;
  late TextEditingController cityController;
  late TextEditingController locationController;

  // Social Media Platforms
  var socialPlatforms = [
    'Facebook', 'Twitter', 'Instagram', 'LinkedIn', 'WhatsApp',
    'YouTube', 'TikTok', 'Snapchat', 'Pinterest', 'Reddit', 'Telegram', 'Discord', 'GitHub'
  ].obs;  // List of supported platforms


  var selectedPlatform = ''.obs; // Platform selected by user
  final RxList<MapEntry<String, TextEditingController>> socialControllers = <MapEntry<String, TextEditingController>>[].obs;


  String? _storeDocId; // The ID of the current store document

  @override
  void onInit() {
    super.onInit();
    // Initialize controllers
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    phoneController = TextEditingController();
    cityController = TextEditingController();
    locationController = TextEditingController();
    logger.d('EditStoreController: onInit called.'); // <-- Add this

    // Check if a storeId was passed as an argument
    if (Get.arguments != null && Get.arguments is Map && Get.arguments['${AppConstants.storeIdField}'] != null) {
      _storeDocId = Get.arguments['${AppConstants.storeIdField}'] as String;
      fetchStoreDataById(_storeDocId!); // Fetch data using the provided ID
    } else {
      logger.d('EditStoreController: No shopId argument found, fetching by UID.'); // <-- Add this

      // Fallback: If no shopId, try to find the user's store by UID
      fetchStoreDataByUid();
    }
  }

  @override
  void onClose() {
    // Dispose all TextEditingControllers
    nameController.dispose();
    descriptionController.dispose();
    phoneController.dispose();
    cityController.dispose();
    locationController.dispose();
    for (var entry in socialControllers) {
      // entry.key.dispose();
      entry.value.dispose();
    }
    socialControllers.close(); // Dispose RxList
    logoFile.close(); // Dispose Rx
    currentLogoUrl.close(); // Dispose Rx
    super.onClose();
  }
  // --- Add Social Link ---
  void addSocialLink() {
    if (selectedPlatform.value.isNotEmpty) {
      socialControllers.add(MapEntry(selectedPlatform.value, TextEditingController()));
    }
  }
  // --- Remove Social Link ---
  void removeSocialLink(int index) {
    socialControllers.removeAt(index);
  }
  // --- Data Fetching by Document ID ---
  // --- Fetch Store Data ---
  Future<void> fetchStoreDataById(String docId) async {
    isLoading.value = true;
    error.value = '';
    try {
      final DocumentSnapshot doc = await _firestore.collection('stores').doc(docId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _storeDocId = doc.id; // Set the doc ID

        nameController.text = data['name'] ?? '';
        descriptionController.text = data['description'] ?? '';
        phoneController.text = data['phone'] ?? '';
        cityController.text = data['city'] ?? '';
        locationController.text = data['location'] ?? '';
        currentLogoUrl.value = data['logo_url'] ?? ''; // Display current logo

        // Populate social links
        final Map<String, dynamic>? socialMap = data['social'] is Map ? (data['social'] as Map<String, dynamic>) : null;
        if (socialMap != null) {
          socialControllers.clear(); // Clear existing if any
          socialMap.forEach((key, value) {
            socialControllers.add(MapEntry(key, TextEditingController(text: value)));
          });
        }
      } else {
        error.value = 'لم يتم العثور على بيانات المتجر بالمعرف المحدد.';
        fetchStoreDataByUid(); // Fallback to UID search
      }
    } catch (e) {
      error.value = 'فشل في جلب بيانات المتجر بالمعرف: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // --- Data Fetching by User UID (as a fallback) ---
  Future<void> fetchStoreDataByUid() async {
    isLoading.value = true;
    error.value = '';
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }

      final querySnapshot = await _firestore
          .collection('stores') // Consistent with 'stores'
          .where('created_by', isEqualTo: uid) // Consistent with 'created_by'
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        _storeDocId = doc.id; // Save the document ID

        // Populate controllers with existing data
        nameController.text = data['name'] ?? '';
        descriptionController.text = data['description'] ?? '';
        phoneController.text = data['phone'] ?? '';
        cityController.text = data['city'] ?? '';
        locationController.text = data['location'] ?? '';
        currentLogoUrl.value = data['logo_url'] ?? ''; // Display current logo

        // Populate social links
        final Map<String, dynamic>? socialMap = data['social'] is Map
            ? (data['social'] as Map<String, dynamic>)
            : null;
        if (socialMap != null) {
          socialControllers.clear(); // Clear existing if any
          socialMap.forEach((key, value) {
            socialControllers.add(
              MapEntry(key, TextEditingController(text: value)),
            );
          });
        }
      } else {
        error.value = 'لم يتم العثور على بيانات المتجر المرتبطة بحسابك.';
        // This case should ideally be handled by AuthController directing to NoAccessScreen
        // but good to have a fallback message here.
      }
    } catch (e) {
      logger.e('Error fetching store data by UID: $e');
      error.value = 'فشل في جلب بيانات المتجر بالـ UID: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // --- Image Picking ---
  Future<void> pickLogo() async {
    final typeGroup = XTypeGroup(label: 'images', extensions: ['png', 'jpg', 'jpeg']);
    final result = await openFile(acceptedTypeGroups: [typeGroup]);
    if (result != null) {
      logoFile.value = result;
    }
  }

  // --- Cloudinary Upload ---
  // --- MODIFIED: Image Picking and Upload for Logo with Folder ---
  Future<String?> _uploadImageToCloudinary(XFile file) async {
    // Ensure _storeDocId is available for folder organization
    if (_storeDocId == null) {
      error.value = 'خطأ: معرف المتجر غير متوفر لرفع الشعار.';
      return null;
    }

    // Define the folder structure for store logos
    final String cloudinaryFolder = '${AppConstants.storeLogosFolder}/$_storeDocId';

    try {
      final dio = Dio();
      Uint8List? fileBytes;
      String? filePath;

      if (GetPlatform.isWeb || GetPlatform.isMacOS || GetPlatform.isWindows || GetPlatform.isLinux) {
        fileBytes = await file.readAsBytes();
      } else if (GetPlatform.isAndroid || GetPlatform.isIOS) {
        filePath = file.path;
      } else {
        throw UnsupportedError('Unsupported platform for file upload.');
      }

      FormData formData;
      if (fileBytes != null) {
        formData = FormData.fromMap({
          'file': MultipartFile.fromBytes(fileBytes, filename: file.name),
          'upload_preset': AppConstants.cloudinaryUploadPreset,
          'folder': cloudinaryFolder, // <--- ADDED: Specify the folder
        });
      } else if (filePath != null) {
        formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(filePath, filename: file.name),
          'upload_preset': AppConstants.cloudinaryUploadPreset,
          'folder': cloudinaryFolder, // <--- ADDED: Specify the folder
        });
      } else {
        throw Exception('No file data available for upload.');
      }

      final response = await dio.post(
        AppConstants.cloudinaryUploadUrl,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200) {
        logger.d('Cloudinary logo upload successful: ${response.data['secure_url']}');
        return response.data['secure_url'];
      } else {
        logger.e('Cloudinary logo upload failed: ${response.statusCode} - ${response.data}');
        error.value = 'فشل تحميل الصورة: ${response.data['error']['message'] ?? 'خطأ غير معروف'}';
        return null;
      }
    } catch (e) {
      logger.e('Cloudinary logo upload error: $e');
      error.value = 'خطأ في رفع الصورة: ${e.toString()}';
      return null;
    }
  }

  // --- Update Store Data ---
  Future<void> updateStore() async {
    isLoading.value = true;
    error.value = '';
    try {
      if (_storeDocId == null) {
        throw Exception('معرف المتجر غير متوفر. لا يمكن التحديث.');
      }

      String? newLogoUrl = currentLogoUrl.value; // Start with current URL

      // If a new logo file is selected, upload it
      if (logoFile.value != null) {
        final uploadedUrl = await _uploadImageToCloudinary(logoFile.value!);
        if (uploadedUrl == null) {
          throw Exception('فشل في رفع الشعار الجديد.');
        }
        newLogoUrl = uploadedUrl;
      }

      // Prepare social links map
      final Map<String, String> socialLinksMap = {};
      for (var entry in socialControllers) {
        final key = entry.key.trim();
        final value = entry.value.text.trim();
        if (key.isNotEmpty && value.isNotEmpty) {
          socialLinksMap[key] = value;
        }
      }

      await _firestore.collection('stores').doc(_storeDocId).update({
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'phone': phoneController.text.trim(),
        'city': cityController.text.trim(),
        'location': locationController.text.trim(),
        'logo_url': newLogoUrl, // Update logo URL
        'social': socialLinksMap,
        'updated_at': FieldValue.serverTimestamp(), // Add an update timestamp
      });

      Get.snackbar('نجاح', 'تم تحديث بيانات المتجر بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primaryContainer,
          colorText: Get.theme.colorScheme.onPrimaryContainer);

      Get.back(); // Go back to Dashboard after successful update
      Get.toNamed(Routes.DASHBOARD);

      Get.toNamed(Routes.DASHBOARD);
    } on Exception catch (e) {
      logger.e('Error updating store: $e');
      error.value = e.toString();
    } catch (e) {
      logger.e('Unexpected error updating store: $e');
      error.value = 'حدث خطأ غير متوقع: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // --- Social Links Management ---




  // --- Product/Offer Navigation Placeholders ---
  void goToAddProduct() {
    if (_storeDocId == null) {
      Get.snackbar('خطأ', 'يرجى حفظ بيانات المتجر أولاً لربط المنتجات.');
      return;
    }
    // You'll implement this navigation when you build the AddProductScreen
    Get.toNamed(Routes.ADD_PRODUCT, arguments: {'storeId': _storeDocId});
  }

  void goToProductsList() {
    if (_storeDocId == null) {
      Get.snackbar('خطأ', 'يرجى حفظ بيانات المتجر أولاً لعرض المنتجات.');
      return;
    }
    // You'll implement this navigation when you build the ProductsListScreen
    Get.toNamed(Routes.PRODUCTS_LIST, arguments: {'storeId': _storeDocId});
  }

  void goToAddOffer() {
    if (_storeDocId == null) {
      Get.snackbar('خطأ', 'يرجى حفظ بيانات المتجر أولاً لربط العروض.');
      return;
    }
    // You'll implement this navigation when you build the AddOfferScreen
    Get.toNamed(Routes.ADD_OFFER, arguments: {'storeId': _storeDocId});
  }

// In EditStoreController.dart
  void goToOffersList() {
    if (_storeDocId == null) return;
    Get.toNamed(Routes.OFFERS_LIST, arguments: {'storeId': _storeDocId});
  }
}