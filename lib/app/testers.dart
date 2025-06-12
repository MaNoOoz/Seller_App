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

  // ===========================================================================================



}
