import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'constants.dart'; // Ensure AppConstants is imported

class SampleDataGenerator {
  final FirebaseFirestore _firestore;
  final Logger _logger = Logger();

  SampleDataGenerator(this._firestore);

  // --- Generate Sample Stores ---
  Future<void> generateSampleStores(String createdByUid) async {
    _logger.d('Starting to generate sample stores for UID: $createdByUid');

    final storesCollection = _firestore.collection(AppConstants.storesCollection);

    final List<Map<String, dynamic>> sampleStoresData = [
      {
        'name': "مقهى السعادة",
        'description': "مقهى دافئ ومريح يقدم أفضل أنواع القهوة والمخبوزات الطازجة.",
        'logo_url': "https://placehold.co/200x200/F0B27A/333333?text=Coffee",
        'phone': "+966501234567",
        'contact_email': "info@happycafe.com",
        'city': "الرياض",
        'location': "شارع الأمير سلطان، حي الورود، الرياض",
        'social': {
          'instagram': "https://instagram.com/happycafe",
          'facebook': "https://facebook.com/happycafe",
          'whatsapp': "https://wa.me/966501234567",
        },
        'working_hours': {
          "Sunday": "Closed",
          "Monday": "8:00 AM - 10:00 PM",
          "Tuesday": "8:00 AM - 10:00 PM",
          "Wednesday": "8:00 AM - 10:00 PM",
          "Thursday": "8:00 AM - 11:00 PM",
          "Friday": "10:00 AM - 11:00 PM",
          "Saturday": "10:00 AM - 10:00 PM"
        },
        'delivery_options': ["pickup_from_store", "local_delivery"],
        'payment_methods': ["cash_on_delivery", "mada", "visa"],
        'announcement_message': "خصم 15% على جميع المشروبات المثلجة هذا الأسبوع!",
        'announcement_active': true,
        'status': "active",
      },
      {
        'name': "مطعم النخيل الذهبي",
        'description': "تذوق أشهى المأكولات العربية والعالمية في أجواء فاخرة.",
        'logo_url': "https://placehold.co/200x200/4CAF50/FFFFFF?text=Restaurant",
        'phone': "+966551234567",
        'contact_email': "contact@goldenpalm.com",
        'city': "جدة",
        'location': "طريق الملك فهد، حي الشاطئ، جدة",
        'social': {
          'instagram': "https://instagram.com/goldenpalm",
          'facebook': "https://facebook.com/goldenpalm",
          'whatsapp': "https://wa.me/966551234567",
        },
        'working_hours': {
          "Sunday": "1:00 PM - 12:00 AM",
          "Monday": "1:00 PM - 12:00 AM",
          "Tuesday": "1:00 PM - 12:00 AM",
          "Wednesday": "1:00 PM - 12:00 AM",
          "Thursday": "1:00 PM - 1:00 AM",
          "Friday": "2:00 PM - 1:00 AM",
          "Saturday": "1:00 PM - 12:00 AM"
        },
        'delivery_options': ["local_delivery"],
        'payment_methods': ["online_payment", "cash_on_delivery", "mada"],
        'announcement_message': "لدينا قائمة إفطار جديدة ومميزة! تفضلوا بزيارتنا.",
        'announcement_active': true,
        'status': "active",
      },
      {
        'name': "مخبز الكرز الذهبي",
        'description': "أشهى المخبوزات الطازجة والكعك المصنوع بحب يوميًا.",
        'logo_url': "https://placehold.co/200x200/D9376E/FFFFFF?text=Bakery",
        'phone': "+966598765432",
        'contact_email': "orders@cherrybakery.com",
        'city': "الدمام",
        'location': "شارع الأمير نايف، حي النور، الدمام",
        'social': {
          'instagram': "https://instagram.com/cherrybakery",
          'facebook': "https://facebook.com/cherrybakery",
        },
        'working_hours': {
          "Sunday": "9:00 AM - 8:00 PM",
          "Monday": "9:00 AM - 8:00 PM",
          "Tuesday": "9:00 AM - 8:00 PM",
          "Wednesday": "9:00 AM - 8:00 PM",
          "Thursday": "9:00 AM - 8:00 PM",
          "Friday": "Closed",
          "Saturday": "9:00 AM - 8:00 PM"
        },
        'delivery_options': ["pickup_from_store"],
        'payment_methods': ["cash_on_delivery", "visa", "apple_pay"],
        'announcement_message': "عيدكم مبارك! خصم 10% على جميع طلبات الكعك.",
        'announcement_active': true,
        'status': "active",
      },
    ];

    for (var storeData in sampleStoresData) {
      try {
        // Prepare the data map directly for Firestore insertion,
        // using FieldValue.serverTimestamp() for createdAt and updatedAt.
        final Map<String, dynamic> dataForFirestore = {
          'name': storeData['name'],
          'description': storeData['description'],
          'logo_url': storeData['logo_url'],
          'phone': storeData['phone'],
          'contact_email': storeData['contact_email'],
          'city': storeData['city'],
          'location': storeData['location'],
          'social': storeData['social'],
          'working_hours': storeData['working_hours'],
          'delivery_options': storeData['delivery_options'],
          'payment_methods': storeData['payment_methods'],
          'announcement_message': storeData['announcement_message'],
          'announcement_active': storeData['announcement_active'],
          'status': storeData['status'],
          'created_by': createdByUid,
          'createdAt': FieldValue.serverTimestamp(), // هذا هو التعديل الأساسي
          'updatedAt': FieldValue.serverTimestamp(), // هذا هو التعديل الأساسي
        };

        // Add the map directly to Firestore.
        // You do not need to create a StoreModel instance with FieldValue.serverTimestamp().
        final docRef = await storesCollection.add(dataForFirestore);
        _logger.d('Added store: ${storeData['name']} with ID: ${docRef.id}');

        // OPTIONAL: If you want to generate products/offers for each store immediately
        // Uncomment and adjust the following lines:
        // await generateSampleProducts(docRef.id);
        // await generateSampleOffers(docRef.id);

      } catch (e) {
        _logger.d('Error adding store ${storeData['name']}: $e');
      }
    }
    _logger.d('Finished generating sample stores.');
  }

  // --- Existing Product Generation Function (from previous response) ---
  Future<void> generateSampleProducts(String storeId) async {
    _logger.d('Starting to generate sample products for store: $storeId');

    final productsCollection = _firestore.collection(AppConstants.productsCollection);

    final List<Map<String, dynamic>> sampleProducts = [
      {
        'name': "قهوة اسبريسو مزدوجة",
        'description': "جرعتان من الإسبريسو الغني والمركز.",
        'price': 15.00,
        'category': "مشروبات ساخنة",
        'images': ["https://placehold.co/600x400/964B00/FFFFFF?text=Espresso"],
        'is_available': true,
        'sku': "ESPRESSO-D",
        'allergens': [],
        'dietary_info': "خالي من الجلوتين",
        'is_featured': true,
        'preparation_time_minutes': 3,
        'store_id': storeId, // Added store_id
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': "كرواسون باللوز",
        'description': "كرواسون هش ومحشو بكريمة اللوز اللذيذة.",
        'price': 12.00,
        'category': "معجنات",
        'images': ["https://placehold.co/600x400/D2B48C/000000?text=Croissant"],
        'is_available': true,
        'sku': "ALMOND-CR",
        'allergens': ["جلوتين", "مكسرات", "حليب", "بيض"],
        'dietary_info': "يحتوي على جلوتين",
        'is_featured': false,
        'preparation_time_minutes': 2,
        'store_id': storeId, // Added store_id
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': "ساندويتش دجاج بيستو",
        'description': "صدر دجاج مشوي مع صلصة البيستو، الطماطم، والخس في خبز باجيت.",
        'price': 35.50,
        'category': "وجبات رئيسية",
        'images': ["https://placehold.co/600x400/A0C4FF/000000?text=Chicken+Sandwich"],
        'is_available': true,
        'sku': "CHICKEN-PESTO-SW",
        'allergens': ["جلوتين", "مكسرات (صنوبر)", "حليب"],
        'dietary_info': "يحتوي على جبن",
        'is_featured': true,
        'preparation_time_minutes': 8,
        'store_id': storeId, // Added store_id
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': "شاي مثلج بالخوخ",
        'description': "شاي أسود منعش مع نكهة الخوخ الطبيعية.",
        'price': 18.00,
        'category': "مشروبات باردة",
        'images': ["https://placehold.co/600x400/87CEEB/000000?text=Iced+Tea"],
        'is_available': true,
        'sku': "PEACH-ICT",
        'allergens': [],
        'dietary_info': "نباتي",
        'is_featured': false,
        'preparation_time_minutes': 1,
        'store_id': storeId, // Added store_id
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': "كعكة الشوكولاتة الذائبة",
        'description': "كعكة غنية بالشوكولاتة مع قلب سائل دافئ.",
        'price': 28.00,
        'category': "حلويات",
        'images': ["https://placehold.co/600x400/7B3F00/FFFFFF?text=Chocolate+Cake"],
        'is_available': true,
        'sku': "CHOC-CAKE",
        'allergens': ["جلوتين", "حليب", "بيض"],
        'dietary_info': "غني بالسعرات",
        'is_featured': true,
        'preparation_time_minutes': 5,
        'store_id': storeId, // Added store_id
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': "سلطة الكينوا والدجاج",
        'description': "سلطة صحية ولذيذة بالكينوا والدجاج والخضروات الطازجة.",
        'price': 42.00,
        'category': "وجبات رئيسية",
        'images': ["https://placehold.co/600x400/AED6F1/000000?text=Quinoa+Salad"],
        'is_available': true,
        'sku': "QUINOA-SAL",
        'allergens': [],
        'dietary_info': "صحي، خالي من الجلوتين",
        'is_featured': false,
        'preparation_time_minutes': 10,
        'store_id': storeId, // Added store_id
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': "عصير برتقال طازج",
        'description': "عصير برتقال طبيعي 100% معصور حديثًا.",
        'price': 20.00,
        'category': "مشروبات باردة",
        'images': ["https://placehold.co/600x400/FFD580/000000?text=Orange+Juice"],
        'is_available': true,
        'sku': "ORANGE-JUICE",
        'allergens': [],
        'dietary_info': "طبيعي",
        'is_featured': false,
        'preparation_time_minutes': 1,
        'store_id': storeId, // Added store_id
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': "معكرونة بالجبنة",
        'description': "طبق كلاسيكي من المعكرونة بالجبنة الغنية.",
        'price': 30.00,
        'category': "وجبات رئيسية",
        'images': ["https://placehold.co/600x400/FFB6C1/000000?text=Mac+and+Cheese"],
        'is_available': true,
        'sku': "MAC-CHEESE",
        'allergens': ["جلوتين", "حليب"],
        'dietary_info': "غني بالسعرات",
        'is_featured': false,
        'preparation_time_minutes': 12,
        'store_id': storeId, // Added store_id
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': "تشيز كيك التوت",
        'description': "قطعة من التشيز كيك الغني مع طبقة من التوت الطازج.",
        'price': 25.00,
        'category': "حلويات",
        'images': ["https://placehold.co/600x400/FFCCCB/000000?text=Cheesecake"],
        'is_available': true,
        'sku': "BERRY-CC",
        'allergens': ["جلوتين", "حليب", "بيض"],
        'dietary_info': "يحتوي على سكر",
        'is_featured': true,
        'preparation_time_minutes': 3,
        'store_id': storeId, // Added store_id
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': "موكا بارد",
        'description': "مشروب موكا مثلج مثالي للانتعاش في الأيام الحارة.",
        'price': 22.00,
        'category': "مشروبات باردة",
        'images': ["https://placehold.co/600x400/ADD8E6/000000?text=Iced+Mocha"],
        'is_available': true,
        'sku': "ICED-MOCHA",
        'allergens': ["حليب"],
        'dietary_info': "يحتوي على كافيين",
        'is_featured': false,
        'preparation_time_minutes': 4,
        'store_id': storeId, // Added store_id
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var productData in sampleProducts) {
      try {
        // Firestore will automatically generate ID
        // Add createdAt field with server timestamp
        productData['createdAt'] = FieldValue.serverTimestamp();
        // Ensure store_id is set
        productData['store_id'] = storeId;
        await productsCollection.add(productData); // Send the map directly
        _logger.d('Added product: ${productData['name']}');
      } catch (e) {
        _logger.d('Error adding product ${productData['name']}: $e');
      }
    }
    _logger.d('Finished generating sample products.');
  }

  // --- Existing Offer Generation Function (from previous response) ---
  Future<void> generateSampleOffers(String storeId) async {
    _logger.d('Starting to generate sample offers for store: $storeId');

    final offersCollection = _firestore.collection(AppConstants.offersCollection);
    final now = DateTime.now();

    final List<Map<String, dynamic>> sampleOffers = [
      {
        'title': "خصم 20% على القهوة",
        'description': "استمتع بخصم 20% على جميع أنواع القهوة.",
        'offer_type': "percentage",
        'offer_value': 20.0,
        'start_date': Timestamp.fromDate(now.subtract(const Duration(days: 5))),
        'end_date': Timestamp.fromDate(now.add(const Duration(days: 10))),
        'is_active': true,
        'banner_image_url': "https://placehold.co/800x200/A52A2A/FFFFFF?text=Coffee+Offer",
        'offer_code': "COFFEE20",
        'min_purchase_amount': 50.0,
        'applicable_products': [], // يمكن إضافة IDs منتجات محددة هنا
        'redemption_limit': null, // لا يوجد حد
        'current_redemptions': 0,
        'store_id': storeId, // Added store_id
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': "وجبة فطور مجانية",
        'description': "احصل على وجبة فطور مجانية عند شراء مشروبين.",
        'offer_type': "buy_x_get_y", // نوع عرض مخصص
        'offer_value': 0.0,
        'start_date': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
        'end_date': Timestamp.fromDate(now.add(const Duration(days: 7))),
        'is_active': true,
        'banner_image_url': "https://placehold.co/800x200/FFC107/000000?text=Breakfast+Offer",
        'offer_code': null,
        'min_purchase_amount': null,
        'applicable_products': [],
        'redemption_limit': 100,
        'current_redemptions': 0,
        'store_id': storeId, // Added store_id
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': "تخفيض 10 ر.س على الحلويات",
        'description': "تخفيض مباشر بقيمة 10 ر.س على جميع أنواع الحلويات.",
        'offer_type': "fixed_amount",
        'offer_value': 10.0,
        'start_date': Timestamp.fromDate(now.add(const Duration(days: 3))),
        'end_date': Timestamp.fromDate(now.add(const Duration(days: 20))),
        'is_active': false, // سيبدأ في المستقبل
        'banner_image_url': "https://placehold.co/800x200/FF6347/FFFFFF?text=Dessert+Discount",
        'offer_code': "SWEET10",
        'min_purchase_amount': 30.0,
        'applicable_products': [],
        'redemption_limit': null,
        'current_redemptions': 0,
        'store_id': storeId, // Added store_id
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var offerData in sampleOffers) {
      try {
        // Add createdAt field with server timestamp
        offerData['createdAt'] = FieldValue.serverTimestamp();
        // Ensure store_id is set
        offerData['store_id'] = storeId;
        await offersCollection.add(offerData); // Send the map directly
        _logger.d('Added offer: ${offerData['title']}');
      } catch (e) {
        _logger.d('Error adding offer ${offerData['title']}: $e');
      }
    }
    _logger.d('Finished generating sample offers.');
  }
}