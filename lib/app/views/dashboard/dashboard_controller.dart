import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../../models.dart';
import '../../routes/app_pages.dart';
import '../../utils/constants.dart';

class DashboardController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger logger = Logger();

  // Observable variables for store info
  var shopName = ''.obs;
  var phoneNumber = ''.obs;
  var description = ''.obs;
  var logoUrl = ''.obs;
  var contactEmail = ''.obs;
  var city = ''.obs;
  var location = ''.obs;
  var isLoading = true.obs;
  var socialLinks = <String, String>{}.obs;
  var workingHours = <String, String>{}.obs;
  var deliveryOptions = <String>[].obs;
  var paymentMethods = <String>[].obs;
  var announcementMessage = ''.obs;
  var announcementActive = false.obs;

  // Observable counts for products, offers, and active offers
  var totalProductsCount = 0.obs;
  var totalOffersCount = 0.obs;
  var activeOffersCount = 0.obs;

  String? _shopDocId;

  String? get shopDocId => _shopDocId;

  bool isFetched = false;

  @override
  void onInit() {
    super.onInit();
    logger.d('DashboardController: onInit called. Fetching user stores data...');
    fetchUserStoresData();
  }

  Future<void> fetchUserStoresData() async {
    if (isFetched) return; // Prevent re-fetching
    try {
      isLoading.value = true;
      final uid = _auth.currentUser?.uid;

      if (uid == null) {
        _handleError('المستخدم غير مسجل الدخول. الرجاء تسجيل الدخول مرة أخرى.');
        return;
      }

      // Fetching user store data
      final query = await _firestore
          .collection(AppConstants.storesCollection)
          .where(AppConstants.createdByField, isEqualTo: uid)
          .get();

      if (query.docs.isNotEmpty) {
        var storeData = query.docs.first.data() as Map<String, dynamic>;

        // Set store details
        _shopDocId = query.docs.first.id;
        shopName.value = storeData[AppConstants.nameField] ?? '';
        phoneNumber.value = storeData[AppConstants.phoneField] ?? '';
        description.value = storeData[AppConstants.descriptionField] ?? '';
        logoUrl.value = storeData[AppConstants.logoUrlField] ?? '';
        contactEmail.value = storeData['contact_email'] ?? '';
        city.value = storeData['city'] ?? '';
        location.value = storeData['location'] ?? '';
        socialLinks.value = Map<String, String>.from(storeData['social'] ?? {});
        workingHours.value = Map<String, String>.from(storeData['working_hours'] ?? {});
        deliveryOptions.value = List<String>.from(storeData['delivery_options'] ?? []);
        paymentMethods.value = List<String>.from(storeData['payment_methods'] ?? []);
        announcementMessage.value = storeData['announcement_message'] ?? '';
        announcementActive.value = storeData['announcement_active'] ?? false;

        // Fetch counts
        await _fetchCounts();
      } else {
        _handleError('لم يتم العثور على أي متجر. يرجى إنشاء متجر.');
      }
    } catch (e) {
      _handleError('فشل في جلب البيانات: ${e.toString()}');
    } finally {
      isLoading.value = false;
      isFetched = true;
    }
  }

  // Fetch counts for products, offers, and active offers
  Future<void> _fetchCounts() async {
    await Future.wait([_fetchProductsCount(), _fetchOffersCount(), _fetchActiveOffersCount()]);
  }

  Future<void> _fetchProductsCount() async {
    if (_shopDocId == null) return;
    try {
      final productSnapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where(AppConstants.storeIdField, isEqualTo: _shopDocId)
          .count()
          .get();
      totalProductsCount.value = productSnapshot.count ?? 0;
    } catch (e) {
      totalProductsCount.value = 0;
      logger.e('Error fetching products count: $e');
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
    } catch (e) {
      totalOffersCount.value = 0;
      logger.e('Error fetching offers count: $e');
    }
  }

  Future<void> _fetchActiveOffersCount() async {
    if (_shopDocId == null) return;
    try {
      final activeOfferSnapshot = await _firestore
          .collection(AppConstants.offersCollection)
          .where(AppConstants.storeIdField, isEqualTo: _shopDocId)
          .where(AppConstants.offerIsActiveField, isEqualTo: true)
          .where(AppConstants.offerEndDateField, isGreaterThan: Timestamp.now())
          .count()
          .get();
      activeOffersCount.value = activeOfferSnapshot.count ?? 0;
    } catch (e) {
      activeOffersCount.value = 0;
      logger.e('Error fetching active offers count: $e');
    }
  }

  // Handle errors and show user-friendly messages
  void _handleError(String message) {
    Get.snackbar(
      'خطأ',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.errorContainer,
      colorText: Get.theme.colorScheme.onErrorContainer,
    );
    logger.e(message);
  }

  // Navigate to edit store screen
  void goToEditStore(String storeId) {
    Get.toNamed(Routes.EDIT_STORE, arguments: {'storeId': storeId});
  }

  // Navigate to add product screen
  void goToAddProduct(String storeId) {
    Get.toNamed(Routes.ADD_PRODUCT, arguments: {'storeId': storeId});
  }

  // Navigate to products list screen
  void goToProductsList(String storeId) {
    Get.toNamed(Routes.PRODUCTS_LIST, arguments: {'storeId': storeId});
  }

  // Navigate to add offer screen
  void goToAddOffer(String storeId) {
    Get.toNamed(Routes.ADD_OFFER, arguments: {'storeId': storeId});
  }

  // Navigate to offers list screen
  void goToOffersList(String storeId) {
    Get.toNamed(Routes.OFFERS_LIST, arguments: {'storeId': storeId});
  }
}
