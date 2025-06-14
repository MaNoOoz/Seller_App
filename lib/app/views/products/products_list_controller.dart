// lib/seller_app/controllers/products_list_controller.dart
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

          // --- FIX START: Handle missing or null values gracefully ---
          // Check if name is missing or empty
          final name = data[AppConstants.nameField] ?? 'غير مُسمى';
          final description = data[AppConstants.descriptionField] ?? 'لا يوجد وصف';
          final price = data[AppConstants.priceField] ?? 0.0;
          final category = data[AppConstants.categoryField] ?? 'غير مُحدد';
          final isAvailable = data[AppConstants.isAvailableField] ?? false;

          // Handle imagesField being either String, List, or missing
          final dynamic imagesData = data[AppConstants.imagesField];
          List<String> loadedImageUrls = [];

          // If imagesField is a string, convert it to a list (legacy support)
          if (imagesData is String && imagesData.isNotEmpty) {
            loadedImageUrls.add(imagesData);
            logger.d('ProductsListController: Converted single image string to list for product ${doc.id}');
          } else if (imagesData is List) {
            // If it's already a list, ensure all elements are strings
            loadedImageUrls = List<String>.from(imagesData.whereType<String>());
          } else {
            // If imagesData is missing or invalid, log it and use an empty list
            logger.w('ProductsListController: Product ${doc.id} has no valid imagesField data or it is not a String/List.');
          }
          // --- FIX END ---

          // Prepare product data
          final productData = {
            'productId': doc.id,
            'name': name,
            'description': description,
            'price': price,
            'category': category,
            'isAvailable': isAvailable,
            'images': loadedImageUrls,
          };

          return productData;
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
