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

                // Contact Email (New Field)
                TextField(
                  controller: controller.contactEmailController,
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني للتواصل',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email, color: colorScheme.primary),
                  ),
                  keyboardType: TextInputType.emailAddress,
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

                // --- Working Hours Section (New) ---
                Text(
                  'ساعات العمل',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 24),

                // --- Delivery Options Section (New) ---
                Text(
                  'خيارات التوصيل',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                _buildListEditor(
                  context,
                  controller.deliveryOptions,
                      (option) => controller.addDeliveryOption(option),
                      (option) => controller.removeDeliveryOption(option),
                  'إضافة خيار توصيل',
                  'خيار التوصيل',
                ),
                const SizedBox(height: 24),

                // --- Payment Methods Section (New) ---
                Text(
                  'طرق الدفع',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                _buildListEditor(
                  context,
                  controller.paymentMethods,
                      (method) => controller.addPaymentMethod(method),
                      (method) => controller.removePaymentMethod(method),
                  'إضافة طريقة دفع',
                  'طريقة الدفع',
                ),
                const SizedBox(height: 24),

                // --- Announcement Section (New) ---
                Text(
                  'رسالة الإعلان',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller.announcementMessageController,
                  decoration: InputDecoration(
                    labelText: 'رسالة الإعلان',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.campaign, color: colorScheme.primary),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'تفعيل رسالة الإعلان',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Obx(() => Switch(
                      value: controller.announcementActive.value,
                      onChanged: (bool value) {
                        controller.announcementActive.value = value;
                      },
                    )),
                  ],
                ),
                const SizedBox(height: 24),



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
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
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

  // Helper widget for Working Hours (New)

  // Helper widget for lists like Delivery Options and Payment Methods (New)
  Widget _buildListEditor(
      BuildContext context,
      RxList<String> list,
      Function(String) onAdd,
      Function(String) onRemove,
      String addButtonText,
      String textFieldLabel,
      ) {
    TextEditingController newOptionController = TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: newOptionController,
                decoration: InputDecoration(
                  labelText: textFieldLabel,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (value) {
                  onAdd(value);
                  newOptionController.clear();
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (newOptionController.text.isNotEmpty) {
                  onAdd(newOptionController.text);
                  newOptionController.clear();
                }
              },
              child: Text(addButtonText),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (list.isEmpty) {
            return Text('لا يوجد ${textFieldLabel.toLowerCase()}s حاليًا.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant));
          }
          return Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: list.map((item) {
              return Chip(
                label: Text(item),
                onDeleted: () => onRemove(item),
                deleteIcon: Icon(Icons.cancel),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                labelStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                deleteIconColor: Theme.of(context).colorScheme.onPrimaryContainer,
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}