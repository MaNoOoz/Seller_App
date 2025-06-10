import 'dart:io'; // For MultipartFile.fromFile in non-web
import 'dart:typed_data'; // For MultipartFile.fromBytes in web
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide MultipartFile, FormData; // Hide MultipartFile, FormData to avoid conflict with Dio
import 'package:logger/logger.dart';
import 'package:file_selector/file_selector.dart'; // For XFile
import 'package:dio/dio.dart'; // For Dio and FormData

import '../../utils/constants.dart';

class AddOfferController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger logger = Logger();

  var isLoading = false.obs;
  var error = ''.obs;

  // New: For banner image
  var bannerFile = Rx<XFile?>(null);

  // Text editing controllers for form fields
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController valueController;
  late TextEditingController startDateController;
  late TextEditingController endDateController;

  var selectedOfferType = 'percentage'.obs;

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  String? _storeId;

  @override
  void onInit() {
    super.onInit();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    valueController = TextEditingController();
    startDateController = TextEditingController();
    endDateController = TextEditingController();

    if (Get.arguments != null && Get.arguments is Map && Get.arguments['storeId'] != null) {
      _storeId = Get.arguments['storeId'] as String;
      logger.d('AddOfferController initialized with Store ID: $_storeId');
    } else {
      error.value = 'معرف المتجر غير متوفر. لا يمكن إضافة العرض.';
      logger.e('AddOfferController: Store ID is null in arguments.');
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    valueController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    bannerFile.close(); // Dispose the Rx variable for the banner
    super.onClose();
  }

  // --- New: Image Picking for Banner ---
  Future<void> pickBannerImage() async {
    final typeGroup = XTypeGroup(label: 'images', extensions: ['png', 'jpg', 'jpeg']);
    final result = await openFile(acceptedTypeGroups: [typeGroup]);
    if (result != null) {
      bannerFile.value = result;
    }
  }

  // --- New: Cloudinary Upload for Banner Image ---
  Future<String?> _uploadBannerImageToCloudinary(XFile file, String storeId) async {
    final String cloudinaryFolder = '${AppConstants.offerBannersFolder}/$storeId'; // Specific folder for offer banners

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
        logger.d('Cloudinary offer banner upload successful: ${response.data['secure_url']}');
        return response.data['secure_url'];
      } else {
        logger.e('Cloudinary offer banner upload failed: ${response.statusCode} - ${response.data}');
        error.value = 'فشل تحميل صورة البانر: ${response.data['error']['message'] ?? 'خطأ غير معروف'}';
        return null;
      }
    } catch (e) {
      logger.e('Cloudinary offer banner upload error: $e');
      error.value = 'خطأ في رفع صورة البانر: ${e.toString()}';
      return null;
    }
  }

  // --- Date Picking Methods (unchanged) ---
  Future<void> pickStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _selectedStartDate = picked;
      startDateController.text = _formatDate(picked);
    }
  }

  Future<void> pickEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? _selectedStartDate ?? DateTime.now(),
      firstDate: _selectedStartDate ?? DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _selectedEndDate = picked;
      endDateController.text = _formatDate(picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // --- Add Offer to Firestore (modified to include banner URL) ---
  Future<void> addOffer() async {
    isLoading.value = true;
    error.value = '';

    if (_storeId == null) {
      error.value = 'لا يمكن إضافة العرض: معرف المتجر غير متوفر.';
      isLoading.value = false;
      return;
    }
    if (titleController.text.trim().isEmpty ||
        valueController.text.trim().isEmpty ||
        startDateController.text.trim().isEmpty ||
        endDateController.text.trim().isEmpty) {
      error.value = 'الرجاء ملء الحقول المطلوبة (العنوان، القيمة، تاريخ البدء، تاريخ الانتهاء).';
      isLoading.value = false;
      return;
    }
    if (_selectedStartDate == null || _selectedEndDate == null) {
      error.value = 'الرجاء تحديد تاريخي البدء والانتهاء بشكل صحيح.';
      isLoading.value = false;
      return;
    }
    if (_selectedEndDate!.isBefore(_selectedStartDate!)) {
      error.value = 'تاريخ الانتهاء لا يمكن أن يكون قبل تاريخ البدء.';
      isLoading.value = false;
      return;
    }
    if (bannerFile.value == null) { // <--- NEW: Check if banner is selected
      error.value = 'الرجاء اختيار صورة بانر للعرض.';
      isLoading.value = false;
      return;
    }

    try {
      final double? offerValue = double.tryParse(valueController.text.trim());
      if (offerValue == null || offerValue <= 0) {
        error.value = 'الرجاء إدخال قيمة عرض صحيحة وموجبة.';
        isLoading.value = false;
        return;
      }

      // New: Upload banner image
      final String? bannerImageUrl = await _uploadBannerImageToCloudinary(bannerFile.value!, _storeId!);
      if (bannerImageUrl == null) {
        isLoading.value = false;
        return; // Error already set in _uploadBannerImageToCloudinary
      }

      await _firestore.collection(AppConstants.offersCollection).add({
        AppConstants.offerTitleField: titleController.text.trim(),
        AppConstants.offerDescriptionField: descriptionController.text.trim(),
        AppConstants.offerTypeField: selectedOfferType.value,
        AppConstants.offerValueField: offerValue,
        AppConstants.offerStartDateField: Timestamp.fromDate(_selectedStartDate!),
        AppConstants.offerEndDateField: Timestamp.fromDate(_selectedEndDate!),
        AppConstants.storeIdField: _storeId,
        AppConstants.createdAtField: FieldValue.serverTimestamp(),
        AppConstants.offerIsActiveField: true,
        AppConstants.offerBannerImageUrlField: bannerImageUrl, // <--- NEW: Save banner URL
      });

      Get.snackbar('نجاح', 'تم إضافة العرض بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primaryContainer,
          colorText: Get.theme.colorScheme.onPrimaryContainer);

      // Clear fields after successful addition
      titleController.clear();
      descriptionController.clear();
      valueController.clear();
      startDateController.clear();
      endDateController.clear();
      selectedOfferType.value = 'percentage';
      _selectedStartDate = null;
      _selectedEndDate = null;
      bannerFile.value = null; // Clear selected banner image

      Get.back();
    } on Exception catch (e) {
      logger.e('Error adding offer: $e');
      error.value = 'فشل في إضافة العرض: ${e.toString()}';
    } catch (e) {
      logger.e('Unexpected error adding offer: $e');
      error.value = 'حدث خطأ غير متوقع: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
}