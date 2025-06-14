class Store {
  final String id;
  final String name;
  final String description;
  final String logoUrl;
  final String phone;
  final String contactEmail;
  final String city;
  final String location;
  final Map<String, dynamic> social;
  final Map<String, dynamic> workingHours;
  final List<String> deliveryOptions;
  final List<String> paymentMethods;
  final String announcementMessage;
  final bool announcementActive;
  final String status;
  final bool isPublic;

  Store({
    required this.id,
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.phone,
    required this.contactEmail,
    required this.city,
    required this.location,
    required this.social,
    required this.workingHours,
    required this.deliveryOptions,
    required this.paymentMethods,
    required this.announcementMessage,
    required this.announcementActive,
    required this.status,
    this.isPublic = false,
  });

  // Updated fromMap to reflect removed fields
  factory Store.fromMap(String id, Map<String, dynamic> map) {
    return Store(
      id: id,
      name: map['name'] as String? ?? 'N/A',
      description: map['description'] as String? ?? 'N/A',
      logoUrl: map['logo_url'] as String? ?? 'https://placehold.co/100x100/CCCCCC/000000?text=Logo',
      phone: map['phone'] as String? ?? 'N/A',
      contactEmail: map['contact_email'] as String? ?? 'N/A',
      city: map['city'] as String? ?? 'N/A',
      location: map['location'] as String? ?? 'N/A',
      social: Map<String, dynamic>.from(map['social'] ?? {}),
      workingHours: Map<String, dynamic>.from(map['working_hours'] ?? {}),
      deliveryOptions: List<String>.from(map['delivery_options'] ?? []),
      paymentMethods: List<String>.from(map['payment_methods'] ?? []),
      announcementMessage: map['announcement_message'] as String? ?? '',
      announcementActive: map['announcement_active'] as bool? ?? false,
      status: map['status'] as String? ?? 'N/A',
      isPublic: map['is_public'] as bool? ?? false,
    );
  }

  // toJson method if you need to convert back to map (e.g., for Firestore writes)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'logo_url': logoUrl,
      'phone': phone,
      'contact_email': contactEmail,
      'city': city,
      'location': location,
      'social': social,
      'working_hours': workingHours,
      'delivery_options': deliveryOptions,
      'payment_methods': paymentMethods,
      'announcement_message': announcementMessage,
      'announcement_active': announcementActive,
      'status': status,
      'is_public': isPublic,
      // You might add FieldValue.serverTimestamp() for createdAt/updatedAt
      // in your Firestore write operations, rather than directly in the model.
    };
  }
}
