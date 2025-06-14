import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // لاستخدام @required

class StoreModel {
  final String id; // معرف الوثيقة (storeId)
  final String name;
  final String description;
  final String logoUrl;
  final String phone;
  final String contactEmail; // حقل جديد
  final String city;
  final String location;
  final Map<String, String> social; // لروابط التواصل الاجتماعي
  final List<String> deliveryOptions; // حقل جديد لخيارات التوصيل
  final List<String> paymentMethods; // حقل جديد لطرق الدفع
  final String announcementMessage; // حقل جديد لرسالة الإعلان
  final bool announcementActive; // حقل جديد لتفعيل/تعطيل رسالة الإعلان
  final String createdBy;
  final Timestamp createdAt;
  final Timestamp? updatedAt; // حقل جديد، قد يكون Null في البداية
  final String status; // حقل جديد للحالة

  StoreModel({
    required this.id,
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.phone,
    required this.contactEmail,
    required this.city,
    required this.location,
    required this.social,
    required this.deliveryOptions,
    required this.paymentMethods,
    required this.announcementMessage,
    required this.announcementActive,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt, // ليس مطلوبًا عند الإنشاء
    required this.status,
  });

  // Factory constructor لإنشاء StoreModel من DocumentSnapshot
  factory StoreModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StoreModel.fromMap(doc.id, data);
  }

  // Factory constructor لإنشاء StoreModel من Map (مثلاً عند التحديث أو إضافة بيانات جديدة)
  factory StoreModel.fromMap(String id, Map<String, dynamic> map) {
    return StoreModel(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      logoUrl: map['logo_url'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      contactEmail: map['contact_email'] as String? ?? '',
      city: map['city'] as String? ?? '',
      location: map['location'] as String? ?? '',
      social: Map<String, String>.from(map['social'] as Map? ?? {}),
      deliveryOptions: List<String>.from(map['delivery_options'] as List? ?? []),
      paymentMethods: List<String>.from(map['payment_methods'] as List? ?? []),
      announcementMessage: map['announcement_message'] as String? ?? '',
      announcementActive: map['announcement_active'] as bool? ?? false,
      createdBy: map['created_by'] as String? ?? '',
      createdAt: map['created_at'] as Timestamp? ?? Timestamp.now(),
      updatedAt: map['updated_at'] as Timestamp?, // يمكن أن يكون null
      status: map['status'] as String? ?? 'active',
    );
  }

  // تحويل StoreModel إلى Map<String, dynamic> ليتم إضافته أو تحديثه في Firestore
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
      'delivery_options': deliveryOptions,
      'payment_methods': paymentMethods,
      'announcement_message': announcementMessage,
      'announcement_active': announcementActive,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt, // يمكن أن يكون null، Firestore سيتجاهل ذلك إذا كان كذلك
      'status': status,
    };
  }

  // لإنشاء نسخة جديدة من StoreModel مع تغيير بعض الحقول بسهولة (immutability)
  StoreModel copyWith({
    String? id,
    String? name,
    String? description,
    String? logoUrl,
    String? phone,
    String? contactEmail,
    String? city,
    String? location,
    Map<String, String>? social,
    Map<String, String>? workingHours,
    List<String>? deliveryOptions,
    List<String>? paymentMethods,
    String? announcementMessage,
    bool? announcementActive,
    String? createdBy,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    String? status,
  }) {
    return StoreModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      phone: phone ?? this.phone,
      contactEmail: contactEmail ?? this.contactEmail,
      city: city ?? this.city,
      location: location ?? this.location,
      social: social ?? this.social,
      deliveryOptions: deliveryOptions ?? this.deliveryOptions,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      announcementMessage: announcementMessage ?? this.announcementMessage,
      announcementActive: announcementActive ?? this.announcementActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'StoreModel(id: $id, name: $name, description: $description, logoUrl: $logoUrl, phone: $phone, contactEmail: $contactEmail, city: $city, location: $location, social: $social,  deliveryOptions: $deliveryOptions, paymentMethods: $paymentMethods, announcementMessage: $announcementMessage, announcementActive: $announcementActive, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, status: $status)';
  }
}

class ProductModel {
  final String id; // معرف الوثيقة (productId)
  final String storeId; // معرف المتجر الذي ينتمي إليه المنتج
  final String name;
  final String description;
  final double price;
  final String category; // مثال: "مشروبات ساخنة", "معجنات", "وجبات رئيسية"
  final List<String> images; // قائمة بروابط الصور
  final bool isAvailable; // هل المنتج متوفر حاليًا؟
  final Timestamp createdAt;
  final Timestamp? updatedAt; // (جديد) وقت آخر تحديث للمنتج

  // حقول جديدة خاصة بالمطاعم/الكافيهات
  final String? sku; // (اختياري) معرف المنتج في المخزون
  final List<String>? allergens; // مسببات الحساسية (مثال: "جلوتين", "مكسرات", "حليب")
  final String? dietaryInfo; // معلومات غذائية (مثال: "نباتي", "خالي من الجلوتين", "حلال")
  final bool isFeatured; // هل المنتج مميز/مقترح (للعرض في الواجهة الرئيسية)
  final int? preparationTimeMinutes; // وقت التحضير بالدقائق

  ProductModel({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.images,
    required this.isAvailable,
    required this.createdAt,
    this.updatedAt,
    this.sku,
    this.allergens,
    this.dietaryInfo,
    required this.isFeatured,
    this.preparationTimeMinutes,
  });

  factory ProductModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel.fromMap(doc.id, data);
  }

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      storeId: map['store_id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] as String? ?? '',
      images: List<String>.from(map['images'] as List? ?? []),
      isAvailable: map['is_available'] as bool? ?? false,
      createdAt: map['created_at'] as Timestamp? ?? Timestamp.now(),
      updatedAt: map['updatedAt'] as Timestamp?,
      sku: map['sku'] as String?,
      allergens: (map['allergens'] as List?)?.map((e) => e as String).toList(),
      dietaryInfo: map['dietary_info'] as String?,
      isFeatured: map['is_featured'] as bool? ?? false,
      preparationTimeMinutes: map['preparation_time_minutes'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'store_id': storeId,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'images': images,
      'is_available': isAvailable,
      'created_at': createdAt,
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(), // يتم التحديث عند الإضافة/التعديل
      'sku': sku,
      'allergens': allergens,
      'dietary_info': dietaryInfo,
      'is_featured': isFeatured,
      'preparation_time_minutes': preparationTimeMinutes,
    };
  }

  ProductModel copyWith({
    String? id,
    String? storeId,
    String? name,
    String? description,
    double? price,
    String? category,
    List<String>? images,
    bool? isAvailable,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    String? sku,
    List<String>? allergens,
    String? dietaryInfo,
    bool? isFeatured,
    int? preparationTimeMinutes,
  }) {
    return ProductModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      images: images ?? this.images,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sku: sku ?? this.sku,
      allergens: allergens ?? this.allergens,
      dietaryInfo: dietaryInfo ?? this.dietaryInfo,
      isFeatured: isFeatured ?? this.isFeatured,
      preparationTimeMinutes: preparationTimeMinutes ?? this.preparationTimeMinutes,
    );
  }

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, price: $price, category: $category, isAvailable: $isAvailable, storeId: $storeId)';
  }
}

class OfferModel {
  final String id; // معرف الوثيقة (offerId)
  final String storeId; // معرف المتجر الذي ينتمي إليه العرض
  final String title;
  final String description;
  final String offerType; // (مثال: "percentage", "fixed_amount", "buy_one_get_one")
  final double offerValue; // قيمة الخصم (مثال: 20.0 لـ 20%, 50.0 لـ 50 ريال)
  final Timestamp startDate;
  final Timestamp endDate;
  final bool isActive; // هل العرض نشط حاليًا؟
  final String bannerImageUrl; // رابط صورة البانر الخاص بالعرض
  final Timestamp createdAt;
  final Timestamp? updatedAt; // (جديد) وقت آخر تحديث للعرض

  // حقول جديدة خاصة بالعروض
  final String? offerCode; // (اختياري) رمز الخصم إذا كان العرض يتطلبه (مثال: "EID2025")
  final double? minPurchaseAmount; // الحد الأدنى لمبلغ الشراء لتفعيل العرض
  final List<String>? applicableProducts; // (اختياري) قائمة بمعرفات المنتجات التي ينطبق عليها العرض
  final int? redemptionLimit; // (اختياري) الحد الأقصى لعدد مرات استخدام العرض
  final int? currentRedemptions; // (اختياري) عدد مرات استخدام العرض حاليًا (يُحدّث عبر Backend)

  OfferModel({
    required this.id,
    required this.storeId,
    required this.title,
    required this.description,
    required this.offerType,
    required this.offerValue,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.bannerImageUrl,
    required this.createdAt,
    this.updatedAt,
    this.offerCode,
    this.minPurchaseAmount,
    this.applicableProducts,
    this.redemptionLimit,
    this.currentRedemptions,
  });

  factory OfferModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OfferModel.fromMap(doc.id, data);
  }

  factory OfferModel.fromMap(String id, Map<String, dynamic> map) {
    return OfferModel(
      id: id,
      storeId: map['store_id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      offerType: map['offer_type'] as String? ?? '',
      offerValue: (map['offer_value'] as num?)?.toDouble() ?? 0.0,
      startDate: map['start_date'] as Timestamp? ?? Timestamp.now(),
      endDate: map['end_date'] as Timestamp? ?? Timestamp.now(),
      isActive: map['is_active'] as bool? ?? false,
      bannerImageUrl: map['banner_image_url'] as String? ?? '',
      createdAt: map['created_at'] as Timestamp? ?? Timestamp.now(),
      updatedAt: map['updatedAt'] as Timestamp?,
      offerCode: map['offer_code'] as String?,
      minPurchaseAmount: (map['min_purchase_amount'] as num?)?.toDouble(),
      applicableProducts: (map['applicable_products'] as List?)?.map((e) => e as String).toList(),
      redemptionLimit: map['redemption_limit'] as int?,
      currentRedemptions: map['current_redemptions'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'store_id': storeId,
      'title': title,
      'description': description,
      'offer_type': offerType,
      'offer_value': offerValue,
      'start_date': startDate,
      'end_date': endDate,
      'is_active': isActive,
      'banner_image_url': bannerImageUrl,
      'created_at': createdAt,
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
      'offer_code': offerCode,
      'min_purchase_amount': minPurchaseAmount,
      'applicable_products': applicableProducts,
      'redemption_limit': redemptionLimit,
      'current_redemptions': currentRedemptions,
    };
  }

  OfferModel copyWith({
    String? id,
    String? storeId,
    String? title,
    String? description,
    String? offerType,
    double? offerValue,
    Timestamp? startDate,
    Timestamp? endDate,
    bool? isActive,
    String? bannerImageUrl,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    String? offerCode,
    double? minPurchaseAmount,
    List<String>? applicableProducts,
    int? redemptionLimit,
    int? currentRedemptions,
  }) {
    return OfferModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      title: title ?? this.title,
      description: description ?? this.description,
      offerType: offerType ?? this.offerType,
      offerValue: offerValue ?? this.offerValue,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      offerCode: offerCode ?? this.offerCode,
      minPurchaseAmount: minPurchaseAmount ?? this.minPurchaseAmount,
      applicableProducts: applicableProducts ?? this.applicableProducts,
      redemptionLimit: redemptionLimit ?? this.redemptionLimit,
      currentRedemptions: currentRedemptions ?? this.currentRedemptions,
    );
  }

  @override
  String toString() {
    return 'OfferModel(id: $id, title: $title, offerType: $offerType, value: $offerValue, isActive: $isActive, storeId: $storeId)';
  }
}