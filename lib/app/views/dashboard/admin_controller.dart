import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;

class AdminController extends GetxController {
  final isLoading = false.obs;
  final error = ''.obs;

  Future<void> createShop({
    required String name,
    required String description,
    required String phone,
    required String city,
    required String location,
    required XFile logoXFile,
    required Map<String, String> socialLinks,
  }) async {
    isLoading.value = true;
    error.value = '';
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('المستخدم غير مسجل الدخول');

      final storesRef = FirebaseFirestore.instance.collection('stores');

      // ننشئ الوثيقة أولاً حتى نحصل على storeId
      final docRef = await storesRef.add({
        'name': name,
        'description': description,
        'phone': phone,
        'city': city,
        'location': location,
        'social': socialLinks,
        'created_by': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'logoUrl': '', // نضيفه لاحقاً بعد الرفع
      });

      final storeId = docRef.id;

      // رفع الصورة إلى Cloudinary داخل فولدر المتجر
      final cloudinaryUrl = await uploadImageToCloudinary(
        file: logoXFile,
        folder: 'stores/$storeId',
      );

      // تحديث الوثيقة بعد رفع الصورة
      await docRef.update({'logoUrl': cloudinaryUrl});

      Get.back(); // رجوع بعد النجاح
    } catch (e) {
      error.value = 'خطأ أثناء إنشاء المتجر: $e';
    } finally {
      isLoading.value = false;
    }
  }


  Future<String> uploadImageToCloudinary({
    required XFile file,
    required String folder,
  }) async {
    final dio = Dio();

    // غير هذول حسب بيانات حسابك على Cloudinary
    const cloudName = 'dn2juvb5i';
    const uploadPreset = 'unsigned_preset';

    final url = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

    final fileBytes = await file.readAsBytes();
    final fileName = file.name;

    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
      'upload_preset': uploadPreset,
      'folder': folder, // هذا هو اسم الفولدر بالـ Cloudinary
    });

    final response = await dio.post(url, data: formData);

    if (response.statusCode == 200) {
      final imageUrl = response.data['secure_url'] as String;
      return imageUrl;
    } else {
      throw Exception('فشل رفع الصورة: ${response.statusMessage}');
    }
  }

}
