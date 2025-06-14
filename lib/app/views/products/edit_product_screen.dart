// lib/seller_app/views/products/edit_product_screen.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_selector/file_selector.dart'; // Required for displaying selected XFile images
import 'dart:typed_data';

import 'edit_product_controller.dart'; // Required for Uint8List


class EditProductScreen extends GetView<EditProductController> {
  const EditProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل المنتج'),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      body: Obx(
            () {
          if (controller.isLoading.value && controller.existingImageUrls.isEmpty && controller.selectedImages.isEmpty) {
            // Only show full screen loading if no images are loaded yet
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
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('إضافة صور جديدة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Display existing and newly selected images
                Obx(
                      () {
                    final allImages = [...controller.existingImageUrls, ...controller.selectedImages];
                    if (allImages.isEmpty) {
                      return Center(
                        child: Text(
                          'لا توجد صور للمنتج حتى الآن.',
                          style: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
                        ),
                      );
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: allImages.length,
                      itemBuilder: (context, index) {
                        final dynamic image = allImages[index]; // Can be String (URL) or XFile
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _buildImageWidget(image),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  if (image is String) {
                                    controller.removeExistingImage(image);
                                  } else if (image is XFile) {
                                    controller.removeSelectedImage(image);
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),

                // --- Product Details Form ---
                TextFormField(
                  controller: controller.nameController,
                  decoration: InputDecoration(
                    labelText: 'اسم المنتج',
                    hintText: 'مثال: هاتف ذكي',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.shopping_bag_outlined),
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.descriptionController,
                  decoration: InputDecoration(
                    labelText: 'وصف المنتج',
                    hintText: 'وصف تفصيلي للمنتج...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.description_outlined),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.priceController,
                  decoration: InputDecoration(
                    labelText: 'السعر (ر.س)',
                    hintText: 'مثال: 99.99',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.categoryController, // New category field
                  decoration: InputDecoration(
                    labelText: 'فئة المنتج',
                    hintText: 'مثال: إلكترونيات، ملابس، طعام',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.category_outlined),
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'متوفر:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: 8),
                    Obx(() => Switch(
                      value: controller.isAvailable.value,
                      onChanged: (bool value) {
                        controller.isAvailable.value = value;
                      },
                      activeColor: colorScheme.primary,
                    )),
                  ],
                ),
                const SizedBox(height: 24),

                // --- Update Product Button ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.isLoading.value ? null : controller.updateProduct,
                    icon: controller.isLoading.value
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                      ),
                    )
                        : Icon(Icons.save, color: colorScheme.onPrimary),
                    label: Text(
                      controller.isLoading.value ? 'جاري التحديث...' : 'تحديث المنتج',
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

  // Helper function to build image widgets based on type (String for URL, XFile for local)
  Widget _buildImageWidget(dynamic image) {
    if (image is String) {
      // Existing image (URL)
      return Image.network(
        image,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    } else if (image is XFile) {
      // Newly selected image (XFile): Use FutureBuilder to load bytes
      return FutureBuilder<Uint8List>(
        future: image.readAsBytes(), // Read bytes from XFile
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            );
          } else if (snapshot.hasError) {
            return Container(
              color: Colors.grey[200],
              child: const Icon(Icons.error, color: Colors.red),
            );
          }
          return Container(
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
      );
    }
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }
}