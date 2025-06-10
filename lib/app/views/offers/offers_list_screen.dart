import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // For date formatting


import '../../routes/app_pages.dart';
import '../../utils/constants.dart';
import 'offers_list_controller.dart'; // For AppConstants

class OffersListScreen extends GetView<OffersListController> {
  const OffersListScreen({super.key});

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    return DateFormat('yyyy-MM-dd').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة العروض'),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_card), // Icon for adding offers
            onPressed: () {
              // Navigate to AddOfferScreen, passing the storeId
              final String? storeId = Get.arguments != null && Get.arguments is Map ? Get.arguments['storeId'] as String? : null;
              if (storeId != null) {
                Get.toNamed(Routes.ADD_OFFER, arguments: {'storeId': storeId});
              } else {
                Get.snackbar('خطأ', 'معرف المتجر غير متوفر لإضافة عرض جديد.');
              }
            },
          ),
        ],
      ),
      body: Obx(
            () {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

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

          if (controller.offers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_offer_outlined, size: 80, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد عروض حتى الآن.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اضغط على زر الإضافة لإنشاء عرض جديد.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: controller.offers.length,
            itemBuilder: (context, index) {
              final offer = controller.offers[index];
              final String offerId = offer['id']; // Document ID
              final String title = offer[AppConstants.offerTitleField] ?? 'لا يوجد عنوان';
              final String description = offer[AppConstants.offerDescriptionField] ?? 'لا يوجد وصف';
              final String type = offer[AppConstants.offerTypeField] ?? 'percentage';
              final double value = (offer[AppConstants.offerValueField] ?? 0.0).toDouble();
              final String bannerImageUrl = offer[AppConstants.offerBannerImageUrlField] ?? 'https://via.placeholder.com/400x200'; // Default image

              final bool isActive = controller.isOfferActive(offer);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Offer Banner Image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        bannerImageUrl,
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: double.infinity,
                          height: 150,
                          color: colorScheme.surfaceVariant,
                          child: Icon(Icons.broken_image, color: colorScheme.onSurfaceVariant, size: 50),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.green.shade100 : Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isActive ? 'نشط' : 'غير نشط',
                                  style: TextStyle(
                                    color: isActive ? Colors.green.shade800 : Colors.red.shade800,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'الخصم: ${value.toStringAsFixed(type == 'percentage' ? 0 : 2)}${type == 'percentage' ? '%' : '\$' + (type == 'amount' ? '' : '')}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.date_range, size: 16, color: colorScheme.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(
                                'يبدأ: ${_formatDate(offer[AppConstants.offerStartDateField])}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(width: 16),
                              Icon(Icons.date_range, size: 16, color: colorScheme.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(
                                'ينتهي: ${_formatDate(offer[AppConstants.offerEndDateField])}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: colorScheme.secondary),
                                onPressed: () => controller.goToEditOffer(offerId),
                                tooltip: 'تعديل العرض',
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: colorScheme.error),
                                onPressed: () => Get.defaultDialog(
                                  title: 'تأكيد الحذف',
                                  middleText: 'هل أنت متأكد أنك تريد حذف هذا العرض؟',
                                  textConfirm: 'حذف',
                                  textCancel: 'إلغاء',
                                  confirmTextColor: Colors.white,
                                  buttonColor: colorScheme.error,
                                  onConfirm: () {
                                    Get.back(); // Dismiss dialog
                                    controller.deleteOffer(offerId);
                                  },
                                ),
                                tooltip: 'حذف العرض',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}