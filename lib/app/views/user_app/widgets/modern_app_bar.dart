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
      padding: const EdgeInsets.all(0.0),
      child: SafeArea(
        child: AppBar(
          toolbarHeight: 80,
          backgroundColor: Colors.white,
          // surfaceTintColor: Colors.pink.shade100,
          // shape: BeveledRectangleBorder(
          //   borderRadius: BorderRadius.circular(22),
          // ),
          elevation: 10,
          // foregroundColor: Colors.red,

          title: Obx(() {
            return Column(
              children: [

                const SizedBox(height: 12),
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
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
