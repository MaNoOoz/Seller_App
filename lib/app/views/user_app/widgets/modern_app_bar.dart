import 'package:app/app/views/user_app/screens/controllers/cart_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../screens/controllers/home_controller.dart';

class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final HomeController controller;
  final double rating;

  const ModernAppBar({
    super.key,
    required this.controller,
    required this.rating,
  });

  @override
  Size get preferredSize => const Size.fromHeight(140);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.black26,
        surfaceTintColor: Colors.pink.shade100,
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        elevation: 10,
        foregroundColor: Colors.red,

        title: Obx(() {
          return Column(
            children: [
              Text(
                controller.storeInfo.value?.name ?? 'جاري التحميل...',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'DG Sahabah',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                controller.storeInfo.value?.description ?? '',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  fontFamily: 'DG Sahabah',
                ),
              ),
            ],
          );
        }),

        leading: Padding(
          padding: const EdgeInsets.only(right: 22),
          child: Obx(() {
            final logoUrl = controller.storeInfo.value?.logoUrl ?? '';
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: logoUrl,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                width: 60,
                height: 60,
                fit: BoxFit.contain,
              ),
            );
          }),
        ),

        actions: [
          Obx(() {
            final storeReady = controller.storeInfo.value?.name != null &&
                controller.storeInfo.value?.phone != null;

            return IconButton(
              icon: Badge(
                label: Obx(() => Text("${Get.find<CartController>().cartItems.length}")),
                child: const Icon(FontAwesomeIcons.cartPlus),
              ),
              onPressed: storeReady
                  ? () {
                Get.toNamed(
                  Routes.CART,
                  arguments: {
                    "restaurantName": controller.storeInfo.value?.name ?? '',
                    "whatsappNumber": controller.storeInfo.value?.phone ?? '',
                  },
                  // transition: Transition.fadeIn,
                  // duration: const Duration(milliseconds: 300),
                );
              }
                  : () {
                Get.snackbar(
                  'يرجى الانتظار',
                  'يتم تحميل بيانات المطعم...',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.black87,
                  colorText: Colors.white,
                );
              },
              tooltip: 'السلة',
            );
          }),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
