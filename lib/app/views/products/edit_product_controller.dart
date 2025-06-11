// lib/app/controllers/edit_product_controller.dart
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:logger/logger.dart';
import 'package:file_selector/file_selector.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../utils/constants.dart';
import '../../utils/app_colors.dart'; // Ensure you have this for snackbar colors

class EditProductController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger logger = Logger();

  var isLoading = false.obs;
  var error = ''.obs;

  String? _productId;
  String? _storeId;

  // New: For handling multiple product images
  final RxList<XFile> selectedImages = <XFile>[].obs; // Newly selected files by user
  final RxList<String> existingImageUrls = <String>[].obs; // URLs of images already in Firestore

  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController categoryController; // Added for product category
  var isAvailable = false.obs; // For product availability

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    priceController = TextEditingController();
    categoryController = TextEditingController(); // Initialize category controller

    if (Get.arguments != null && Get.arguments is Map) {
      _productId = Get.arguments['productId'] as String?;
      _storeId = Get.arguments['storeId'] as String?;

      if (_productId != null && _storeId != null) {
        fetchProductDetails(_productId!);
      } else {
        error.value = 'معرف المنتج أو المتجر غير متوفر.';
        isLoading.value = false;
        logger.e('EditProductController: Product ID or Store ID is null in arguments.');
      }
    } else {
      error.value = 'لا توجد بيانات منتج لتعديلها.';
      isLoading.value = false;
      logger.e('EditProductController: No arguments passed.');
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    categoryController.dispose(); // Dispose category controller
    selectedImages.close();
    existingImageUrls.close();
    super.onClose();
  }

  // --- Fetch Product Details ---
  Future<void> fetchProductDetails(String productId) async {
    isLoading.value = true;
    error.value = '';
    try {
      final DocumentSnapshot doc =
      await _firestore.collection(AppConstants.productsCollection).doc(productId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        nameController.text = data[AppConstants.nameField] ?? '';
        descriptionController.text = data[AppConstants.descriptionField] ?? '';
        priceController.text = (data[AppConstants.priceField] ?? '').toString();
        categoryController.text = data[AppConstants.categoryField] ?? ''; // Populate category
        isAvailable.value = data[AppConstants.isAvailableField] ?? false;

        // Corrected: Handle 'imagesField' which might be a String or List<dynamic>
        final dynamic imagesData = data[AppConstants.imagesField];
        List<String> loadedImageUrls = [];

        if (imagesData is String && imagesData.isNotEmpty) {
          // If it's a single string (from older implementation), convert to a list
          loadedImageUrls.add(imagesData);
          logger.d('Converted single image string to list: $imagesData');
        } else if (imagesData is List) {
          // If it's already a list, ensure all elements are strings
          loadedImageUrls = List<String>.from(imagesData.whereType<String>());
          logger.d('Loaded image list from Firestore: $loadedImageUrls');
        } else {
          logger.w('Product $productId has no valid imagesField data or it is not a String/List.');
        }

        existingImageUrls.assignAll(loadedImageUrls);
        logger.d('Product details loaded for $productId');
      } else {
        error.value = 'لم يتم العثور على بيانات المنتج.';
        logger.e('Product $productId not found.');
      }
    } catch (e) {
      logger.e('Error fetching product details: $e');
      error.value = 'فشل في جلب تفاصيل المنتج: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // --- Image Picker (Multiple Images) ---
  Future<void> pickImages() async {
    final typeGroup = XTypeGroup(label: 'images', extensions: ['png', 'jpg', 'jpeg']);
    final results = await openFiles(acceptedTypeGroups: [typeGroup]); // Removed allowMultiple: true
    if (results.isNotEmpty) {
      selectedImages.addAll(results);
      logger.d('Selected ${results.length} new images.');
    }
  }

  // --- Remove a newly selected image from the preview list ---
  void removeSelectedImage(XFile image) {
    selectedImages.remove(image);
    logger.d('Removed new selected image: ${image.name}');
  }

  // --- Remove an existing image by its URL ---
  Future<void> removeExistingImage(String imageUrl) async {
    existingImageUrls.remove(imageUrl);
    logger.d('Removed existing image URL from list: $imageUrl');

    // --- IMPORTANT: Cloudinary Deletion ---
    // For secure and reliable deletion of old images from Cloudinary,
    // it is strongly recommended to implement a backend function (e.g., Firebase Cloud Function)
    // that handles signed deletion requests. Client-side deletion for signed uploads is insecure.
    //
    // For now, removing it from the list means it won't be saved to Firestore on update.
    // Actual deletion from Cloudinary should happen securely on the backend when the product is updated.
    logger.w('Cloudinary image deletion should ideally be handled by a secure backend and triggered on update.');
  }


  // --- Cloudinary Upload for Product Images ---
  Future<List<String>> _uploadNewProductImagesToCloudinary() async {
    List<String> uploadedUrls = [];
    if (selectedImages.isEmpty || _storeId == null) {
      return uploadedUrls;
    }

    final String cloudinaryFolder = '${AppConstants.productsFolder}/$_storeId';

    for (var file in selectedImages) {
      try {
        final dio = Dio();
        Uint8List? fileBytes;
        String? filePath;

        if (kIsWeb || GetPlatform.isMacOS || GetPlatform.isWindows || GetPlatform.isLinux) {
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
          final String secureUrl = response.data['secure_url'];
          uploadedUrls.add(secureUrl);
          logger.d('Cloudinary product image upload successful: $secureUrl');
        } else {
          logger.e('Cloudinary product image upload failed for ${file.name}: ${response.statusCode} - ${response.data}');
          error.value = 'فشل تحميل صورة ${file.name}: ${response.data['error']['message'] ?? 'خطأ غير معروف'}';
        }
      } catch (e) {
        logger.e('Cloudinary product image upload error for ${file.name}: $e');
        error.value = 'خطأ في رفع صورة ${file.name}: ${e.toString()}';
      }
    }
    return uploadedUrls;
  }

  // --- Update Product ---
  Future<void> updateProduct() async {
    if (_productId == null || _storeId == null) {
      error.value = 'معرف المنتج أو المتجر غير موجود للتحديث.';
      return;
    }
    if (nameController.text.isEmpty || priceController.text.isEmpty || categoryController.text.isEmpty) {
      error.value = 'الرجاء ملء جميع الحقول المطلوبة (الاسم، السعر، الفئة).';
      return;
    }

    isLoading.value = true;
    error.value = '';

    try {
      // 1. Upload any newly selected images
      final List<String> newlyUploadedUrls = await _uploadNewProductImagesToCloudinary();

      // 2. Combine existing (and kept) URLs with newly uploaded URLs
      final List<String> finalImageUrls = [...existingImageUrls, ...newlyUploadedUrls];

      if (finalImageUrls.isEmpty) {
        error.value = 'الرجاء اختيار صورة واحدة على الأقل للمنتج.';
        isLoading.value = false;
        return;
      }

      final double? productPrice = double.tryParse(priceController.text.trim());
      if (productPrice == null || productPrice < 0) {
        error.value = 'الرجاء إدخال سعر منتج صحيح وموجب.';
        isLoading.value = false;
        return;
      }

      // 3. Update product data in Firestore
      await _firestore.collection(AppConstants.productsCollection).doc(_productId).update({
        AppConstants.nameField: nameController.text.trim(),
        AppConstants.descriptionField: descriptionController.text.trim(),
        AppConstants.priceField: productPrice,
        AppConstants.categoryField: categoryController.text.trim(), // Save category
        AppConstants.imagesField: finalImageUrls, // Save the combined list of image URLs
        AppConstants.isAvailableField: isAvailable.value,
        AppConstants.updatedAtField: FieldValue.serverTimestamp(),
      });

      Get.snackbar('نجاح', 'تم تحديث المنتج بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primaryContainer,
          colorText: Get.theme.colorScheme.onPrimaryContainer);

      Get.back(); // Go back to products list
    } on DioException catch (e) {
      logger.e('Dio error during image upload/update: $e');
      error.value = 'فشل في تحميل الصورة أو تحديث البيانات: ${e.message}';
    } on FirebaseException catch (e) {
      logger.e('Firebase error updating product: $e');
      error.value = 'فشل في تحديث المنتج: ${e.message}';
    } on Exception catch (e) {
      logger.e('Error updating product: $e');
      error.value = 'فشل في تحديث المنتج: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Helper to extract public ID from Cloudinary URL for deletion (if implementing backend deletion)
  String? extractPublicIdFromCloudinaryUrl(String url) {
    if (url.isEmpty || !url.contains('res.cloudinary.com')) return null;
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      // Example: 'v12345/folder/subfolder/public_id.png'
      // We want 'folder/subfolder/public_id'
      final indexOfUpload = segments.indexOf('upload');
      if (indexOfUpload != -1 && indexOfUpload + 1 < segments.length) {
        // Get all segments after 'upload/' or 'vYYYYY/' (version segment)
        final relevantSegments = segments.sublist(indexOfUpload + 1);
        final fileNameWithExtension = relevantSegments.last;
        final publicIdWithoutExtension = fileNameWithExtension.split('.').first;

        // Reconstruct the public ID including folders
        if (relevantSegments.length > 1) {
          final folderPath = relevantSegments.sublist(0, relevantSegments.length - 1).join('/');
          return '$folderPath/$publicIdWithoutExtension';
        }
        return publicIdWithoutExtension;
      }
    } catch (e) {
      logger.e('Error extracting public ID from Cloudinary URL: $e');
    }
    return null;
  }
}