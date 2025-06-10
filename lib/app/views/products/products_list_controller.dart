import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../../utils/constants.dart';


class ProductsListController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger logger = Logger();

  // Observable list to hold products
  final RxList<Map<String, dynamic>> products = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var error = ''.obs;
  String? _storeId; // To fetch products for a specific store

  @override
  void onInit() {
    super.onInit();
    // Get the storeId passed from the previous screen (e.g., EditStoreScreen)
    if (Get.arguments != null && Get.arguments is Map && Get.arguments['storeId'] != null) {
      _storeId = Get.arguments['storeId'] as String;
      logger.d('ProductsListController initialized with Store ID: $_storeId');
      fetchProducts(); // Start fetching products
    } else {
      error.value = 'معرف المتجر غير متوفر. لا يمكن عرض المنتجات.';
      logger.e('ProductsListController: Store ID is null in arguments.');
      isLoading.value = false;
    }
  }

  // Method to fetch products from Firestore in real-time
  void fetchProducts() {
    if (_storeId == null) {
      error.value = 'لا يوجد معرف متجر لجلب المنتجات.';
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    error.value = '';

    // Listen to real-time updates from Firestore
    _firestore
        .collection(AppConstants.productsCollection) // Use constants
        .where(AppConstants.storeIdField, isEqualTo: _storeId) // Filter by store ID
        .orderBy(AppConstants.createdAtField, descending: true) // Order by creation date
        .snapshots() // Get a stream of query snapshots
        .listen(
          (QuerySnapshot querySnapshot) {
        final List<Map<String, dynamic>> fetchedProducts = [];
        for (var doc in querySnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          fetchedProducts.add({'id': doc.id, ...data}); // Include document ID
        }
        products.assignAll(fetchedProducts); // Update the observable list
        isLoading.value = false;
        logger.d('Fetched ${fetchedProducts.length} products for store $_storeId');
      },
      onError: (e) {
        logger.e('Error fetching products: $e');
        error.value = 'فشل في جلب المنتجات: ${e.toString()}';
        isLoading.value = false;
      },
      onDone: () {
        logger.d('Finished fetching products stream.');
        isLoading.value = false;
      },
    );
  }

  // Future methods for editing/deleting products
  void goToEditProduct(String productId) {
    // Navigate to an EditProductScreen, passing productId and storeId
    logger.d('Navigate to edit product: $productId for store: $_storeId');
    // Get.toNamed(Routes.EDIT_PRODUCT, arguments: {'productId': productId, 'storeId': _storeId});
    Get.snackbar('ميزة قادمة', 'تعديل المنتج ليس متاحًا بعد');
  }

  Future<void> deleteProduct(String productId) async {
    // Implement product deletion logic
    isLoading.value = true;
    error.value = '';
    try {
      await _firestore.collection(AppConstants.productsCollection).doc(productId).delete();
      Get.snackbar('نجاح', 'تم حذف المنتج بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primaryContainer,
          colorText: Get.theme.colorScheme.onPrimaryContainer);
      logger.d('Product $productId deleted successfully.');
    } catch (e) {
      logger.e('Error deleting product $productId: $e');
      error.value = 'فشل في حذف المنتج: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
}