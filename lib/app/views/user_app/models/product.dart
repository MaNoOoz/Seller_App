import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String category;
  final Timestamp createdAt;
  final String description;
  final List<String> images;  // images is a list, which may not exist
  final bool isAvailable;
  final String name;
  final double price;
  final String storeId;

  Product({
    required this.category,
    required this.createdAt,
    required this.description,
    required this.images,
    required this.isAvailable,
    required this.name,
    required this.price,
    required this.storeId,
  });

  // Convert Firestore document to Product
  factory Product.fromDocument(DocumentSnapshot doc) {
    return Product(
      category: doc['category'] ?? '',  // Default to empty string if missing
      createdAt: doc['created_at'] ?? Timestamp.now(),
      description: doc['description'] ?? '',
      // Check if 'images' field exists and is a list; if not, default to empty list
      images: doc['images'] != null && doc['images'] is List
          ? List<String>.from(doc['images'])
          : [],
      isAvailable: doc['is_available'] ?? false,
      name: doc['name'] ?? '',
      price: (doc['price'] ?? 0).toDouble(),
      storeId: doc['store_id'] ?? '',
    );
  }
}
