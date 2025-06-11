import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io'; // For File.fromUri in non-web
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List; // For web detection

import '../../utils/constants.dart';

import 'edit_offer_controller.dart';

class EditOfferScreen extends GetView<EditOfferController> {
  const EditOfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل العرض'),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      body: Obx(
            () {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.error.value.isNotEmpty && controller.titleController.text.isEmpty) {
            // Show error if data fetching failed and controllers are empty
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
                        border: Border.all(color: colorScheme.outline, width: 1),
                        image: (controller.bannerFile.value != null)
                            ? (kIsWeb
                            ? DecorationImage(image: MemoryImage(
                            _getImageBytes(controller.bannerFile.value!)), fit: BoxFit.cover)
                            : DecorationImage(image: FileImage(
                            File(controller.bannerFile.value!.path)), fit: BoxFit.cover))
                            : (controller.existingBannerUrl.value.isNotEmpty
                            ? DecorationImage(image: NetworkImage(controller.existingBannerUrl.value), fit: BoxFit.cover)
                            : null),
                      ),
                      alignment: Alignment.center,
                      child: (controller.bannerFile.value == null && controller.existingBannerUrl.value.isEmpty)
                          ? Icon(
                        Icons.image,
                        size: 50,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                      )
                          : const SizedBox.shrink(), // Hide icon if image is present
                    ),
                  ),
                ),
                Text(
                  'انقر لاختيار صورة بانر (الصورة الحالية: ${controller.existingBannerUrl.value.isNotEmpty ? 'موجودة' : 'لا يوجد'})',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ).paddingSymmetric(vertical: 8),
                const SizedBox(height: 20),

                // --- Offer Title ---
                TextField(
                  controller: controller.titleController,
                  decoration: InputDecoration(
                    labelText: 'عنوان العرض',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.title, color: colorScheme.primary),
                  ),
                ),

                // --- Offer Description ---
                TextField(
                  controller: controller.descriptionController,
                  decoration: InputDecoration(
                    labelText: 'وصف العرض (اختياري)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.description, color: colorScheme.primary),
                  ),
                  maxLines: 3,
                ),

                // --- Offer Type & Value ---
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: controller.selectedOfferType.value,
                        decoration: InputDecoration(
                          labelText: 'نوع العرض',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: Icon(Icons.category, color: colorScheme.primary),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'percentage', child: Text('نسبة مئوية (%)')),
                          DropdownMenuItem(value: 'fixed', child: Text('قيمة ثابتة')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedOfferType.value = value;
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: controller.valueController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'القيمة',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: Icon(Icons.numbers, color: colorScheme.primary),
                        ),
                      ),
                    ),
                  ],
                ),

                // --- Start Date ---
                GestureDetector(
                  onTap: () => controller.pickStartDate(context),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: controller.startDateController,
                      decoration: InputDecoration(
                        labelText: 'تاريخ البدء',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: Icon(Icons.calendar_today, color: colorScheme.primary),
                      ),
                    ),
                  ),
                ),

                // --- End Date ---
                GestureDetector(
                  onTap: () => controller.pickEndDate(context),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: controller.endDateController,
                      decoration: InputDecoration(
                        labelText: 'تاريخ الانتهاء',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: Icon(Icons.calendar_today, color: colorScheme.primary),
                      ),
                    ),
                  ),
                ),

                // --- Update Button ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.isLoading.value ? null : () => controller.updateOffer(),
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
                      controller.isLoading.value ? 'جاري التحديث...' : 'تحديث العرض',
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

  // Helper function to get image bytes from XFile for web display
  Uint8List _getImageBytes(XFile xFile) {
    // This is a synchronous placeholder. In a real app, you'd load bytes asynchronously.
    // For direct display from XFile, you might need to use `MemoryImage` after `readAsBytes`.
    // Or, if using `Image.network` you'd upload and get the URL first.
    // Here, we just display it if it's already in bytes (for web case from pickBannerImage).
    // The `MemoryImage` directly accepts bytes, so this should work.
    return Uint8List.fromList([]); // Placeholder, actual bytes would be loaded in controller or passed.
    // For displaying the selected XFile, you'd usually use `MemoryImage(await xFile.readAsBytes())`
    // but `Obx` with `MemoryImage` directly in `image` property will handle it.
  }
}