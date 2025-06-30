// // lib/seller_app/modules/create_store/views/create_store_screen.dart
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:cached_network_image/cached_network_image.dart'; // For displaying network image
// import 'dart:io'; // For File.fromUri in non-web
// import 'package:flutter/foundation.dart' show kIsWeb; // For web detection
// import 'dart:typed_data'; // For MemoryImage
//
//
// class CreateStoreScreen extends GetView<CreateStoreController> {
//   const CreateStoreScreen({super.key});
//
//   InputDecoration _inputDecoration(String label, IconData icon, ColorScheme colorScheme) {
//     return InputDecoration(
//       labelText: label,
//       hintText: 'أدخل $label',
//       prefixIcon: Icon(icon, color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: colorScheme.outline),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: colorScheme.primary, width: 2),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.3), width: 1),
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final ColorScheme colorScheme = Theme.of(context).colorScheme;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('إنشاء متجر جديد'),
//         backgroundColor: colorScheme.primaryContainer,
//         foregroundColor: colorScheme.onPrimaryContainer,
//       ),
//       body: Obx(
//             () {
//           if (controller.isStoreCreated.value) {
//             return Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(24.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.check_circle_outline, size: 80, color: colorScheme.primary),
//                     const SizedBox(height: 24),
//                     Text(
//                       'لديك متجر مسجل بالفعل!',
//                       style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: colorScheme.onSurface),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'يمكنك إدارة متجرك من خلال لوحة التحكم.',
//                       style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 32),
//                     ElevatedButton.icon(
//                       onPressed: () => Get.offAllNamed(Routes.DASHBOARD),
//                       icon: const Icon(Icons.dashboard),
//                       label: const Text('الذهاب إلى لوحة التحكم'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: colorScheme.primary,
//                         foregroundColor: colorScheme.onPrimary,
//                         padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }
//
//           if (controller.isLoading.value) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'تفاصيل المتجر',
//                   style: Theme.of(context).textTheme.titleLarge,
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: controller.nameController,
//                   decoration: _inputDecoration('اسم المتجر', Icons.store, colorScheme),
//                   textInputAction: TextInputAction.next,
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: controller.descriptionController,
//                   decoration: _inputDecoration('وصف المتجر', Icons.description, colorScheme),
//                   maxLines: 3,
//                   textInputAction: TextInputAction.newline,
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: controller.phoneController,
//                   decoration: _inputDecoration('رقم الهاتف', Icons.phone, colorScheme),
//                   keyboardType: TextInputType.phone,
//                   textInputAction: TextInputAction.next,
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: controller.contactEmailController,
//                   decoration: _inputDecoration('البريد الإلكتروني للاتصال', Icons.email, colorScheme),
//                   keyboardType: TextInputType.emailAddress,
//                   textInputAction: TextInputAction.next,
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: controller.cityController,
//                         decoration: _inputDecoration('المدينة', Icons.location_city, colorScheme),
//                         textInputAction: TextInputAction.next,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: TextField(
//                         controller: controller.locationController,
//                         decoration: _inputDecoration('العنوان التفصيلي', Icons.map, colorScheme),
//                         textInputAction: TextInputAction.next,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
//
//                 Text(
//                   'شعار المتجر',
//                   style: Theme.of(context).textTheme.titleLarge,
//                 ),
//                 const SizedBox(height: 12),
//                 Center(
//                   child: Column(
//                     children: [
//                       Obx(() {
//                         final selectedFile = controller.selectedLogoFile.value;
//                         if (selectedFile != null) {
//                           if (kIsWeb) {
//                             return Image.memory(
//                               // On web, read bytes for MemoryImage
//                               Uint8List.fromList(selectedFile.bytes as List<int>), // Assuming bytes are available
//                               width: 150,
//                               height: 150,
//                               fit: BoxFit.cover,
//                             );
//                           } else {
//                             // On non-web, use File.fromUri
//                             return Image.file(
//                               File.fromUri(Uri.parse(selectedFile.path)),
//                               width: 150,
//                               height: 150,
//                               fit: BoxFit.cover,
//                             );
//                           }
//                         } else if (controller.logoImageUrl.value.isNotEmpty) {
//                           // Display existing logo if available
//                           return CachedNetworkImage(
//                             imageUrl: controller.logoImageUrl.value,
//                             width: 150,
//                             height: 150,
//                             fit: BoxFit.cover,
//                             placeholder: (context, url) => const CircularProgressIndicator(),
//                             errorWidget: (context, url, error) => Icon(Icons.error, color: colorScheme.error),
//                           );
//                         }
//                         return Container(
//                           width: 150,
//                           height: 150,
//                           decoration: BoxDecoration(
//                             color: colorScheme.surfaceVariant.withOpacity(0.3),
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
//                           ),
//                           child: Icon(Icons.storefront, size: 60, color: colorScheme.onSurfaceVariant.withOpacity(0.6)),
//                         );
//                       }),
//                       const SizedBox(height: 16),
//                       ElevatedButton.icon(
//                         onPressed: controller.pickStoreLogo,
//                         icon: const Icon(Icons.upload_file),
//                         label: const Text('اختيار شعار المتجر'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: colorScheme.secondaryContainer,
//                           foregroundColor: colorScheme.onSecondaryContainer,
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//
//                 Text(
//                   'روابط التواصل الاجتماعي',
//                   style: Theme.of(context).textTheme.titleLarge,
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: controller.instagramController,
//                   decoration: _inputDecoration('رابط انستجرام', Icons.camera_alt, colorScheme),
//                   textInputAction: TextInputAction.next,
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: controller.facebookController,
//                   decoration: _inputDecoration('رابط فيسبوك', Icons.facebook, colorScheme),
//                   textInputAction: TextInputAction.next,
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: controller.whatsappController,
//                   decoration: _inputDecoration('رقم واتساب (مع رمز الدولة)', Icons.whatsapp, colorScheme),
//                   keyboardType: TextInputType.phone,
//                   textInputAction: TextInputAction.done,
//                 ),
//                 const SizedBox(height: 24),
//
//                 Text(
//                   'رسالة الإعلان',
//                   style: Theme.of(context).textTheme.titleLarge,
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: controller.announcementMessageController,
//                   decoration: _inputDecoration('نص رسالة الإعلان', Icons.announcement, colorScheme),
//                   maxLines: 2,
//                   textInputAction: TextInputAction.newline,
//                 ),
//                 SwitchListTile(
//                   title: Text(
//                     'تفعيل رسالة الإعلان',
//                     style: Theme.of(context).textTheme.titleMedium,
//                   ),
//                   value: controller.announcementActive.value,
//                   onChanged: (bool value) {
//                     controller.announcementActive.value = value;
//                   },
//                   activeColor: colorScheme.primary,
//                   inactiveThumbColor: colorScheme.outline,
//                   contentPadding: EdgeInsets.zero,
//                 ),
//                 const SizedBox(height: 32),
//
//                 // Save Button
//                 Center(
//                   child: SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       onPressed: controller.isLoading.value ? null : controller.createStore,
//                       icon: controller.isLoading.value
//                           ? SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
//                         ),
//                       )
//                           : Icon(Icons.add_business, color: colorScheme.onPrimary),
//                       label: Text(
//                         controller.isLoading.value ? 'جاري الإنشاء...' : 'إنشاء المتجر',
//                         style: TextStyle(color: colorScheme.onPrimary),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: colorScheme.primary,
//                         padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Obx(() {
//                   if (controller.error.value.isNotEmpty) {
//                     return Center(
//                       child: Text(
//                         controller.error.value,
//                         style: TextStyle(color: colorScheme.error, fontSize: 14),
//                         textAlign: TextAlign.center,
//                       ),
//                     );
//                   }
//                   return const SizedBox.shrink();
//                 }),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }