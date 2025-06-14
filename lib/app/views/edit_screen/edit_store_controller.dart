import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // For TextEditingController
import 'package:get/get.dart' hide MultipartFile, FormData; // hide to avoid conflict with dio
import 'package:file_selector/file_selector.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../models.dart';
import '../../routes/app_pages.dart';
import '../../utils/constants.dart'; // Import Routes for navigation


class EditStoreController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger logger = Logger(
    printer: PrettyPrinter(methodCount:4),

  );

  // Observable state for UI
  var isLoading = false.obs;
  var error = ''.obs;
  var logoFile = Rx<XFile?>(null); // For new selected logo
  var currentLogoUrl = ''.obs; // To display current logo from Firestore

  // Text editing controllers for form fields
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController phoneController;
  late TextEditingController contactEmailController; // New
  late TextEditingController cityController;
  late TextEditingController locationController;
  late TextEditingController announcementMessageController; // New

  // New observable fields for StoreModel
  var deliveryOptions = <String>[].obs; // New
  var paymentMethods = <String>[].obs; // New
  // var workingHours = <String, String>{}.obs; // Removed
  var announcementActive = false.obs; // New
  var status = ''.obs; // New

  // Social Media Platforms
  var socialPlatforms = [
    'Facebook', 'Twitter', 'Instagram', 'LinkedIn', 'WhatsApp',
    'YouTube', 'TikTok', 'Snapchat', 'Pinterest', 'Reddit', 'Telegram', 'Discord', 'GitHub'
  ].obs;

  var selectedPlatform = ''.obs;
  final RxList<MapEntry<String, TextEditingController>> socialControllers = <MapEntry<String, TextEditingController>>[].obs;

  String? _storeDocId; // The ID of the current store document

  @override
  void onInit() {
    super.onInit();
    // Initialize controllers
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    phoneController = TextEditingController();
    contactEmailController = TextEditingController(); // Initialize new controller
    cityController = TextEditingController();
    locationController = TextEditingController();
    announcementMessageController = TextEditingController(); // Initialize new controller

    logger.d('EditStoreController: onInit called.');

    // Check if a storeId was passed as an argument
    if (Get.arguments != null && Get.arguments is Map && Get.arguments['${AppConstants.storeIdField}'] != null) {
      _storeDocId = Get.arguments['${AppConstants.storeIdField}'] as String;
      fetchStoreDataById(_storeDocId!);
    } else {
      logger.d('EditStoreController: No shopId argument found, fetching by UID.');
      fetchStoreDataByUid();
    }
  }

  @override
  void onClose() {
    // Dispose all TextEditingControllers
    nameController.dispose();
    descriptionController.dispose();
    phoneController.dispose();
    contactEmailController.dispose(); // Dispose new controller
    cityController.dispose();
    locationController.dispose();
    announcementMessageController.dispose(); // Dispose new controller

    for (var entry in socialControllers) {
      entry.value.dispose();
    }
    socialControllers.close();
    logoFile.close();
    currentLogoUrl.close();
    deliveryOptions.close(); // Dispose new RxList
    paymentMethods.close(); // Dispose new RxList
    // workingHours.close(); // Removed
    announcementActive.close(); // Dispose new RxBool
    status.close(); // Dispose new RxString

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

  // --- Working Hours Management --- (Removed)
  // void updateWorkingHour(String day, String time) {
  //   workingHours[day] = time;
  // }

  // --- Delivery Options Management ---
  void addDeliveryOption(String option) {
    if (option.isNotEmpty && !deliveryOptions.contains(option)) {
      deliveryOptions.add(option);
    }
  }

  void removeDeliveryOption(String option) {
    deliveryOptions.remove(option);
  }

  // --- Payment Methods Management ---
  void addPaymentMethod(String method) {
    if (method.isNotEmpty && !paymentMethods.contains(method)) {
      paymentMethods.add(method);
    }
  }

  void removePaymentMethod(String method) {
    paymentMethods.remove(method);
  }

  // --- Data Fetching by Document ID ---
  Future<void> fetchStoreDataById(String docId) async {
    isLoading.value = true;
    error.value = '';
    try {
      final DocumentSnapshot doc = await _firestore.collection('stores').doc(docId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        // Use StoreModel.fromMap to parse the data
        final store = StoreModel.fromMap(doc.id, data);

        _storeDocId = doc.id;

        nameController.text = store.name;
        descriptionController.text = store.description;
        phoneController.text = store.phone;
        contactEmailController.text = store.contactEmail; // Populate new field
        cityController.text = store.city;
        locationController.text = store.location;
        currentLogoUrl.value = store.logoUrl;
        announcementMessageController.text = store.announcementMessage; // Populate new field

        // Populate new observable fields
        deliveryOptions.value = List<String>.from(store.deliveryOptions);
        paymentMethods.value = List<String>.from(store.paymentMethods);
        // workingHours.value = Map<String, String>.from(store.workingHours); // Removed
        announcementActive.value = store.announcementActive;
        status.value = store.status;


        // Populate social links
        socialControllers.clear();
        store.social.forEach((key, value) {
          socialControllers.add(MapEntry(key, TextEditingController(text: value)));
        });
      } else {
        error.value = 'لم يتم العثور على بيانات المتجر بالمعرف المحدد.';
        fetchStoreDataByUid();
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
          .collection('stores')
          .where('created_by', isEqualTo: uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        // Use StoreModel.fromMap to parse the data
        final store = StoreModel.fromMap(doc.id, data);

        _storeDocId = doc.id;

        // Populate controllers with existing data
        nameController.text = store.name;
        descriptionController.text = store.description;
        phoneController.text = store.phone;
        contactEmailController.text = store.contactEmail; // Populate new field
        cityController.text = store.city;
        locationController.text = store.location;
        currentLogoUrl.value = store.logoUrl;
        announcementMessageController.text = store.announcementMessage; // Populate new field

        // Populate new observable fields
        deliveryOptions.value = List<String>.from(store.deliveryOptions);
        paymentMethods.value = List<String>.from(store.paymentMethods);
        // workingHours.value = Map<String, String>.from(store.workingHours); // Removed
        announcementActive.value = store.announcementActive;
        status.value = store.status;

        // Populate social links
        socialControllers.clear();
        store.social.forEach((key, value) {
          socialControllers.add(
            MapEntry(key, TextEditingController(text: value)),
          );
        });
      } else {
        error.value = 'لم يتم العثور على بيانات المتجر المرتبطة بحسابك.';
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
  Future<String?> _uploadImageToCloudinary(XFile file) async {
    if (_storeDocId == null) {
      error.value = 'خطأ: معرف المتجر غير متوفر لرفع الشعار.';
      return null;
    }

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
          'folder': cloudinaryFolder,
        });
      } else if (filePath != null) {
        formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(filePath, filename: file.name),
          'upload_preset': AppConstants.cloudinaryUploadPreset,
          'folder': cloudinaryFolder,
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

      String? newLogoUrl = currentLogoUrl.value;

      if (logoFile.value != null) {
        final uploadedUrl = await _uploadImageToCloudinary(logoFile.value!);
        if (uploadedUrl == null) {
          throw Exception('فشل في رفع الشعار الجديد.');
        }
        newLogoUrl = uploadedUrl;
      }

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
        'contact_email': contactEmailController.text.trim(), // Update new field
        'city': cityController.text.trim(),
        'location': locationController.text.trim(),
        'logo_url': newLogoUrl,
        'social': socialLinksMap,
        // 'working_hours': workingHours.value, // Removed
        'delivery_options': deliveryOptions.value, // Update new field
        'payment_methods': paymentMethods.value, // Update new field
        'announcement_message': announcementMessageController.text.trim(), // Update new field
        'announcement_active': announcementActive.value, // Update new field
        'status': status.value, // Update new field
        'updated_at': FieldValue.serverTimestamp(),
      });

      Get.snackbar('نجاح', 'تم تحديث بيانات المتجر بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primaryContainer,
          colorText: Get.theme.colorScheme.onPrimaryContainer);

      Get.back();
      // Ensure Dashboard route is correctly defined if navigating directly
      // Get.toNamed(Routes.DASHBOARD); // This line might cause issues if not set up

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

  // --- Product/Offer Navigation Placeholders ---
  void goToAddProduct() {
    if (_storeDocId == null) {
      Get.snackbar('خطأ', 'يرجى حفظ بيانات المتجر أولاً لربط المنتجات.');
      return;
    }
    Get.toNamed(Routes.ADD_PRODUCT, arguments: {'storeId': _storeDocId});
  }

  void goToProductsList() {
    if (_storeDocId == null) {
      Get.snackbar('خطأ', 'يرجى حفظ بيانات المتجر أولاً لعرض المنتجات.');
      return;
    }
    Get.toNamed(Routes.PRODUCTS_LIST, arguments: {'storeId': _storeDocId});
  }

  void goToAddOffer() {
    if (_storeDocId == null) {
      Get.snackbar('خطأ', 'يرجى حفظ بيانات المتجر أولاً لربط العروض.');
      return;
    }
    Get.toNamed(Routes.ADD_OFFER, arguments: {'storeId': _storeDocId});
  }

  void goToOffersList() {
    if (_storeDocId == null) return;
    Get.toNamed(Routes.OFFERS_LIST, arguments: {'storeId': _storeDocId});
  }

}
