import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'edit_store_controller.dart';

class EditStoreScreen extends GetView<EditStoreController> {
  const EditStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل بيانات المتجر'),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      body: Obx(
            () {
          if (controller.isLoading.value && controller.nameController.text.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.error.value.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(controller.error.value, style: TextStyle(color: colorScheme.error, fontSize: 16)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => controller.fetchStoreDataByUid(), // Retry fetching
                      child: const Text('إعادة المحاولة'),
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
                // Logo Section
                Center(
                  child: GestureDetector(
                    onTap: controller.pickLogo,
                    child: Obx(() {
                      if (controller.logoFile.value != null) {
                        return FutureBuilder<Uint8List>(
                          future: controller.logoFile.value!.readAsBytes(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                              return CircleAvatar(
                                radius: 60,
                                backgroundImage: MemoryImage(snapshot.data!),
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: colorScheme.primary,
                                        child: Icon(Icons.camera_alt, color: colorScheme.onPrimary, size: 20),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return _buildLogoPlaceholder(colorScheme);
                          },
                        );
                      } else if (controller.currentLogoUrl.value.isNotEmpty) {
                        return CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(controller.currentLogoUrl.value),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.bottomRight,
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: colorScheme.primary,
                                  child: Icon(Icons.camera_alt, color: colorScheme.onPrimary, size: 20),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return _buildLogoPlaceholder(colorScheme);
                    }),
                  ),
                ),
                const SizedBox(height: 24),

                // Store Name
                TextField(
                  controller: controller.nameController,
                  decoration: InputDecoration(
                    labelText: 'اسم المتجر',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.store, color: colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 16),

                // Store Description
                TextField(
                  controller: controller.descriptionController,
                  decoration: InputDecoration(
                    labelText: 'وصف المتجر',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description, color: colorScheme.primary),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Store Phone Number
                TextField(
                  controller: controller.phoneController,
                  decoration: InputDecoration(
                    labelText: 'رقم الهاتف',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone, color: colorScheme.primary),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // City
                TextField(
                  controller: controller.cityController,
                  decoration: InputDecoration(
                    labelText: 'المدينة',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_city, color: colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 16),

                // Detailed Location
                TextField(
                  controller: controller.locationController,
                  decoration: InputDecoration(
                    labelText: 'العنوان التفصيلي',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on, color: colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Social Links Section ---
                Text(
                  'روابط التواصل الاجتماعي',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),

                // Social Platform Dropdown
                DropdownButton<String>(
                  value: controller.selectedPlatform.value.isEmpty ? null : controller.selectedPlatform.value,
                  hint: Text('اختار منصة التواصل الاجتماعي'),
                  isExpanded: true,
                  items: controller.socialPlatforms.map((String platform) {
                    return DropdownMenuItem<String>(
                      value: platform,
                      child: Text(platform),
                    );
                  }).toList(),
                  onChanged: (value) {
                    controller.selectedPlatform.value = value ?? '';
                  },
                ),
                const SizedBox(height: 12),

                // Add Social Link Button
                ElevatedButton(
                  onPressed: controller.addSocialLink,
                  child: const Text('إضافة رابط تواصل اجتماعي'),
                ),
                const SizedBox(height: 16),

                // List of Social Links
                Obx(() {
                  return Column(
                    children: controller.socialControllers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final controllers = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Text(controllers.key, style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: controllers.value,
                                decoration: InputDecoration(
                                  labelText: 'الرابط (URL)',
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                ),
                                keyboardType: TextInputType.url,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.remove_circle, color: colorScheme.error),
                              onPressed: () => controller.removeSocialLink(index),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }),

                const SizedBox(height: 32),

                // --- Management Sections ---
                _buildManagementSection(
                  context,
                  title: 'إدارة المنتجات',
                  icon: Icons.inventory_2,
                  onAdd: controller.goToAddProduct,
                  onView: controller.goToProductsList,
                  color: colorScheme.tertiaryContainer,
                  onColor: colorScheme.onTertiaryContainer,
                ),
                const SizedBox(height: 24),
                _buildManagementSection(
                  context,
                  title: 'إدارة العروض',
                  icon: Icons.local_offer,
                  onAdd: controller.goToAddOffer,
                  onView: controller.goToOffersList,
                  color: colorScheme.secondaryContainer,
                  onColor: colorScheme.onSecondaryContainer,
                ),
                const SizedBox(height: 32),

                // --- Save Button ---
                Obx(() => Center(
                  child: ElevatedButton.icon(
                    onPressed: controller.isLoading.value ? null : controller.updateStore,
                    icon: controller.isLoading.value
                        ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator())
                        : Icon(Icons.save, color: colorScheme.onPrimary),
                    label: Text(
                      controller.isLoading.value ? 'جاري الحفظ...' : 'حفظ التغييرات',
                      style: TextStyle(color: colorScheme.onPrimary),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                )),
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

  // Helper widget for logo placeholder
  Widget _buildLogoPlaceholder(ColorScheme colorScheme) {
    return CircleAvatar(
      radius: 60,
      backgroundColor: colorScheme.surfaceVariant,
      child: Icon(Icons.store, size: 60, color: colorScheme.onSurfaceVariant),
    );
  }

  // Helper widget for management sections (Products/Offers)
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
