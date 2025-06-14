// // lib/seller_app/views/create_shop/create_shop_screen.dart
//
// import 'dart:typed_data';
//
// import 'package:app/app/views/dashboard/admin_controller.dart';
// import 'package:file_selector/file_selector.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class CreateShopScreen extends StatefulWidget {
//   const CreateShopScreen({super.key});
//
//   @override
//   State<CreateShopScreen> createState() => _CreateShopScreenState();
// }
//
// class _CreateShopScreenState extends State<CreateShopScreen> {
//   final AdminController shopController = Get.find(); // Use Get.find()
//
//   final TextEditingController _nameC = TextEditingController();
//   final TextEditingController _descC = TextEditingController();
//   final TextEditingController _phoneC = TextEditingController();
//   final TextEditingController _cityC = TextEditingController();
//   final TextEditingController _locationC = TextEditingController();
//   final RxList<MapEntry<TextEditingController, TextEditingController>> _socialControllers = <MapEntry<TextEditingController, TextEditingController>>[].obs;
//
//   final Rx<XFile?> _logoFile = Rx<XFile?>(null);
//
//   @override
//   void dispose() {
//     _nameC.dispose();
//     _descC.dispose();
//     _phoneC.dispose();
//     _cityC.dispose();
//     _locationC.dispose();
//     // Dispose social media controllers
//     for (var entry in _socialControllers) {
//       entry.key.dispose();
//       entry.value.dispose();
//     }
//     _socialControllers.close(); // Dispose RxList
//     _logoFile.close(); // Dispose Rx
//     super.dispose();
//   }
//
//   Future<void> _pickLogo() async {
//     final typeGroup = XTypeGroup(label: 'images', extensions: ['png', 'jpg', 'jpeg']);
//     final result = await openFile(acceptedTypeGroups: [typeGroup]);
//     if (result != null) {
//       _logoFile.value = result;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('إنشاء متجر جديد')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               TextField(controller: _nameC, decoration: const InputDecoration(labelText: 'اسم المتجر')),
//               const SizedBox(height: 12),
//               TextField(controller: _descC, decoration: const InputDecoration(labelText: 'الوصف'), maxLines: 3),
//               const SizedBox(height: 12),
//               TextField(controller: _phoneC, decoration: const InputDecoration(labelText: 'رقم الهاتف')),
//               const SizedBox(height: 12),
//               TextField(controller: _cityC, decoration: const InputDecoration(labelText: 'المدينة')),
//               const SizedBox(height: 12),
//               TextField(controller: _locationC, decoration: const InputDecoration(labelText: 'العنوان الكامل / الموقع')),
//               const SizedBox(height: 20),
//               const Text("روابط التواصل الاجتماعي", style: TextStyle(fontWeight: FontWeight.bold)),
//               Obx(() => Column(
//                     children: _socialControllers
//                         .map((entry) => Row(
//                               children: [
//                                 Expanded(child: TextField(controller: entry.key, decoration: const InputDecoration(labelText: 'المنصة'))),
//                                 const SizedBox(width: 8),
//                                 Expanded(child: TextField(controller: entry.value, decoration: const InputDecoration(labelText: 'الرابط'))),
//                                 IconButton(
//                                   icon: const Icon(Icons.delete, color: Colors.red),
//                                   onPressed: () => _socialControllers.remove(entry),
//                                 )
//                               ],
//                             ))
//                         .toList(),
//                   )),
//               TextButton.icon(
//                 onPressed: () {
//                   _socialControllers.add(MapEntry(TextEditingController(), TextEditingController()));
//                 },
//                 icon: const Icon(Icons.add),
//                 label: const Text("إضافة وسيلة تواصل"),
//               ),
//               const SizedBox(height: 16),
//               Obx(() {
//                 final file = _logoFile.value;
//                 return file == null
//                     ? const Text('لم يتم اختيار شعار بعد')
//                     : FutureBuilder<Uint8List>(
//                         future: file.readAsBytes(),
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
//                             return Image.memory(snapshot.data!, height: 100);
//                           } else if (snapshot.hasError) {
//                             return const Text('خطأ في تحميل الصورة');
//                           } else {
//                             return const CircularProgressIndicator();
//                           }
//                         },
//                       );
//               }),
//               TextButton(onPressed: _pickLogo, child: const Text('اختيار شعار')),
//               const SizedBox(height: 24),
//               Obx(() {
//                 return shopController.isLoading.value
//                     ? const CircularProgressIndicator()
//                     : ElevatedButton(
//                         onPressed: () {
//                           if (_logoFile.value == null) {
//                             Get.snackbar('خطأ', 'يرجى اختيار شعار المتجر');
//                             return;
//                           }
//
//                           final socialMap = <String, String>{};
//                           for (var entry in _socialControllers) {
//                             final key = entry.key.text.trim();
//                             final value = entry.value.text.trim();
//                             if (key.isNotEmpty && value.isNotEmpty) {
//                               socialMap[key] = value;
//                             }
//                           }
//
//                           shopController.createShop(
//                             name: _nameC.text.trim(),
//                             description: _descC.text.trim(),
//                             phone: _phoneC.text.trim(),
//                             city: _cityC.text.trim(),
//                             location: _locationC.text.trim(),
//                             logoXFile: _logoFile.value!,
//                             socialLinks: socialMap,
//                           );
//                         },
//                         child: const Text('إنشاء المتجر'),
//                       );
//               }),
//               Obx(() {
//                 return shopController.error.value.isNotEmpty ? Text(shopController.error.value, style: const TextStyle(color: Colors.red)) : const SizedBox.shrink();
//               }),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
