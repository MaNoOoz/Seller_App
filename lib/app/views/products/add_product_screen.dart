import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_selector/file_selector.dart';

import 'add_product_controller.dart'; // Required for displaying selected XFile images


class AddProductScreen extends GetView<AddProductController> {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة منتج جديد'),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      body: Obx(
            () {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Product Images Section ---
                Text(
                  'صور المنتج',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton.icon(
                    onPressed: controller.pickImages,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('اختر صور المنتج'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      backgroundColor: colorScheme.secondaryContainer,
                      foregroundColor: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                      () {
                    if (controller.selectedImages.isEmpty) {
                      return Center(
                        child: Text(
                          'لم يتم اختيار أي صور',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      );
                    }
                    return SizedBox(
                      height: 120, // Height for the horizontal list of images
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.selectedImages.length,
                        itemBuilder: (context, index) {
                          final XFile imageFile = controller.selectedImages[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FutureBuilder<Uint8List>(
                              future: imageFile.readAsBytes(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                  return Image.memory(
                                    snapshot.data!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  );
                                }
                                return Container(
                                  width: 100,
                                  height: 100,
                                  color: colorScheme.surfaceVariant,
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // --- Product Details Form ---
                TextField(
                  controller: controller.nameController,
                  decoration: InputDecoration(
                    labelText: 'اسم المنتج',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.shopping_bag, color: colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.descriptionController,
                  decoration: InputDecoration(
                    labelText: 'وصف المنتج',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description, color: colorScheme.primary),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.priceController,
                  decoration: InputDecoration(
                    labelText: 'السعر',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money, color: colorScheme.primary),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.categoryController,
                  decoration: InputDecoration(
                    labelText: 'الفئة (مثال: إلكترونيات، ملابس)',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category, color: colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 32),

                // --- Add Product Button ---
                Center(
                  child: ElevatedButton.icon(
                    onPressed: controller.isLoading.value ? null : controller.addProduct,
                    icon: controller.isLoading.value
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                      ),
                    )
                        : Icon(Icons.add, color: colorScheme.onPrimary),
                    label: Text(
                      controller.isLoading.value ? 'جاري الإضافة...' : 'إضافة المنتج',
                      style: TextStyle(color: colorScheme.onPrimary),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Obx(() {
                  if (controller.error.value.isNotEmpty) {
                    return Center(
                      child: Text(
                        controller.error.value,
                        style: TextStyle(color: colorScheme.error, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}