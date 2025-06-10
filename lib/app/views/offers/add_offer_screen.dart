import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io'; // For File.fromUri in non-web
import 'package:flutter/foundation.dart' show kIsWeb; // For web detection

import '../../utils/constants.dart';
import 'add_offer_controller.dart'; // Ensure constants are imported

class AddOfferScreen extends GetView<AddOfferController> {
  const AddOfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة عرض جديد'),
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
                // --- Banner Image Selection ---
                GestureDetector(
                  onTap: controller.pickBannerImage,
                  child: Obx(
                        () => Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.outline),
                      ),
                      child: controller.bannerFile.value != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: kIsWeb
                            ? Image.network(
                          controller.bannerFile.value!.path,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.broken_image, color: colorScheme.onSurfaceVariant),
                        )
                            : Image.file(
                          File(controller.bannerFile.value!.path),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.broken_image, color: colorScheme.onSurfaceVariant),
                        ),
                      )
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 40, color: colorScheme.onSurfaceVariant),
                          const SizedBox(height: 8),
                          Text(
                            'اضغط لاختيار صورة بانر',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: controller.titleController,
                  decoration: InputDecoration(
                    labelText: 'عنوان العرض (مثال: خصم الصيف الكبير)',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label, color: colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.descriptionController,
                  decoration: InputDecoration(
                    labelText: 'وصف العرض (اختياري)',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description, color: colorScheme.primary),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                // --- Offer Type Selector ---
                Text('نوع العرض:', style: Theme.of(context).textTheme.titleSmall),
                Obx(() => Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('نسبة مئوية (%)'),
                        value: 'percentage',
                        groupValue: controller.selectedOfferType.value,
                        onChanged: (String? value) {
                          if (value != null) controller.selectedOfferType.value = value;
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('قيمة ثابتة'),
                        value: 'amount',
                        groupValue: controller.selectedOfferType.value,
                        onChanged: (String? value) {
                          if (value != null) controller.selectedOfferType.value = value;
                        },
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.valueController,
                  decoration: InputDecoration(
                    labelText: controller.selectedOfferType.value == 'percentage'
                        ? 'قيمة النسبة المئوية (مثال: 10 لـ 10%)'
                        : 'قيمة المبلغ (مثال: 5.00)',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(
                        controller.selectedOfferType.value == 'percentage' ? Icons.percent : Icons.attach_money,
                        color: colorScheme.primary),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                // --- Start Date Picker ---
                TextField(
                  controller: controller.startDateController,
                  readOnly: true,
                  onTap: () => controller.pickStartDate(context),
                  decoration: InputDecoration(
                    labelText: 'تاريخ البدء',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today, color: colorScheme.primary),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                ),
                const SizedBox(height: 16),
                // --- End Date Picker ---
                TextField(
                  controller: controller.endDateController,
                  readOnly: true,
                  onTap: () => controller.pickEndDate(context),
                  decoration: InputDecoration(
                    labelText: 'تاريخ الانتهاء',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today, color: colorScheme.primary),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                ),
                const SizedBox(height: 32),

                // --- Add Offer Button ---
                Center(
                  child: ElevatedButton.icon(
                    onPressed: controller.isLoading.value ? null : controller.addOffer,
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
                      controller.isLoading.value ? 'جاري الإضافة...' : 'إضافة العرض',
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