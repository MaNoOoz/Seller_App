import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // For SnackBar and TextButton styles
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../../routes/app_pages.dart';
import '../../utils/constants.dart'; // <--- NEW: Import AppConstants

class DashboardController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Rx variables to bind to UI for store info
  var shopName = ''.obs;
  var phoneNumber = ''.obs;
  var description = ''.obs;
  var logoUrl = ''.obs;
  var isLoading = true.obs;
  final Logger logger = Logger();

  // <--- NEW: Rx variables for counts ---
  var totalProductsCount = 0.obs;
  var totalOffersCount = 0.obs;
  var activeOffersCount = 0.obs;
  // --- END NEW ---

  // Current shop doc ID
  String? _shopDocId;

  // Getter to provide shopDocId to other methods/views
  String? get shopDocId => _shopDocId;

  @override
  void onInit() {
    super.onInit();
    logger.d('DashboardController: onInit called. Fetching shop data...');
    // No need for async onInit if fetchShopData is Future<void> and called without await
    fetchShopData();
  }

  /// Fetch shop data based on current user
  Future<void> fetchShopData() async {
    try {
      isLoading.value = true;
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        Get.snackbar(
          'خطأ',
          'المستخدم غير مسجل الدخول. الرجاء تسجيل الدخول مرة أخرى.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.errorContainer,
          colorText: Get.theme.colorScheme.onErrorContainer,
        );
        logger.e('DashboardController: UID is null. User not logged in.');
        return;
      }
      logger.d('DashboardController: Fetching data for UID: $uid');

      final query = await _firestore
          .collection(AppConstants.storesCollection) // Use constant
          .where(AppConstants.createdByField, isEqualTo: uid) // Use constant
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final data = doc.data();

        _shopDocId = doc.id;
        shopName.value = data[AppConstants.nameField] ?? ''; // Use constant
        phoneNumber.value = data[AppConstants.phoneField] ?? ''; // Use constant
        description.value = data[AppConstants.descriptionField] ?? ''; // Use constant
        logoUrl.value = data[AppConstants.logoUrlField] ?? ''; // Use constant
        logger.d('DashboardController: Shop data fetched. Shop ID: $_shopDocId, Name: ${shopName.value}');

        // <--- NEW: Fetch counts after store ID is available ---
        _fetchProductsCount();
        _fetchOffersCount();
        _fetchActiveOffersCount();
        // --- END NEW ---

      } else {
        Get.snackbar(
          'تنبيه',
          'لم يتم العثور على بيانات المتجر. يرجى إنشاء متجر.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
          mainButton: TextButton(
            onPressed: () => Get.offAllNamed(Routes.NO_ACCESS), // Assuming NO_ACCESS is your create shop screen
            child: Text('إنشاء متجر الآن', style: TextStyle(color: Get.theme.colorScheme.onSurfaceVariant)),
          ),
          backgroundColor: Get.theme.colorScheme.surfaceVariant,
          colorText: Get.theme.colorScheme.onSurfaceVariant,
        );
        logger.w('DashboardController: No store found for UID: $uid');
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في جلب البيانات: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
      logger.e('DashboardController: Error fetching data: $e');
    } finally {
      isLoading.value = false;
      logger.d('DashboardController: Finished fetching shop data. isLoading: ${isLoading.value}');
    }
  }

  // <--- NEW: Methods to fetch counts ---
  Future<void> _fetchProductsCount() async {
    if (_shopDocId == null) return;
    try {
      final productSnapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where(AppConstants.storeIdField, isEqualTo: _shopDocId)
          .count() // Use .count() for efficient count
          .get();
      totalProductsCount.value = productSnapshot.count ?? 0;
      logger.d('DashboardController: Total products count: ${totalProductsCount.value}');
    } catch (e) {
      logger.e('DashboardController: Error fetching products count: $e');
      totalProductsCount.value = 0; // Reset on error
    }
  }

  Future<void> _fetchOffersCount() async {
    if (_shopDocId == null) return;
    try {
      final offerSnapshot = await _firestore
          .collection(AppConstants.offersCollection)
          .where(AppConstants.storeIdField, isEqualTo: _shopDocId)
          .count()
          .get();
      totalOffersCount.value = offerSnapshot.count ?? 0;
      logger.d('DashboardController: Total offers count: ${totalOffersCount.value}');
    } catch (e) {
      logger.e('DashboardController: Error fetching total offers count: $e');
      totalOffersCount.value = 0; // Reset on error
    }
  }

  Future<void> _fetchActiveOffersCount() async {
    if (_shopDocId == null) return;
    try {
      final activeOfferSnapshot = await _firestore
          .collection(AppConstants.offersCollection)
          .where(AppConstants.storeIdField, isEqualTo: _shopDocId)
          .where(AppConstants.offerIsActiveField, isEqualTo: true)
          .where(AppConstants.offerEndDateField, isGreaterThan: Timestamp.now()) // Only truly active offers
          .count()
          .get();
      activeOffersCount.value = activeOfferSnapshot.count ?? 0;
      logger.d('DashboardController: Active offers count: ${activeOffersCount.value}');
    } catch (e) {
      logger.e('DashboardController: Error fetching active offers count: $e');
      activeOffersCount.value = 0; // Reset on error
    }
  }
  // --- END NEW ---

  /// Navigate to edit store screen
  void goToEditStore() {
    logger.d('DashboardController: goToEditStore called. Shop Doc ID before navigation: $_shopDocId');
    if (_shopDocId == null) {
      Get.snackbar(
        'خطأ',
        'لا يمكن تعديل المتجر: بيانات المتجر غير متوفرة بعد.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
      return;
    }
    Get.toNamed(Routes.EDIT_STORE, arguments: {'storeId': _shopDocId}); // <--- Corrected to 'storeId' for consistency
  }


  /// Navigate to add product screen
  void goToAddProduct() {
    if (_shopDocId == null) {
      Get.snackbar('خطأ', 'لا يمكن إضافة منتج: بيانات المتجر غير متوفرة.');
      return;
    }
    Get.toNamed(Routes.ADD_PRODUCT, arguments: {'storeId': _shopDocId}); // <--- Corrected to 'storeId' and use constant route
  }

  /// Navigate to products list screen
  void goToProductsList() {
    if (_shopDocId == null) {
      Get.snackbar('خطأ', 'لا يمكن عرض المنتجات: بيانات المتجر غير متوفرة.');
      return;
    }
    Get.toNamed(Routes.PRODUCTS_LIST, arguments: {'storeId': _shopDocId});
  }

  // <--- NEW: Navigation methods for offers ---
  void goToAddOffer() {
    if (_shopDocId == null) {
      Get.snackbar('خطأ', 'لا يمكن إضافة عرض: بيانات المتجر غير متوفرة.');
      return;
    }
    Get.toNamed(Routes.ADD_OFFER, arguments: {'storeId': _shopDocId});
  }

  void goToOffersList() {
    if (_shopDocId == null) {
      Get.snackbar('خطأ', 'لا يمكن عرض العروض: بيانات المتجر غير متوفرة.');
      return;
    }
    Get.toNamed(Routes.OFFERS_LIST, arguments: {'storeId': _shopDocId});
  }
// --- END NEW ---
}