import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get.dart';

import '../../routes/app_pages.dart';
import '../../routes/app_pages.dart';
import '../../utils/constants.dart'; // For routes
import '../../utils/constants.dart';
import 'products_list_controller.dart'; // For routes

class ProductsListScreen extends GetView<ProductsListController> {
  const ProductsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة المنتجات'),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            onPressed: () {
              // Navigate to AddProductScreen, passing the storeId
              final String? storeId = Get.arguments != null && Get.arguments is Map ? Get.arguments['storeId'] as String? : null;
              if (storeId != null) {
                Get.toNamed(Routes.ADD_PRODUCT, arguments: {'storeId': storeId});
              } else {
                Get.snackbar('خطأ', 'معرف المتجر غير متوفر لإضافة منتج جديد.');
              }
            },
          ),
        ],
      ),
      body: Obx(
            () {
          // Show loading indicator if still loading
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error message if there is an error
          if (controller.error.value.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  controller.error.value,
                  style: TextStyle(color: colorScheme.error, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // Show empty products message if no products are found
          if (controller.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.widgets_outlined, size: 80, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد منتجات حتى الآن.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اضغط على زر الإضافة لإنشاء منتج جديد.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Render the products list
          return ListView.builder(
            itemCount: controller.products.length,
            itemBuilder: (context, index) {
              final product = controller.products[index];
              final String productId = product['productId'] ?? ''; // Safely handle missing ID
              final String name = product[AppConstants.nameField] ?? 'لا يوجد اسم';
              final String description = product[AppConstants.descriptionField] ?? 'لا يوجد وصف';
              final double price = (product[AppConstants.priceField] ?? 0.0).toDouble();
              final String category = product[AppConstants.categoryField] ?? 'غير مصنف';
              final List<dynamic> images = product[AppConstants.imagesField] ?? [];
              final String imageUrl = images.isNotEmpty ? images[0] : 'https://via.placeholder.com/150'; // Fallback image

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display image with fallback
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 90,
                            height: 90,
                            color: colorScheme.surfaceVariant,
                            child: Icon(Icons.broken_image, color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name of the product with ellipsis for overflow
                            Text(
                              name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            // Category info
                            Text(
                              'الفئة: $category',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 4),
                            // Price info with formatted currency style
                            Text(
                              'السعر: \$${price.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Description with ellipsis for overflow
                            Text(
                              description,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          // Edit button for the product
                          IconButton(
                            icon: Icon(Icons.edit, color: colorScheme.secondary),
                            onPressed: () => controller.goToEditProduct(productId),
                            tooltip: 'تعديل المنتج',
                          ),
                          // Delete button with confirmation dialog
                          IconButton(
                            icon: Icon(Icons.delete, color: colorScheme.error),
                            onPressed: () => Get.defaultDialog(
                              title: 'تأكيد الحذف',
                              middleText: 'هل أنت متأكد أنك تريد حذف هذا المنتج؟',
                              textConfirm: 'حذف',
                              textCancel: 'إلغاء',
                              confirmTextColor: Colors.white,
                              buttonColor: colorScheme.error,
                              onConfirm: () {
                                Get.back(); // Dismiss dialog
                                controller.deleteProduct(productId);
                              },
                            ),
                            tooltip: 'حذف المنتج',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
