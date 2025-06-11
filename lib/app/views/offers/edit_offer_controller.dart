import 'dart:io';
import 'dart:typed_data'; // For Uint8List in web
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:logger/logger.dart';
import 'package:file_selector/file_selector.dart';
import 'package:dio/dio.dart'; // For Dio and FormData
import 'package:flutter/foundation.dart' show kIsWeb; // For web detection

import '../../utils/constants.dart';
import '../../utils/app_colors.dart'; // For snackbar colors

class EditOfferController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger logger = Logger();

  var isLoading = false.obs;
  var error = ''.obs;

  // Offer ID passed to this controller
  String? _offerId;
  String? _storeId; // Needed for consistency, as offers belong to a store

  // New: For banner image
  var bannerFile = Rx<XFile?>(null); // New selected file
  var existingBannerUrl = ''.obs; // URL of the currently saved banner

  // Text editing controllers for form fields
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController valueController;
  late TextEditingController startDateController;
  late TextEditingController endDateController;

  var selectedOfferType = 'percentage'.obs; // Default value

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void onInit() {
    super.onInit();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    valueController = TextEditingController();
    startDateController = TextEditingController();
    endDateController = TextEditingController();

    // Get offerId and storeId from arguments
    if (Get.arguments != null && Get.arguments is Map) {
      _offerId = Get.arguments['offerId'] as String?;
      _storeId = Get.arguments['storeId'] as String?; // Pass storeId for consistency

      if (_offerId != null) {
        fetchOfferDetails(_offerId!);
      } else {
        error.value = 'معرف العرض غير متوفر.';
        isLoading.value = false;
        logger.e('EditOfferController: Offer ID is null in arguments.');
      }

      if (_storeId == null) {
        error.value += ' معرف المتجر غير متوفر.';
        logger.e('EditOfferController: Store ID is null in arguments.');
      }
    } else {
      error.value = 'لا توجد بيانات عرض لتعديلها.';
      isLoading.value = false;
      logger.e('EditOfferController: No arguments passed.');
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

  // --- Fetch Offer Details ---
  Future<void> fetchOfferDetails(String offerId) async {
    isLoading.value = true;
    error.value = '';
    try {
      final DocumentSnapshot doc =
      await _firestore.collection(AppConstants.offersCollection).doc(offerId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        titleController.text = data[AppConstants.offerTitleField] ?? '';
        descriptionController.text = data[AppConstants.offerDescriptionField] ?? '';
        valueController.text = (data[AppConstants.offerValueField] ?? '').toString();
        selectedOfferType.value = data[AppConstants.offerTypeField] ?? 'percentage';
        existingBannerUrl.value = data[AppConstants.offerBannerImageUrlField] ?? '';

        // Dates
        final Timestamp? startDateTimestamp = data[AppConstants.offerStartDateField];
        final Timestamp? endDateTimestamp = data[AppConstants.offerEndDateField];

        if (startDateTimestamp != null) {
          _selectedStartDate = startDateTimestamp.toDate();
          startDateController.text = _formatDate(_selectedStartDate!);
        }
        if (endDateTimestamp != null) {
          _selectedEndDate = endDateTimestamp.toDate();
          endDateController.text = _formatDate(_selectedEndDate!);
        }
        logger.d('Offer details loaded for $offerId');
      } else {
        error.value = 'لم يتم العثور على بيانات العرض.';
        logger.e('Offer $offerId not found.');
      }
    } catch (e) {
      logger.e('Error fetching offer details: $e');
      error.value = 'فشل في جلب تفاصيل العرض: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // --- Date Picker Methods ---
  Future<void> pickStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedStartDate) {
      _selectedStartDate = picked;
      startDateController.text = _formatDate(picked);
    }
  }

  Future<void> pickEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? _selectedStartDate ?? DateTime.now(),
      firstDate: _selectedStartDate ?? DateTime(2000), // End date cannot be before start date
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedEndDate) {
      _selectedEndDate = picked;
      endDateController.text = _formatDate(picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // --- Image Picker ---
  Future<void> pickBannerImage() async {
    final typeGroup = XTypeGroup(label: 'images', extensions: ['png', 'jpg', 'jpeg']);
    final result = await openFile(acceptedTypeGroups: [typeGroup]);
    if (result != null) {
      bannerFile.value = result;
      logger.d('Banner image selected: ${result.name}');
    }
  }

  // --- Cloudinary Upload for Banner Image (copied from your AddOfferController) ---
  Future<String?> _uploadBannerImageToCloudinary(XFile file, String storeId) async {
    final String cloudinaryFolder = '${AppConstants.offerBannersFolder}/$storeId'; // Specific folder for offer banners

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
          'folder': cloudinaryFolder, // Specify the folder
        });
      } else if (filePath != null) {
        formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(filePath, filename: file.name),
          'upload_preset': AppConstants.cloudinaryUploadPreset,
          'folder': cloudinaryFolder, // Specify the folder
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

  // --- Update Offer ---
  Future<void> updateOffer() async {
    if (_offerId == null) {
      error.value = 'معرف العرض غير موجود للتحديث.';
      return;
    }
    if (_storeId == null) {
      error.value = 'معرف المتجر غير موجود.';
      return;
    }
    if (titleController.text.isEmpty || valueController.text.isEmpty || _selectedStartDate == null || _selectedEndDate == null) {
      error.value = 'الرجاء ملء جميع الحقول المطلوبة واختيار التواريخ.';
      return;
    }
    if (_selectedEndDate!.isBefore(_selectedStartDate!)) {
      error.value = 'تاريخ الانتهاء لا يمكن أن يكون قبل تاريخ البدء.';
      isLoading.value = false;
      return;
    }


    isLoading.value = true;
    error.value = '';
    String? bannerImageUrl = existingBannerUrl.value; // Start with existing URL

    try {
      // 1. Upload new banner image if selected
      if (bannerFile.value != null) {
        // --- IMPORTANT: Cloudinary Deletion ---
        // For secure and reliable deletion of old images from Cloudinary,
        // it is strongly recommended to implement a backend function (e.g., Firebase Cloud Function)
        // that handles signed deletion requests. Client-side deletion is insecure for signed uploads.
        // If you are using unsigned uploads, you typically don't delete from the client directly.
        //
        // For now, if a new image is uploaded, we'll replace the URL.
        // You might consider a separate cleanup process or a backend for old images.
        logger.w('Cloudinary image deletion should ideally be handled by a secure backend.');
        // If you had a CloudinaryService.deleteImage method (which needs a backend), it would look like:
        // if (existingBannerUrl.value.isNotEmpty) {
        //   // You'd need to extract the public_id from existingBannerUrl.value
        //   final publicId = extractPublicIdFromCloudinaryUrl(existingBannerUrl.value);
        //   if (publicId != null) {
        //     await CloudinaryService().deleteImage(publicId);
        //     logger.d('Old banner image marked for deletion: $publicId');
        //   }
        // }


        bannerImageUrl = await _uploadBannerImageToCloudinary(bannerFile.value!, _storeId!);
        if (bannerImageUrl == null) {
          isLoading.value = false;
          return; // Error already set in _uploadBannerImageToCloudinary
        }
        logger.d('New banner image uploaded: $bannerImageUrl');
      }

      // Convert value based on type
      num offerValue;
      try {
        if (selectedOfferType.value == 'percentage') {
          offerValue = double.parse(valueController.text);
          if (offerValue < 0 || offerValue > 100) {
            error.value = 'النسبة المئوية يجب أن تكون بين 0 و 100.';
            isLoading.value = false;
            return;
          }
        } else {
          offerValue = double.parse(valueController.text);
          if (offerValue < 0) {
            error.value = 'القيمة الثابتة يجب أن تكون موجبة.';
            isLoading.value = false;
            return;
          }
        }
      } catch (e) {
        error.value = 'قيمة العرض غير صالحة.';
        isLoading.value = false;
        return;
      }


      // 2. Update offer data in Firestore
      await _firestore.collection(AppConstants.offersCollection).doc(_offerId).update({
        AppConstants.offerTitleField: titleController.text.trim(),
        AppConstants.offerDescriptionField: descriptionController.text.trim(),
        AppConstants.offerTypeField: selectedOfferType.value,
        AppConstants.offerValueField: offerValue,
        AppConstants.offerStartDateField: Timestamp.fromDate(_selectedStartDate!),
        AppConstants.offerEndDateField: Timestamp.fromDate(_selectedEndDate!),
        AppConstants.offerBannerImageUrlField: bannerImageUrl, // Save new or existing URL
        // offerIsActiveField could be updated if you add a toggle in the UI
      });

      Get.snackbar('نجاح', 'تم تحديث العرض بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primaryContainer, // Using current theme
          colorText: Get.theme.colorScheme.onPrimaryContainer); // Using current theme

      Get.back(); // Go back to offers list
    } on DioException catch (e) {
      logger.e('Dio error during image upload/update: $e');
      error.value = 'فشل في تحميل الصورة أو تحديث البيانات: ${e.message}';
    } on FirebaseException catch (e) {
      logger.e('Firebase error updating offer: $e');
      error.value = 'فشل في تحديث العرض: ${e.message}';
    } on Exception catch (e) {
      logger.e('Error updating offer: $e');
      error.value = 'فشل في تحديث العرض: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Helper to extract public ID from Cloudinary URL for deletion (if needed)
  // This is a basic example; a more robust solution might use regex.
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