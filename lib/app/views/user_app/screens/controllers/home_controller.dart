import 'package:app/app/views/user_app/models/category.dart';
import 'package:app/app/views/user_app/models/product.dart';


import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../../models/Offer.dart';
import '../../models/Store.dart';

class HomeController extends GetxController {
  RxList<Product> filteredMenuItems = <Product>[].obs;
  RxList<Product> allProducts = <Product>[].obs; // Add this line

  RxList<String> categories = <String>[].obs;  // List of unique categories
  Rx<String?> selectedCategory = Rx<String?>(null);
  RxBool isLoading = false.obs;
  Rx<String?> errorMessage = Rx<String?>(null);

  // Store and Offers data
  Rx<Store?> storeInfo = Rx<Store?>(null);
  RxList<Offer> offers = <Offer>[].obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();
  final String storeId = "p2HNRulZDPyjYcSMgvRP"; // centralize store ID

  @override
  void onInit() {
    fetchMenuItems(); // Fetch all products initially
    fetchStoreInfo(); // Fetch store information
    fetchOffers(); // Fetch active offers
    super.onInit();
  }

  // Fetch all products from Firebase and extract unique categories
  /// ✅ Fetch products only from the current store and extract unique categories
  Future<void> fetchMenuItems() async {
    isLoading(true);
    _logger.i('Fetching products for store: $storeId');
    try {
      final productDocs = await _firestore
          .collection('products')
          .where('store_id', isEqualTo: storeId)
          .get();

      _logger.i('Products fetched: ${productDocs.docs.length}');

      List<Product> products = [];
      Set<String> categorySet = {};

      for (var doc in productDocs.docs) {
        try {
          final product = Product.fromDocument(doc);
          products.add(product);
          categorySet.add(product.category);
        } catch (e) {
          _logger.e('Error processing product: $e');
        }
      }

      allProducts.assignAll(products);
      filteredMenuItems.assignAll(products);
      categories.assignAll(categorySet.toList());
    } catch (e) {
      _logger.e('Failed to load products: $e');
      errorMessage("Failed to load products: $e");
    } finally {
      isLoading(false);
    }
  }// New method to reset filter
  void resetCategoryFilter() {
    _logger.i("Resetting category filter");
    selectedCategory.value = null;
    filteredMenuItems.assignAll(allProducts);
  }
  // Filter products by selected category
  void filterByCategory(String category) {
    _logger.i("Filtering by category: $category");
    selectedCategory.value = category;

    final filtered = allProducts.where((product) => product.category == category).toList();
    filteredMenuItems.assignAll(filtered);
  }
  // Fetch Store Information
  Future<void> fetchStoreInfo() async {
    _logger.i('Fetching store information...');
    try {
      final storeDoc = await _firestore.collection('stores').doc(storeId).get(); // Replace with the actual store_id
      final Map<String, dynamic> data = storeDoc.data() as Map<String, dynamic>;

      if (storeDoc.exists) {
        storeInfo.value = Store.fromMap(storeId,data);
        _logger.i('Store info fetched: ${storeInfo.value?.name}');
      } else {
        _logger.e('Store not found');
      }
    } catch (e) {
      _logger.e('Failed to load store info: $e');
      errorMessage("Failed to load store info: $e");
    }
  }

  // Fetch active Offers for the Store
  Future<void> fetchOffers() async {
    _logger.i('Fetching offers...');
    try {
      final offerDocs = await _firestore
          .collection('offers')
          .where('store_id', isEqualTo: "p2HNRulZDPyjYcSMgvRP") // Only fetch active offers
          .get();
      _logger.i('Offers fetched: ${offerDocs.docs.length}');

      offers.assignAll(
        offerDocs.docs.map((doc) {
          try {
            return Offer.fromDocument(doc);
          } catch (e) {
            _logger.e('Error processing offer: $e');
            return null;
          }
        }).whereType<Offer>().toList(),
      );
    } catch (e) {
      _logger.e('Failed to load offers: $e');
      errorMessage("Failed to load offers: $e");
    }
  }


  List<Product> getProductsByCategory(String category) {
    return filteredMenuItems.where((p) => p.category == category).toList();
  }
}

