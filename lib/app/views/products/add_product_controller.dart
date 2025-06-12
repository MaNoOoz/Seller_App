import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:file_selector/file_selector.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../routes/app_pages.dart';
import '../../utils/constants.dart';

class AddProductController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger logger = Logger();

  var isLoading = false.obs;
  var error = ''.obs;
  final RxList<XFile> selectedImages = <XFile>[].obs;
  final RxList<String> imageUrls = <String>[].obs;

  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController categoryController;

  String? _storeId; // Store ID to be populated in onInit
  // testing
  Future<void> generateRandomProductsAndOffers(String storeId) async {
    List<String> productNames = ['Product 1', 'Product 2', 'Product 3', 'Product 4', 'Product 5'];
    List<String> categories = ['Category A', 'Category B', 'Category C'];
    List<String> offerTitles = ['Offer 1', 'Offer 2', 'Offer 3', 'Offer 4', 'Offer 5'];

    // Generate random products
    for (var i = 0; i < 5; i++) {
      await _firestore.collection(AppConstants.productsCollection).add({
        AppConstants.nameField: productNames[i],
        AppConstants.descriptionField: 'Description for ${productNames[i]}',
        AppConstants.priceField: (i + 1) * 10.0,
        AppConstants.categoryField: categories[i % 3],
        AppConstants.storeIdField: storeId,
        AppConstants.createdAtField: FieldValue.serverTimestamp(),
        AppConstants.isAvailableField: true,
      });
    }

    // Generate random offers
    for (var i = 0; i < 5; i++) {
      await _firestore.collection(AppConstants.offersCollection).add({
        AppConstants.offerTitleField: offerTitles[i],
        AppConstants.offerDescriptionField: 'Description for ${offerTitles[i]}',
        AppConstants.storeIdField: storeId,
        AppConstants.createdAtField: FieldValue.serverTimestamp(),
        AppConstants.offerIsActiveField: true,
      });
    }
  }

  @override
  void onInit() {
    super.onInit();
    // generateRandomProductsAndOffers("RcVKmNMF374n40X7Ok9o");
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    priceController = TextEditingController();
    categoryController = TextEditingController();

    if (Get.arguments != null && Get.arguments is Map && Get.arguments['storeId'] != null) {
      _storeId = Get.arguments['storeId'] as String;
      logger.d('AddProductController initialized with Store ID: $_storeId');
    } else {
      error.value = 'معرف المتجر غير متوفر. لا يمكن إضافة المنتج.';
      logger.e('AddProductController: Store ID is null in arguments.');
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    categoryController.dispose();
    selectedImages.close();
    imageUrls.close();
    super.onClose();
  }

  Future<void> pickImages() async {
    final typeGroup = XTypeGroup(label: 'images', extensions: ['png', 'jpg', 'jpeg']);
    final results = await openFiles(acceptedTypeGroups: [typeGroup]);
    if (results.isNotEmpty) {
      selectedImages.assignAll(results);
    }
  }

  // --- Modified: Cloudinary Upload (Multiple Images) ---
  Future<List<String>?> _uploadImagesToCloudinary(List<XFile> files) async {
    if (_storeId == null) {
      error.value = 'خطأ: معرف المتجر غير متوفر لرفع الصور.';
      return null;
    }

    final String cloudinaryFolder = '${AppConstants.productsCollection}/$_storeId';
    List<String> uploadedUrls = [];
    final dio = Dio();

    try {
      for (var file in files) {
        FormData formData;
        Uint8List? fileBytes;
        String? filePath;

        if (kIsWeb || GetPlatform.isMacOS || GetPlatform.isWindows || GetPlatform.isLinux) {
          fileBytes = await file.readAsBytes();
        } else if (GetPlatform.isAndroid || GetPlatform.isIOS) {
          filePath = file.path;
        } else {
          throw UnsupportedError('Unsupported platform for file upload.');
        }

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
          uploadedUrls.add(response.data['secure_url']);
        } else {
          logger.e('Cloudinary upload failed for ${file.name}: ${response.statusCode} - ${response.data}');
          error.value = 'فشل تحميل بعض الصور: ${response.data['error']['message'] ?? 'خطأ غير معروف'}';
          return null;
        }
      }
      return uploadedUrls;
    } catch (e) {
      logger.e('Cloudinary upload error: $e');
      error.value = 'خطأ في رفع الصور: ${e.toString()}';
      return null;
    }
  }

  // --- Add Product to Firestore ---
  Future<void> addProduct() async {
    isLoading.value = true;
    error.value = '';

    if (_storeId == null) {
      error.value = 'لا يمكن إضافة المنتج: معرف المتجر غير متوفر.';
      isLoading.value = false;
      return;
    }
    if (nameController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        categoryController.text.trim().isEmpty) {
      error.value = 'الرجاء ملء الحقول المطلوبة (الاسم، السعر، الفئة).';
      isLoading.value = false;
      return;
    }
    if (selectedImages.isEmpty) {
      error.value = 'الرجاء اختيار صورة واحدة على الأقل للمنتج.';
      isLoading.value = false;
      return;
    }

    try {
      final uploadedImageUrls = await _uploadImagesToCloudinary(selectedImages.toList());
      if (uploadedImageUrls == null) {
        isLoading.value = false;
        return;
      }
      imageUrls.assignAll(uploadedImageUrls);

      final double? price = double.tryParse(priceController.text.trim());
      if (price == null) {
        error.value = 'الرجاء إدخال سعر صحيح للمنتج.';
        isLoading.value = false;
        return;
      }

      await _firestore.collection(AppConstants.productsCollection).add({
        AppConstants.nameField: nameController.text.trim(),
        AppConstants.descriptionField: descriptionController.text.trim(),
        AppConstants.priceField: price,
        AppConstants.categoryField: categoryController.text.trim(),
        AppConstants.imagesField: imageUrls.toList(),
        AppConstants.storeIdField: _storeId,
        AppConstants.createdAtField: FieldValue.serverTimestamp(),
        AppConstants.isAvailableField: true,
      });

      Get.snackbar('نجاح', 'تم إضافة المنتج بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primaryContainer,
          colorText: Get.theme.colorScheme.onPrimaryContainer);

      nameController.clear();
      descriptionController.clear();
      priceController.clear();
      categoryController.clear();
      selectedImages.clear();
      imageUrls.clear();

      Get.back();
      Get.toNamed(Routes.DASHBOARD);

    } catch (e) {
      logger.e('Error adding product: $e');
      error.value = 'فشل في إضافة المنتج: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
}
