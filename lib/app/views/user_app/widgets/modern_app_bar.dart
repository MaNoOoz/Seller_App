import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  Size get preferredSize => const Size.fromHeight(140); // Total height including background

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AppBar(
        toolbarHeight: 80,
        // Height of the actual app bar content
        backgroundColor: Colors.black26,
        surfaceTintColor: Colors.pink.shade100,
        shape: BeveledRectangleBorder(borderRadius: BorderRadiusGeometry.all(Radius.circular(22))),
        actionsIconTheme: IconThemeData(color: Colors.white),

        // primary: true,
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
              Obx(() {
                return Text(
                  controller.storeInfo.value?.description ?? 'جاري التحميل...',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        fontFamily: 'DG Sahabah',
                      ),
                );
              }),
            ],
          );
        }),

        leading: Padding(
          padding: const EdgeInsets.only(right: 22),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: controller.storeInfo.value?.logoUrl ?? '',
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: Badge(
              label: const Text('3'),
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
