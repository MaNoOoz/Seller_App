// Category Model
import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String categoryId;
  final String categoryName;

  Category({required this.categoryId, required this.categoryName});

  factory Category.fromDocument(DocumentSnapshot doc) {
    return Category(
      categoryId: doc['categoryId'],
      categoryName: doc['categoryName'],
    );
  }
}

// Product Model
