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
  var deliveryOptions = <String>[].obs;
  var paymentMethods = <String>[].obs;
  var announcementMessage = ''.obs;
  var announcementActive = false.obs;
  var status = ''.obs; // Added status from StoreModel

  // Observable counts for products, offers, and active offers
  var totalProductsCount = 0.obs;
  var totalOffersCount = 0.obs;
  var activeOffersCount = 0.obs;

  // Changed _shopDocId to be an Rxn<String> for reactivity
  var _shopDocId = Rxn<String>();

  // Getter to access the value of _shopDocId
  String? get shopDocId => _shopDocId.value;

  @override
  void onInit() {
    super.onInit();
    _initializeData(); // Call a new method to handle async initialization sequence
  }

  @override
  void onClose() {
    shopName.close();
    phoneNumber.close();
    description.close();
    logoUrl.close();
    contactEmail.close();
    city.close();
    location.close();
    isLoading.close();
    socialLinks.close();
    deliveryOptions.close();
    paymentMethods.close();
    announcementMessage.close();
    announcementActive.close();
    status.close(); // Dispose status
    totalProductsCount.close();
    totalOffersCount.close();
    activeOffersCount.close();
    _shopDocId.close(); // Close the Rxn variable
    super.onClose();
  }

  // New method to sequence data fetching
  Future<void> _initializeData() async {
    await _fetchStoreData(); // Wait for store data to be fetched and _shopDocId to be set
    _fetchCounts(); // Then fetch counts
  }

  Future<void> _fetchStoreData() async {
    isLoading.value = true;
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        _handleError('المستخدم غير مسجل الدخول.');
        return;
      }

      final querySnapshot = await _firestore
          .collection('stores')
          .where('created_by', isEqualTo: uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        final store = StoreModel.fromMap(doc.id, data);

        _shopDocId.value = store.id; // Assign value to the Rxn variable
        shopName.value = store.name;
        phoneNumber.value = store.phone;
        description.value = store.description;
        logoUrl.value = store.logoUrl;
        contactEmail.value = store.contactEmail; // Populate new field
        city.value = store.city;
        location.value = store.location;
        socialLinks.value = Map<String, String>.from(store.social);
        deliveryOptions.value = List<String>.from(store.deliveryOptions); // Populate new field
        paymentMethods.value = List<String>.from(store.paymentMethods); // Populate new field
        announcementMessage.value = store.announcementMessage; // Populate new field
        announcementActive.value = store.announcementActive; // Populate new field
        status.value = store.status; // Populate status
      } else {
        _handleError('لم يتم العثور على بيانات المتجر المرتبطة بحسابك.');
      }
    } catch (e) {
      _handleError('فشل في جلب بيانات المتجر: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchCounts() async {
    // Check if _shopDocId.value is available before fetching counts
    if (_shopDocId.value == null) {
      logger.w('Shop ID is null, cannot fetch product/offer counts.');
      return;
    }
    await _fetchProductsCount();
    await _fetchOffersCount();
    await _fetchActiveOffersCount();
  }

  Future<void> _fetchProductsCount() async {
    try {
      final productSnapshot = await _firestore
          .collection('products')
          .where('store_id', isEqualTo: _shopDocId.value) // Access value from Rxn
          .count()
          .get();
      totalProductsCount.value = productSnapshot.count ?? 0;
    } catch (e) {
      totalProductsCount.value = 0;
      logger.e('Error fetching product count: $e');
    }
  }

  Future<void> _fetchOffersCount() async {
    try {
      final offerSnapshot = await _firestore
          .collection('offers')
          .where('store_id', isEqualTo: _shopDocId.value) // Access value from Rxn
          .count()
          .get();
      totalOffersCount.value = offerSnapshot.count ?? 0;
    } catch (e) {
      totalOffersCount.value = 0;
      logger.e('Error fetching offer count: $e');
    }
  }

  Future<void> _fetchActiveOffersCount() async {
    try {
      final activeOfferSnapshot = await _firestore
          .collection('offers')
          .where('store_id', isEqualTo: _shopDocId.value) // Access value from Rxn
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

  String formatPhoneNumberForWhatsApp(String rawPhoneNumber) {
    // Remove all non-digit characters
    String cleanedNumber = rawPhoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Check if it already starts with a country code (e.g., +963, 00963)
    if (cleanedNumber.startsWith('00963')) { // Corrected from 00969
      return '+${cleanedNumber.substring(2)}'; // Remove '00' prefix
    } else if (cleanedNumber.startsWith('963')) { // Corrected from 969
      return '+$cleanedNumber'; // Add '+' if it starts with country code without it
    } else if (cleanedNumber.startsWith('+963')) { // Corrected from +969
      return cleanedNumber; // Already in desired format
    }

    // Assume Syrian number if it starts with '09' or '9' and is of typical length
    // Syrian mobile numbers generally start with 09 and are 10 digits long (09XXXXXXXX)
    // or 9 digits long if the leading '0' is omitted (9XXXXXXXX).
    if (cleanedNumber.startsWith('09') && cleanedNumber.length == 10) {
      return '+963${cleanedNumber.substring(1)}'; // Corrected to +963, remove '0'
    } else if (cleanedNumber.startsWith('9') && cleanedNumber.length == 9) {
      return '+963$cleanedNumber'; // Corrected to +963, prepend to '9XXXXXXXX'
    }

    // If it doesn't match common local or international Syrian patterns,
    // return as is (cleaned). You might want to handle other cases or
    // explicitly throw an error if strict validation is needed here.
    return cleanedNumber;
  }}