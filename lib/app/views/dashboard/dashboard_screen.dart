import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart'; // For loading images

import '../../controllers/auth_controller.dart';
import '../../routes/app_pages.dart';
import '../../utils/theme_service.dart';
import 'dashboard_controller.dart'; // Import routes

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure the controller is put (or find if already put by binding)
    // This is typically handled by GetPage binding in app_pages.dart
    // If you explicitly remove it from app_pages.dart binding, then Get.put(DashboardController()); would be needed here.
    // For consistency and best practice with GetX, prefer bindings.
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          controller.shopName.value.isEmpty ? 'لوحة التحكم' : controller.shopName.value,
        )),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        leading:   IconButton(
          icon: const Icon(Icons.exit_to_app, ),
          tooltip: 'تسجيل الخروج',

          onPressed: () {
            // Assuming you have an AuthController for logout
            Get.find<AuthController>().logout();
            Get.snackbar('تسجيل الخروج', '');
          },
        ),
        actions: [

          // Inside DashboardScreen's AppBar actions:
          IconButton(
            icon: Icon(Icons.brightness_6, color: colorScheme.onPrimaryContainer), // A sun/moon icon
            onPressed: () {
              Get.find<ThemeService>().switchTheme(); // Call the theme switcher
            },
            tooltip: 'تبديل الوضع الليلي/النهاري',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'تعديل',

            onPressed: () {
              controller.goToEditStore();
            },
          ),
          SizedBox(width: 22,),

        ],
      ),
      body: Obx(
            () {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.shopDocId == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.store_mall_directory_outlined, size: 80, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(
                      'لم يتم العثور على متجر.',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'الرجاء إنشاء متجر جديد للبدء بإدارة أعمالك.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Assuming NO_ACCESS navigates to create shop screen or handles redirection
                        Get.offAllNamed(Routes.NO_ACCESS);
                      },
                      icon: const Icon(Icons.add_business),
                      label: const Text('إنشاء متجر جديد'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Store Info Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: controller.logoUrl.value.isNotEmpty
                              ? CachedNetworkImage(
                            imageUrl: controller.logoUrl.value,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Icon(Icons.store, size: 80, color: colorScheme.onSurfaceVariant),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                              : Icon(Icons.store, size: 100, color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.shopName.value,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                controller.description.value.isNotEmpty ? controller.description.value : 'لا يوجد وصف للمتجر.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.phone, size: 16, color: colorScheme.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Text(
                                    controller.phoneNumber.value.isNotEmpty ? controller.phoneNumber.value : 'لا يوجد رقم هاتف.',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Products Summary Card
                Text('ملخص المنتجات', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'إجمالي المنتجات:',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Obx(() => Text(
                              '${controller.totalProductsCount.value}',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                            )),
                          ],
                        ),
                      ),
                      const Divider(height: 24),
                      _buildManagementSection(
                        context,
                        title: 'إدارة المنتجات',
                        icon: Icons.inventory_2,
                        onAdd: controller.goToAddProduct,
                        onView: controller.goToProductsList,
                        color: colorScheme.tertiaryContainer,
                        onColor: colorScheme.onTertiaryContainer,
                      ),                      ],
                  ),
                ),
                const SizedBox(height: 24),

                // Offers Summary Card
                Text('ملخص العروض', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'إجمالي العروض:',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Obx(() => Text(
                              '${controller.totalOffersCount.value}',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildManagementSection(
                        context,
                        title: 'إدارة العروض',
                        icon: Icons.local_offer,
                        onAdd: controller.goToAddOffer,
                        onView: controller.goToOffersList,
                        color: colorScheme.secondaryContainer,
                        onColor: colorScheme.onSecondaryContainer,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Add more sections as needed (e.g., Recent Orders, Analytics)
              ],
            ),
          );
        },
      ),
    );
  }
  Widget _buildManagementSection(
      BuildContext context, {
        required String title,
        required IconData icon,
        required VoidCallback onAdd,
        required VoidCallback onView,
        required Color color,
        required Color onColor,
      }) {
    return Card(
      color: color,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28, color: onColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: onColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onAdd,
                    icon: Icon(Icons.add_circle, color: color),
                    label: Text('إضافة جديد', style: TextStyle(color: color)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: onColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onView,
                    icon: Icon(Icons.list, color: color),
                    label: Text('عرض الكل', style: TextStyle(color: color)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: onColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}