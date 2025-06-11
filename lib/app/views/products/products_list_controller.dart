// lib/app/controllers/products_list_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../../routes/app_pages.dart';
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
      error.value = 'معرف المتجر غير متوفر.';
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    error.value = '';

    _firestore
        .collection(AppConstants.productsCollection)
        .where(AppConstants.storeIdField, isEqualTo: _storeId)
        .orderBy(AppConstants.createdAtField, descending: true)
        .snapshots()
        .listen(
          (QuerySnapshot snapshot) {
        final fetchedProducts = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          // Ensure product ID is included in the map
          data[AppConstants.idField] = doc.id;

          // --- FIX START: Handle imagesField potentially being a String instead of a List ---
          final dynamic imagesData = data[AppConstants.imagesField];
          List<String> loadedImageUrls = [];

          if (imagesData is String && imagesData.isNotEmpty) {
            loadedImageUrls.add(imagesData);
            logger.d('ProductsListController: Converted single image string to list for product ${doc.id}');
          } else if (imagesData is List) {
            loadedImageUrls = List<String>.from(imagesData.whereType<String>());
          } else {
            logger.w('ProductsListController: Product ${doc.id} has no valid imagesField data or it is not a String/List.');
          }
          data[AppConstants.imagesField] = loadedImageUrls;
          // --- FIX END ---

          return data;
        }).toList();
        products.assignAll(fetchedProducts);
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
    if (_storeId == null) {
      Get.snackbar('خطأ', 'معرف المتجر غير متوفر لتعديل المنتج.');
      return;
    }
    Get.toNamed(
      Routes.EDIT_PRODUCT,
      arguments: {'productId': productId, 'storeId': _storeId},
    );
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