import 'dart:math';

import 'package:app/app/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class methodTset {
  var logger = Logger();

  Future<void> addSampleOffers(var storeId) async {
    storeId = "RcVKmNMF374n40X7Ok9o";
    final sampleOffers = [
      {
        'title': 'عرض خاص على الهواتف',
        'description': 'تخفيض 20% على جميع الهواتف الذكية!',
        'value': 20.0,
        'startDate': Timestamp.fromDate(DateTime.now()),
        'endDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 7))),
        'storeId': storeId, // Replace with actual storeId
        'offerType': 'percentage',
        'isActive': true,
        'bannerImageUrl': 'https://via.placeholder.com/300x150',
      },
      {
        'title': 'عرض اشتراك سنوي',
        'description': 'احصل على اشتراك سنوي بسعر مخفض 25%!',
        'value': 25.0,
        'startDate': Timestamp.fromDate(DateTime.now()),
        'endDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 10))),
        'storeId': storeId,
        'offerType': 'percentage',
        'isActive': true,
        'bannerImageUrl': 'https://via.placeholder.com/300x150',
      },
      // Add 3 more offers in the same way
    ];

    for (var offer in sampleOffers) {
      await FirebaseFirestore.instance.collection(AppConstants.offersCollection).add(offer);
    }
  }
  // using
  // addSampleOffers("RcVKmNMF374n40X7Ok9o");

  // add new store
// tester

  // ===========================================================================================
  Future<void> generateTestStoreForCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('❌ No user logged in.');
      return;
    }

    final uid = user.uid;

    // Check if the user already has a store before creating one
    bool hasStore = await _checkIfUserHasStore(uid);
    if (hasStore) {
      print('❌ User already has a store.');
      return;
    }

    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final fakeStore = {
      'name': 'متجر تجريبي', // اسم المتجر
      'description': 'وصف المتجر التجريبي', // وصف المتجر
      'logo_url': 'https://example.com/logo.png', // رابط الشعار
      'phone': '1234567890', // رقم الهاتف
      'contact_email': 'test@example.com', // البريد الإلكتروني
      'city': 'المدينة التجريبية', // المدينة
      'location': 'الموقع التجريبي', // الموقع
      'social': {
        'facebook': 'https://facebook.com/test', // رابط الفيسبوك
        'instagram': 'https://instagram.com/test', // رابط الإنستغرام
      },
      'working_hours': {
        'monday': '9 صباحًا - 5 مساءً', // ساعات العمل
        'tuesday': '9 صباحًا - 5 مساءً',
        'wednesday': '9 صباحًا - 5 مساءً',
        'thursday': '9 صباحًا - 5 مساءً',
        'friday': 'مغلق', // يوم الجمعة مغلق
        'saturday': '9 صباحًا - 5 مساءً',
        'sunday': '9 صباحًا - 5 مساءً',
      },
      'delivery_options': ['استلام من المتجر', 'توصيل'], // خيارات التوصيل
      'payment_methods': ['نقدًا', 'بطاقة ائتمان'], // طرق الدفع
      'announcement_message': 'تخفيضات ضخمة اليوم!', // رسالة الإعلان
      'announcement_active': true, // تفعيل الإعلان
      'created_by': uid, // معرّف المستخدم الذي أنشأ المتجر
      'created_at': Timestamp.now(), // وقت الإنشاء
      'updated_at': Timestamp.now(), // وقت التحديث
      'status': 'نشط', // حالة المتجر
    };


    try {
      await FirebaseFirestore.instance.collection(AppConstants.storesCollection).add(fakeStore);
      print('✅ Test store added successfully for user $uid');
    } catch (e) {
      print('❌ Failed to add test store: $e');
    }
  }

  Future<bool> _checkIfUserHasStore(String uid) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection(AppConstants.storesCollection) // Use the stores collection constant
          .where('created_by', isEqualTo: uid) // Use 'created_by'
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      logger.e('Error checking for user store: $e');
      return false; // Assume no store on error
    }
  }
  // use
  // await generateTestStoreForCurrentUser();


// How to call this function:
// In your main or a relevant part of your app where you want to generate data:
// await generateRealProductsAndOffers('p2HNRulZDPyjYcSMgvRP');
}

// Ensure this AppConstants class matches your ProductModel and OfferModel toJson() field names
class AppConstants {
  // Collections
  static const String productsCollection = 'products';
  static const String offersCollection = 'offers';
  static const String storesCollection = 'stores'; // Good practice to have if used elsewhere

  // Common Fields
  static const String storeIdField = 'store_id';
  static const String createdAtField = 'created_at';
  static const String updatedAtField = 'updatedAt'; // Matches ProductModel/OfferModel toJson() casing

  // Product Fields (matching ProductModel toJson() )
  static const String nameField = 'name';
  static const String descriptionField = 'description';
  static const String priceField = 'price';
  static const String categoryField = 'category';
  static const String imagesField = 'images'; // Matches ProductModel toJson()
  static const String isAvailableField = 'is_available';
  static const String skuField = 'sku';
  static const String allergensField = 'allergens';
  static const String dietaryInfoField = 'dietary_info';
  static const String isFeaturedField = 'is_featured';
  static const String preparationTimeMinutesField = 'preparation_time_minutes';

  // Offer Fields (matching OfferModel toJson() )
  static const String offerTitleField = 'title'; // Matches OfferModel toJson()
  static const String offerDescriptionField = 'description'; // Matches OfferModel toJson()
  static const String offerTypeField = 'offer_type';
  static const String offerValueField = 'offer_value';
  static const String startDateField = 'start_date';
  static const String endDateField = 'end_date';
  static const String isActiveField = 'is_active'; // Matches OfferModel toJson()
  static const String bannerImageUrlField = 'banner_image_url';
  static const String offerCodeField = 'offer_code';
  static const String minPurchaseAmountField = 'min_purchase_amount';
  static const String applicableProductsField = 'applicable_products';
  static const String redemptionLimitField = 'redemption_limit';
  static const String currentRedemptionsField = 'current_redemptions';
}

  Future<void> generateRealProductsAndOffers(String storeId) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Real Product Data with Arabic Names, Diverse Categories, and Image URLs ---
  List<Map<String, dynamic>> productsData = [
    {
      AppConstants.nameField: 'هاتف ذكي متطور',
      AppConstants.descriptionField: 'أداء عالي وكاميرا احترافية، مناسب للاستخدام اليومي والمهني.',
      AppConstants.priceField: 2500.0,
      AppConstants.categoryField: 'إلكترونيات',
      AppConstants.imagesField: ['https://placehold.co/600x400/000000/FFFFFF?text=SmartPhone'],
      AppConstants.isAvailableField: true,
      AppConstants.isFeaturedField: true,
      AppConstants.preparationTimeMinutesField: null, // Example: null for non-food items
    },
    {
      AppConstants.nameField: 'سماعات بلوتوث لاسلكية',
      AppConstants.descriptionField: 'صوت نقي وباس عميق، مريحة للاستخدام الطويل، بطارية تدوم طويلاً.',
      AppConstants.priceField: 350.0,
      AppConstants.categoryField: 'إلكترونيات',
      AppConstants.imagesField: ['https://placehold.co/600x400/121212/FFFFFF?text=Headphones'],
      AppConstants.isAvailableField: true,
      AppConstants.isFeaturedField: false,
      AppConstants.preparationTimeMinutesField: null,
    },
    {
      AppConstants.nameField: 'شاحن متنقل فائق السرعة',
      AppConstants.descriptionField: 'سعة كبيرة لشحن أجهزتك عدة مرات، يدعم الشحن السريع.',
      AppConstants.priceField: 150.0,
      AppConstants.categoryField: 'إلكترونيات',
      AppConstants.imagesField: ['https://placehold.co/600x400/333333/FFFFFF?text=PowerBank'],
      AppConstants.isAvailableField: true,
      AppConstants.isFeaturedField: false,
      AppConstants.preparationTimeMinutesField: null,
    },
    {
      AppConstants.nameField: 'بيتزا مارجريتا',
      AppConstants.descriptionField: 'بيتزا إيطالية كلاسيكية بجبنة الموزاريلا وصلصة الطماطم الطازجة.',
      AppConstants.priceField: 45.0,
      AppConstants.categoryField: 'وجبات رئيسية',
      AppConstants.imagesField: ['https://placehold.co/600x400/FF5733/FFFFFF?text=Pizza'],
      AppConstants.isAvailableField: true,
      AppConstants.allergensField: ['جلوتين', 'حليب'],
      AppConstants.dietaryInfoField: 'نباتي',
      AppConstants.isFeaturedField: true,
      AppConstants.preparationTimeMinutesField: 20,
    },
    {
      AppConstants.nameField: 'سلطة السيزر بالدجاج',
      AppConstants.descriptionField: 'خس روماني طازج، دجاج مشوي، خبز محمص، جبنة بارميزان وصلصة سيزر.',
      AppConstants.priceField: 35.0,
      AppConstants.categoryField: 'سلطات',
      AppConstants.imagesField: ['https://placehold.co/600x400/33FF57/000000?text=Caesar+Salad'],
      AppConstants.isAvailableField: true,
      AppConstants.allergensField: ['جلوتين', 'بيض', 'حليب'],
      AppConstants.dietaryInfoField: 'غني بالبروتين',
      AppConstants.isFeaturedField: false,
      AppConstants.preparationTimeMinutesField: 15,
    },
    {
      AppConstants.nameField: 'قهوة اسبريسو',
      AppConstants.descriptionField: 'قهوة مركزة وغنية، مثالية لبداية اليوم.',
      AppConstants.priceField: 15.0,
      AppConstants.categoryField: 'مشروبات ساخنة',
      AppConstants.imagesField: ['https://placehold.co/600x400/3366FF/FFFFFF?text=Espresso'],
      AppConstants.isAvailableField: true,
      AppConstants.isFeaturedField: true,
      AppConstants.preparationTimeMinutesField: 3,
    },
    {
      AppConstants.nameField: 'عصير برتقال طازج',
      AppConstants.descriptionField: 'عصير طبيعي 100% من أجود أنواع البرتقال.',
      AppConstants.priceField: 20.0,
      AppConstants.categoryField: 'مشروبات باردة',
      AppConstants.imagesField: ['https://placehold.co/600x400/FF9933/FFFFFF?text=Orange+Juice'],
      AppConstants.isAvailableField: true,
      AppConstants.isFeaturedField: false,
      AppConstants.preparationTimeMinutesField: 5,
    },
    {
      AppConstants.nameField: 'كوكيز الشوكولاتة',
      AppConstants.descriptionField: 'كوكيز طازج برقائق الشوكولاتة الذائبة.',
      AppConstants.priceField: 10.0,
      AppConstants.categoryField: 'حلويات',
      AppConstants.imagesField: ['https://placehold.co/600x400/CC99FF/FFFFFF?text=Cookies'],
      AppConstants.isAvailableField: true,
      AppConstants.allergensField: ['جلوتين', 'حليب', 'بيض'],
      AppConstants.isFeaturedField: false,
      AppConstants.preparationTimeMinutesField: 10,
    },
    {
      AppConstants.nameField: 'كتاب الطبخ العربي',
      AppConstants.descriptionField: 'مجموعة مختارة من الوصفات العربية الأصيلة.',
      AppConstants.priceField: 80.0,
      AppConstants.categoryField: 'كتب',
      AppConstants.imagesField: ['https://placehold.co/600x400/66CC66/FFFFFF?text=Cookbook'],
      AppConstants.isAvailableField: true,
      AppConstants.isFeaturedField: false,
      AppConstants.preparationTimeMinutesField: null,
    },
    {
      AppConstants.nameField: 'عطر فاخر للرجال',
      AppConstants.descriptionField: 'رائحة جذابة تدوم طويلاً، مزيج من الأخشاب والتوابل.',
      AppConstants.priceField: 600.0,
      AppConstants.categoryField: 'عطور',
      AppConstants.imagesField: ['https://placehold.co/600x400/999999/FFFFFF?text=Mens+Perfume'],
      AppConstants.isAvailableField: true,
      AppConstants.isFeaturedField: true,
      AppConstants.preparationTimeMinutesField: null,
    },
  ];

  // --- Real Offer Data with Arabic Titles and Descriptions ---
  List<Map<String, dynamic>> offersData = [
    {
      AppConstants.offerTitleField: 'خصم 25% على المشروبات الساخنة',
      AppConstants.offerDescriptionField: 'استمتع بقهوتك المفضلة بخصم مميز هذا الأسبوع.',
      AppConstants.offerTypeField: 'percentage',
      AppConstants.offerValueField: 25.0,
      AppConstants.startDateField: Timestamp.now(),
      AppConstants.endDateField: Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
      AppConstants.isActiveField: true,
      AppConstants.bannerImageUrlField: 'https://placehold.co/800x200/FFCC00/000000?text=Hot+Drinks+Offer',
      AppConstants.offerCodeField: 'HOT25',
      AppConstants.minPurchaseAmountField: 0.0,
      AppConstants.applicableProductsField: null, // Or list product IDs if specific
      AppConstants.redemptionLimitField: 100,
    },
    {
      AppConstants.offerTitleField: 'وجبة غداء مجانية عند شراء وجبتين',
      AppConstants.offerDescriptionField: 'عرض خاص على وجبات الغداء، اشترِ اثنين واحصل على الثالث مجانًا.',
      AppConstants.offerTypeField: 'buy_one_get_one',
      AppConstants.offerValueField: 0.0, // Value might be 0 for BOGO types
      AppConstants.startDateField: Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
      AppConstants.endDateField: Timestamp.fromDate(DateTime.now().add(const Duration(days: 5))),
      AppConstants.isActiveField: true,
      AppConstants.bannerImageUrlField: 'https://placehold.co/800x200/66B2FF/000000?text=Lunch+Deal',
      AppConstants.offerCodeField: 'BOGO_LUNCH',
      AppConstants.minPurchaseAmountField: 90.0,
      AppConstants.redemptionLimitField: 50,
    },
    {
      AppConstants.offerTitleField: 'خصم 50 ريال على الهواتف',
      AppConstants.offerDescriptionField: 'خصم مباشر على جميع الهواتف الذكية المتاحة.',
      AppConstants.offerTypeField: 'fixed_amount',
      AppConstants.offerValueField: 50.0,
      AppConstants.startDateField: Timestamp.now(),
      AppConstants.endDateField: Timestamp.fromDate(DateTime.now().add(const Duration(days: 14))),
      AppConstants.isActiveField: true,
      AppConstants.bannerImageUrlField: 'https://placehold.co/800x200/99FF99/000000?text=Phone+Discount',
      AppConstants.offerCodeField: 'PHONE50',
      AppConstants.minPurchaseAmountField: 1000.0,
      AppConstants.applicableProductsField: null,
      AppConstants.redemptionLimitField: 20,
    },
    {
      AppConstants.offerTitleField: 'توصيل مجاني لجميع الطلبات',
      AppConstants.offerDescriptionField: 'لا تدفع رسوم توصيل، استمتع بخدمة التوصيل المجاني داخل المدينة.',
      AppConstants.offerTypeField: 'free_delivery',
      AppConstants.offerValueField: 0.0,
      AppConstants.startDateField: Timestamp.now(),
      AppConstants.endDateField: Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
      AppConstants.isActiveField: true,
      AppConstants.bannerImageUrlField: 'https://placehold.co/800x200/FF99FF/000000?text=Free+Delivery',
      AppConstants.offerCodeField: 'FREEDELIVERY',
      AppConstants.minPurchaseAmountField: 50.0,
      AppConstants.applicableProductsField: null,
      AppConstants.redemptionLimitField: null, // No limit
    },
    {
      AppConstants.offerTitleField: 'عرض خاص على الحلويات',
      AppConstants.descriptionField: 'استمتع بخصم 15% على جميع أنواع الحلويات لدينا.',
      AppConstants.offerTypeField: 'percentage',
      AppConstants.offerValueField: 15.0,
      AppConstants.startDateField: Timestamp.now(),
      AppConstants.endDateField: Timestamp.fromDate(DateTime.now().add(const Duration(days: 10))),
      AppConstants.isActiveField: true,
      AppConstants.bannerImageUrlField: 'https://placehold.co/800x200/CC66FF/000000?text=Dessert+Offer',
      AppConstants.offerCodeField: null, // No code needed
      AppConstants.minPurchaseAmountField: 30.0,
      AppConstants.applicableProductsField: null,
      AppConstants.redemptionLimitField: null,
    },
  ];

  // Specific store ID to use for all generated products and offers
  final String specificStoreId = storeId; // Using the parameter directly

  print('Generating real products for store: $specificStoreId');
  // Generate products
  for (var product in productsData) {
    await _firestore.collection(AppConstants.productsCollection).add({
      ...product, // Spreads existing fields from the map
      AppConstants.storeIdField: specificStoreId, // Use the provided storeId
      AppConstants.createdAtField: FieldValue.serverTimestamp(),
      // updatedAt will be handled by the model's toJson() if null
    });
    print('Added product: ${product[AppConstants.nameField]}');
  }

  print('\nGenerating real offers for store: $specificStoreId');
  // Generate offers
  for (var offer in offersData) {
    await _firestore.collection(AppConstants.offersCollection).add({
      ...offer, // Spreads existing fields from the map
      AppConstants.storeIdField: specificStoreId, // Use the provided storeId
      AppConstants.createdAtField: FieldValue.serverTimestamp(),
      // updatedAt will be handled by the model's toJson() if null
    });
    print('Added offer: ${offer[AppConstants.offerTitleField]}');
  }

  print('\nFinished generating products and offers with image URLs and model-matching fields.');
}