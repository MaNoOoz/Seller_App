import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io'; // For File.fromUri in non-web
import 'package:flutter/foundation.dart' show kIsWeb; // For web detection

import '../../utils/constants.dart';
import 'add_offer_controller.dart'; // Ensure constants are imported

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart'; // For displaying network image if needed
import 'package:flutter/foundation.dart' show kIsWeb; // For web detection
import 'dart:io'; // For File.fromUri in non-web

import '../../utils/constants.dart';
import 'add_offer_controller.dart';

class AddOfferScreen extends GetView<AddOfferController> {
  const AddOfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Helper for consistent input decoration
    InputDecoration _inputDecoration(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        hintText: 'أدخل $label',
        prefixIcon: Icon(icon, color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.1),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة عرض جديد'),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      body: Obx(
            () {
          if (controller.isLoading.value && controller.error.value.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Banner Image Selection ---
                Text(
                  'صورة البانر للعرض:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: controller.pickBannerImage,
                  child: Obx(
                        () => Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: colorScheme.outline.withOpacity(0.5), width: 1.5),
                      ),
                      child: controller.bannerFile.value != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: kIsWeb
                            ? Image.network(
                          controller.bannerFile.value!.path,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Center(child: Icon(Icons.error, size: 40, color: colorScheme.error)),
                        )
                            : Image.file(
                          File(controller.bannerFile.value!.path),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Center(child: Icon(Icons.error, size: 40, color: colorScheme.error)),
                        ),
                      )
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 50, color: colorScheme.onSurfaceVariant),
                          const SizedBox(height: 8),
                          Text(
                            'انقر لاختيار صورة البانر',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Offer Details Form ---
                TextFormField(
                  controller: controller.titleController,
                  decoration: _inputDecoration('عنوان العرض', Icons.title),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.descriptionController,
                  decoration: _inputDecoration('وصف العرض', Icons.description),
                  maxLines: 3,
                  minLines: 1,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: controller.selectedOfferType.value,
                  decoration: _inputDecoration('نوع العرض', Icons.category),
                  items: AppConstants.offerTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type == 'percentage' ? 'نسبة مئوية (%)' : 'قيمة ثابتة'),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      controller.selectedOfferType.value = newValue;
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.valueController,
                  decoration: _inputDecoration(
                      controller.selectedOfferType.value == 'percentage' ? 'قيمة النسبة المئوية (مثل 15)' : 'قيمة ثابتة (مثل 50)',
                      Icons.percent),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => controller.pickStartDate(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: controller.startDateController,
                      decoration: _inputDecoration('تاريخ البدء', Icons.calendar_today),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => controller.pickEndDate(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: controller.endDateController,
                      decoration: _inputDecoration('تاريخ الانتهاء', Icons.calendar_month),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Add Offer Button ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.isLoading.value ? null : controller.addOffer,
                    icon: controller.isLoading.value
                        ? SizedBox(
                      width: 24,
                      height: 24,
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

                // --- Error Display ---
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