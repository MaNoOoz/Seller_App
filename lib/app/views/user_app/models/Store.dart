import 'package:cloud_firestore/cloud_firestore.dart';

class Store {
  final String name;
  final String description;
  final String logoUrl;
  final String location;
  final List<String> paymentMethods;
  final String phone;
  final Map<String, String> social;
  final Map<String, String> workingHours;

  Store({
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.location,
    required this.paymentMethods,
    required this.phone,
    required this.social,
    required this.workingHours,
  });

  factory Store.fromDocument(DocumentSnapshot doc) {
    return Store(
      name: doc['name'] ?? '',
      description: doc['description'] ?? '',
      logoUrl: doc['logo_url'] ?? '',
      location: doc['location'] ?? '',
      paymentMethods: List<String>.from(doc['payment_methods'] ?? []),
      phone: doc['phone'] ?? '',
      social: Map<String, String>.from(doc['social'] ?? {}),
      workingHours: Map<String, String>.from(doc['working_hours'] ?? {}),
    );
  }
}
