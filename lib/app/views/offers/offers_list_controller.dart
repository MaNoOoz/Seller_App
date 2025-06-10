import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../../utils/constants.dart';


class OffersListController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger logger = Logger();

  // Observable list to hold offers
  final RxList<Map<String, dynamic>> offers = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var error = ''.obs;
  String? _storeId; // To fetch offers for a specific store

  @override
  void onInit() {
    super.onInit();
    // Get the storeId passed from the previous screen (e.g., EditStoreScreen)
    if (Get.arguments != null && Get.arguments is Map && Get.arguments['storeId'] != null) {
      _storeId = Get.arguments['storeId'] as String;
      logger.d('OffersListController initialized with Store ID: $_storeId');
      fetchOffers(); // Start fetching offers
    } else {
      error.value = 'معرف المتجر غير متوفر. لا يمكن عرض العروض.';
      logger.e('OffersListController: Store ID is null in arguments.');
      isLoading.value = false;
    }
  }

  // Method to fetch offers from Firestore in real-time
  void fetchOffers() {
    if (_storeId == null) {
      error.value = 'لا يوجد معرف متجر لجلب العروض.';
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    error.value = '';

    // Listen to real-time updates from Firestore
    _firestore
        .collection(AppConstants.offersCollection) // Use constants
        .where(AppConstants.storeIdField, isEqualTo: _storeId) // Filter by store ID
        .orderBy(AppConstants.createdAtField, descending: true) // Order by creation date
        .snapshots() // Get a stream of query snapshots
        .listen(
          (QuerySnapshot querySnapshot) {
        final List<Map<String, dynamic>> fetchedOffers = [];
        for (var doc in querySnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          fetchedOffers.add({'id': doc.id, ...data}); // Include document ID
        }
        offers.assignAll(fetchedOffers); // Update the observable list
        isLoading.value = false;
        logger.d('Fetched ${fetchedOffers.length} offers for store $_storeId');
      },
      onError: (e) {
        logger.e('Error fetching offers: $e');
        error.value = 'فشل في جلب العروض: ${e.toString()}';
        isLoading.value = false;
      },
      onDone: () {
        logger.d('Finished fetching offers stream.');
        isLoading.value = false;
      },
    );
  }

  // Future methods for editing/deleting offers
  void goToEditOffer(String offerId) {
    // Navigate to an EditOfferScreen, passing offerId and storeId
    logger.d('Navigate to edit offer: $offerId for store: $_storeId');
    // Get.toNamed(Routes.EDIT_OFFER, arguments: {'offerId': offerId, 'storeId': _storeId});
    Get.snackbar('ميزة قادمة', 'تعديل العرض ليس متاحًا بعد');
  }

  Future<void> deleteOffer(String offerId) async {
    // Implement offer deletion logic
    isLoading.value = true;
    error.value = '';
    try {
      await _firestore.collection(AppConstants.offersCollection).doc(offerId).delete();
      Get.snackbar('نجاح', 'تم حذف العرض بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primaryContainer,
          colorText: Get.theme.colorScheme.onPrimaryContainer);
      logger.d('Offer $offerId deleted successfully.');
    } catch (e) {
      logger.e('Error deleting offer $offerId: $e');
      error.value = 'فشل في حذف العرض: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Helper to check if an offer is currently active
  bool isOfferActive(Map<String, dynamic> offer) {
    final Timestamp? startDateTimestamp = offer[AppConstants.offerStartDateField];
    final Timestamp? endDateTimestamp = offer[AppConstants.offerEndDateField];
    final bool isActive = offer[AppConstants.offerIsActiveField] ?? false;

    if (!isActive) return false;

    final DateTime now = DateTime.now();
    final DateTime? startDate = startDateTimestamp?.toDate();
    final DateTime? endDate = endDateTimestamp?.toDate();

    return (startDate == null || now.isAfter(startDate)) &&
        (endDate == null || now.isBefore(endDate));
  }
}