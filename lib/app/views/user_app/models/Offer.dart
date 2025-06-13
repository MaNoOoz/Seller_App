import 'package:cloud_firestore/cloud_firestore.dart';

class Offer {
  final String title;
  final String description;
  final String bannerImageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final String type;
  final double value;

  Offer({
    required this.title,
    required this.description,
    required this.bannerImageUrl,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.value,
  });

  factory Offer.fromDocument(DocumentSnapshot doc) {
    return Offer(
      title: doc['title'] ?? '',
      description: doc['description'] ?? '',
      bannerImageUrl: doc['banner_image_url'] ?? '',
      startDate: (doc['start_date'] as Timestamp).toDate(),
      endDate: (doc['end_date'] as Timestamp).toDate(),
      type: doc['type'] ?? '',
      value: (doc['value'] ?? 0).toDouble(),
    );
  }
}
