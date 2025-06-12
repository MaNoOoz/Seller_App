// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../controllers/auth_controller.dart';
// import '../../routes/app_pages.dart';
//
// class RegisterScreen extends StatelessWidget {
//   final AuthController authController = Get.find();
//
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPasswordController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('إنشاء حساب')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           shrinkWrap: true,
//           children: [
//             TextField(
//               controller: emailController,
//               decoration: InputDecoration(labelText: 'البريد الإلكتروني'),
//             ),
//             SizedBox(height: 12),
//             TextField(
//               controller: passwordController,
//               obscureText: true,
//               decoration: InputDecoration(labelText: 'كلمة المرور'),
//             ),
//             SizedBox(height: 12),
//             TextField(
//               controller: confirmPasswordController,
//               obscureText: true,
//               decoration: InputDecoration(labelText: 'تأكيد كلمة المرور'),
//             ),
//             SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () {
//                 if (passwordController.text == confirmPasswordController.text) {
//                   authController.register(
//                     emailController.text.trim(),
//                     passwordController.text.trim(),
//                   );
//                 } else {
//                   Get.snackbar('خطأ', 'كلمتا المرور غير متطابقتين');
//                 }
//               },
//               child: Text('تسجيل'),
//             ),
//             SizedBox(height: 24),
//             SizedBox(height: 24),
//
//             TextButton(
//               onPressed: () {
//                 Get.toNamed(Routes.LOGIN);
//               },
//               child: Text(' لديك حساب؟  إدخل'),
//             ),
//             Obx(() {
//               if (authController.isLoading.value) {
//                 return Center(child: CircularProgressIndicator());
//               }
//               return Container();
//             }),
//             Obx(() {
//               if (authController.error.value.isNotEmpty) {
//                 return Text(authController.error.value, style: TextStyle(color: Colors.red));
//               }
//               return Container();
//             }),
//           ],
//         ),
//       ),
//     );
//   }
// }
