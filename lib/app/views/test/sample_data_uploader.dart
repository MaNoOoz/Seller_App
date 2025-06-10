import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class SampleDataUploader {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Random _random = Random();

  /// Generates a random alphanumeric string for IDs.
  String _generateRandomId({int length = 20}) {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(Iterable.generate(
      length,
          (_) => chars.codeUnitAt(_random.nextInt(chars.length)),
    ));
  }

  /// Generates a random phone number with a Saudi Arabian prefix.
  String _generateRandomPhoneNumber() {
    final List<String> prefixes = ['050', '054', '056', '059'];
    final String randomPrefix = prefixes[_random.nextInt(prefixes.length)];
    String number = '';
    for (int i = 0; i < 7; i++) {
      number += _random.nextInt(10).toString();
    }
    return randomPrefix + number;
  }

  /// Generates sample product data.
  Map<String, dynamic> _generateSampleProduct() {
    final List<String> categories = ['Electronics', 'Clothing', 'Books', 'Home Goods', 'Food', 'Beauty'];
    final List<String> productNames = [
      'Smartphone X', 'Designer T-Shirt', 'Mystery Novel', 'Smart Coffee Maker',
      'Organic Apples', 'Hydrating Serum', 'Laptop Pro', 'Running Shoes',
      'Cookbook Classics', 'Ergonomic Chair', 'Fresh Bread', 'Sunscreen SPF50'
    ];

    return {
      'name': productNames[_random.nextInt(productNames.length)],
      'description': 'A high-quality product designed for everyday use.',
      'image_url': 'https://picsum.photos/seed/${_generateRandomId(length: 5)}/400/300',
      'price': double.parse((_random.nextDouble() * 100 + 10).toStringAsFixed(2)), // Price between 10 and 110
      'category': categories[_random.nextInt(categories.length)],
      'available': _random.nextDouble() > 0.1, // 90% chance of being available
    };
  }

  /// Generates sample offer data.
  Map<String, dynamic> _generateSampleOffer() {
    final List<String> titles = ['Summer Sale', 'Grand Opening Discount', 'Flash Deal', 'Holiday Special', 'Buy One Get One'];
    final List<String> descriptions = [
      'Enjoy amazing discounts on selected items!',
      'Limited time offer, don\'t miss out!',
      'Huge savings for our loyal customers.',
      'Get ready for the best deals of the season.'
    ];

    final DateTime startDate = DateTime.now();
    final DateTime endDate = startDate.add(Duration(days: _random.nextInt(30) + 7)); // Offer lasts 7-36 days

    return {
      'title': titles[_random.nextInt(titles.length)],
      'description': descriptions[_random.nextInt(descriptions.length)],
      'image_url': 'https://picsum.photos/seed/${_generateRandomId(length: 5)}/800/450',
      'start_date': Timestamp.fromDate(startDate),
      'end_date': Timestamp.fromDate(endDate),
    };
  }

  /// Posts a specified number of sample stores to Firestore.
  /// Each store will have a few sample products and offers.
  ///
  /// [numberOfStores]: The number of sample stores to create.
  /// [ownerUid]: The UID of the user who "owns" these stores (optional, for testing).
  Future<void> postSampleStores({
    required int numberOfStores,
    String ownerUid = 'sampleUserForTestingUID', // Default UID if not provided
  }) async {
    print('Starting to post $numberOfStores sample stores...');

    for (int i = 0; i < numberOfStores; i++) {
      final String storeId = _generateRandomId();
      final String phoneNumber = _generateRandomPhoneNumber();

      final Map<String, dynamic> storeData = {
        'name': 'Sample Store ${i + 1}',
        'logo_url': 'https://picsum.photos/seed/$storeId/100/100',
        'phone': phoneNumber,
        'location': 'Lat: ${30.0 + _random.nextDouble() * 5.0}, Lng: ${40.0 + _random.nextDouble() * 5.0}', // Random coordinates
        'social': {
          'instagram': 'https://instagram.com/store$storeId',
          'facebook': 'https://facebook.com/store$storeId',
          'whatsapp': 'https://wa.me/${phoneNumber.replaceFirst('0', '966')}' // Replace 0 with 966 for Saudi
        },
        'created_at': FieldValue.serverTimestamp(),
        'created_by': ownerUid,
      };

      try {
        // Add the store document
        await _firestore.collection('stores').doc(storeId).set(storeData);
        print('Store $storeId created.');

        // Add sample products to the subcollection
        final int numProducts = _random.nextInt(5) + 2; // 2-6 products per store
        for (int j = 0; j < numProducts; j++) {
          final String productId = _generateRandomId();
          final Map<String, dynamic> productData = _generateSampleProduct();
          await _firestore.collection('stores').doc(storeId).collection('products').doc(productId).set(productData);
          // print('  - Product $productId added to $storeId'); // Uncomment for verbose logging
        }
        print('  - $numProducts products added to $storeId.');

        // Add sample offers to the subcollection
        final int numOffers = _random.nextInt(3) + 1; // 1-3 offers per store
        for (int k = 0; k < numOffers; k++) {
          final String offerId = _generateRandomId();
          final Map<String, dynamic> offerData = _generateSampleOffer();
          await _firestore.collection('stores').doc(storeId).collection('offers').doc(offerId).set(offerData);
          // print('  - Offer $offerId added to $storeId'); // Uncomment for verbose logging
        }
        print('  - $numOffers offers added to $storeId.');

      } catch (e) {
        print('Error creating store $storeId: $e');
      }
    }
    print('Finished posting $numberOfStores sample stores.');
  }
}