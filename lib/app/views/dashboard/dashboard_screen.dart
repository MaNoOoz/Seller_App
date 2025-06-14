import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart'; // For platform-based scaling
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../routes/app_pages.dart';
import '../../utils/theme_service.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  // Map to translate English status values to Arabic for display
  static const Map<String, String> statusDisplayNames = {
    'active': 'نشط',
    'inactive': 'غير نشط',
    'pending': 'معلق',
    'closed': 'مغلق',
  };

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          controller.shopName.value.isEmpty ? 'لوحة التحكم' : controller.shopName.value,
          style: TextStyle(
            fontSize: kIsWeb || GetPlatform.isMobile ? 22 : 24, // Scale font size based on platform
          ),
        )),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        leading: IconButton(
          icon: Icon(Icons.brightness_6, color: colorScheme.onPrimaryContainer),
          onPressed: () {
            Get.find<ThemeService>().switchTheme();
          },
          tooltip: 'تبديل الوضع الليلي/النهاري',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            color: colorScheme.onPrimaryContainer,
            onPressed: () {
              if (controller.shopDocId != null) {
                controller.goToEditStore(controller.shopDocId!);
              } else {
                Get.snackbar('خطأ', 'معرف المتجر غير متوفر للتعديل.');
              }
            },
            tooltip: 'تعديل بيانات المتجر',
          ),
          // TODO: Add refresh button if needed
        ],
      ),
      body: Obx(() { // This top-level Obx is primarily for isLoading and initial shop status
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.shopName.value.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.store_mall_directory, size: 80, color: colorScheme.primary),
                const SizedBox(height: 20),
                Text(
                  'لا يوجد متجر مرتبط بحسابك حتى الآن.',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    // Get.toNamed(Routes.CREATE_STORE); // Assuming you have a route for creating a store
                  },
                  icon: const Icon(Icons.add_business),
                  label: const Text('إنشاء متجر جديد'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          );
        } else {
          // If shop data is loaded, display the dashboard content
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStoreHeader(context, colorScheme),
                const SizedBox(height: 24),

                _buildCountsSection(context, colorScheme),
                const SizedBox(height: 24),

                _buildManagementButtons(context, colorScheme),
                const SizedBox(height: 24),

                Obx(() => // Wrap the announcement card block with Obx for reactivity
                controller.announcementActive.value && controller.announcementMessage.value.isNotEmpty
                    ? _buildAnnouncementCard(context, colorScheme)
                    : const SizedBox.shrink()
                ),
                Obx(() => // Conditionally add SizedBox if announcement card is visible
                controller.announcementActive.value && controller.announcementMessage.value.isNotEmpty
                    ? const SizedBox(height: 24)
                    : const SizedBox.shrink()
                ),

                _buildAdditionalInfoSection(context), // Inner Obx handled inside this function
                const SizedBox(height: 24),
              ],
            ),
          );
        }
      }),
    );
  }

  // --- Helper Widgets ---

  Widget _buildStoreHeader(BuildContext context, ColorScheme colorScheme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store Logo
            Obx(() => CircleAvatar( // Only this part reacts to logoUrl changes
              radius: 40,
              backgroundColor: colorScheme.surfaceVariant,
              backgroundImage: controller.logoUrl.value.isNotEmpty
                  ? CachedNetworkImageProvider(controller.logoUrl.value)
                  : null,
              child: controller.logoUrl.value.isEmpty
                  ? Icon(Icons.store, size: 40, color: colorScheme.onSurfaceVariant)
                  : null,
            )),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text( // Only this part reacts to shopName changes
                    controller.shopName.value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )),
                  const SizedBox(height: 4),
                  Obx(() => Text( // Only this part reacts to description changes
                    controller.description.value,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  )),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: [
                      Obx(() => // Only this part reacts to phoneNumber changes
                      controller.phoneNumber.value.isNotEmpty
                          ? ActionChip(
                        avatar: Icon(Icons.phone, color: colorScheme.onSecondaryContainer),
                        label: Text(controller.phoneNumber.value),
                        labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
                        backgroundColor: colorScheme.secondaryContainer,
                        onPressed: () {
                          // Format the phone number for WhatsApp
                          final formattedNumber = controller.formatPhoneNumberForWhatsApp(controller.phoneNumber.value);
                          // Construct the WhatsApp URL
                          final whatsappUrl = 'https://wa.me/$formattedNumber';

                          _launchUrl(whatsappUrl);
                        },
                      )
                          : const SizedBox.shrink()
                      ),
                      Obx(() => // Only this part reacts to contactEmail changes
                      controller.contactEmail.value.isNotEmpty
                          ? ActionChip(
                        avatar: Icon(Icons.email, color: colorScheme.onSecondaryContainer),
                        label: Text(controller.contactEmail.value),
                        labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
                        backgroundColor: colorScheme.secondaryContainer,
                        onPressed: () => _launchUrl('mailto:${controller.contactEmail.value}'),
                      )
                          : const SizedBox.shrink()
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(() => _buildSocialMediaLinks(colorScheme)), // Only this part reacts to socialLinks changes
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMediaLinks(ColorScheme colorScheme) {
    if (controller.socialLinks.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: controller.socialLinks.entries.map((entry) {
        IconData iconData = Icons.link; // Default icon
        if (entry.key.toLowerCase().contains('facebook')) {
          iconData = FontAwesomeIcons.facebook;
        } else if (entry.key.toLowerCase().contains('twitter')) {
          iconData = FontAwesomeIcons.twitter;
        } else if (entry.key.toLowerCase().contains('instagram')) {
          iconData = FontAwesomeIcons.instagram;
        } else if (entry.key.toLowerCase().contains('linkedin')) {
          iconData = FontAwesomeIcons.linkedin;
        } else if (entry.key.toLowerCase().contains('whatsapp')) {
          iconData = FontAwesomeIcons.whatsapp;
        } else if (entry.key.toLowerCase().contains('youtube')) {
          iconData = FontAwesomeIcons.youtube;
        } else if (entry.key.toLowerCase().contains('tiktok')) {
          iconData = FontAwesomeIcons.tiktok;
        } else if (entry.key.toLowerCase().contains('snapchat')) {
          iconData = FontAwesomeIcons.snapchatGhost;
        } else if (entry.key.toLowerCase().contains('pinterest')) {
          iconData = FontAwesomeIcons.pinterest;
        } else if (entry.key.toLowerCase().contains('reddit')) {
          iconData = FontAwesomeIcons.reddit;
        } else if (entry.key.toLowerCase().contains('telegram')) {
          iconData = FontAwesomeIcons.telegram;
        } else if (entry.key.toLowerCase().contains('discord')) {
          iconData = FontAwesomeIcons.discord;
        } else if (entry.key.toLowerCase().contains('github')) {
          iconData = FontAwesomeIcons.github;
        }

        return IconButton(
          icon: FaIcon(iconData, color: colorScheme.primary),
          onPressed: () => _launchUrl(entry.value),
          tooltip: entry.key,
        );
      }).toList(),
    );
  }

  Widget _buildCountsSection(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: _buildCountCard(
            context,
            'إجمالي المنتجات',
            controller.totalProductsCount, // Pass RxInt
            Icons.category,
            colorScheme.tertiaryContainer,
            colorScheme.onTertiaryContainer,
                () => controller.goToProductsList(controller.shopDocId!),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCountCard(
            context,
            'إجمالي العروض',
            controller.totalOffersCount, // Pass RxInt
            Icons.local_offer,
            colorScheme.primaryContainer,
            colorScheme.onPrimaryContainer,
                () => controller.goToOffersList(controller.shopDocId!),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCountCard(
            context,
            'العروض النشطة',
            controller.activeOffersCount, // Pass RxInt
            Icons.flash_on,
            colorScheme.secondaryContainer,
            colorScheme.onSecondaryContainer,
                () => controller.goToOffersList(controller.shopDocId!),
          ),
        ),
      ],
    );
  }

  Widget _buildCountCard(
      BuildContext context,
      String title,
      RxInt countObservable, // Changed parameter type to RxInt
      IconData icon,
      Color cardColor,
      Color onCardColor,
      VoidCallback onTap,
      ) {
    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: onCardColor),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: onCardColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Obx(() => Text( // Only this Text widget rebuilds when countObservable changes
                countObservable.value.toString(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: onCardColor,
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagementButtons(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => controller.goToAddProduct(controller.shopDocId!),
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('إضافة منتج'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => controller.goToAddOffer(controller.shopDocId!),
            icon: const Icon(Icons.discount),
            label: const Text('إضافة عرض'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.secondary,
              foregroundColor: colorScheme.onSecondary,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementCard(BuildContext context, ColorScheme colorScheme) {
    return Card(
      color: colorScheme.tertiaryContainer,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.campaign, size: 36, color: colorScheme.onTertiaryContainer),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إعلان المتجر',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onTertiaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() => Text( // Only this Text widget rebuilds when announcementMessage changes
                    controller.announcementMessage.value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colorScheme.onTertiaryContainer),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to launch URLs
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      Get.snackbar('خطأ', 'لا يمكن فتح الرابط: $url',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.errorContainer,
          colorText: Get.theme.colorScheme.onErrorContainer);
    }
  }

  // Helper widget for displaying a single info row
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // Adjust width as needed for alignment
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
              softWrap: true, // Allow text to wrap
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for displaying and copying text
  Widget _buildCopyableInfoRow(BuildContext context, String label, String textToCopy) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // Adjust width as needed for alignment
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (textToCopy.isNotEmpty && textToCopy != 'غير متوفر') {
                  Clipboard.setData(ClipboardData(text: textToCopy));
                  Get.snackbar(
                    'تم النسخ',
                    'تم نسخ $label إلى الحافظة',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                    colorText: Theme.of(context).colorScheme.surface,
                  );
                }
              },
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      textToCopy.isEmpty ? 'غير متوفر' : textToCopy,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary, // Make it look clickable
                        decoration: textToCopy.isNotEmpty && textToCopy != 'غير متوفر'
                            ? TextDecoration.underline
                            : TextDecoration.none,
                      ),
                      softWrap: true,
                    ),
                  ),
                  if (textToCopy.isNotEmpty && textToCopy != 'غير متوفر')
                    Icon(Icons.copy, size: 16, color: Theme.of(context).colorScheme.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Improved Additional Info Section
  Widget _buildAdditionalInfoSection(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معلومات إضافية',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
            ),
            const SizedBox(height: 16),
            // Store ID with copy functionality
            Obx(() => _buildCopyableInfoRow(
              context,
              "معرف المتجر:",
              controller.shopDocId ?? 'غير متوفر',
            )),
            // Contact Email
            Obx(() => _buildInfoRow(
              context,
              'البريد الإلكتروني:',
              controller.contactEmail.value.isEmpty ? 'غير متوفر' : controller.contactEmail.value,
            )),
            // Location
            Obx(() => _buildInfoRow(
              context,
              'العنوان:',
              controller.location.value.isEmpty ? 'غير متوفر' : controller.location.value,
            )),
            // Delivery Options
            Obx(() => _buildInfoRow(
              context,
              'خيارات التوصيل:',
              controller.deliveryOptions.isEmpty ? 'غير متوفر' : controller.deliveryOptions.join(', '),
            )),
            // Payment Methods
            Obx(() => _buildInfoRow(
              context,
              'طرق الدفع:',
              controller.paymentMethods.isEmpty ? 'غير متوفر' : controller.paymentMethods.join(', '),
            )),
            // Announcement Message
            Obx(() => _buildInfoRow(
              context,
              'رسالة الإعلان:',
              controller.announcementMessage.value.isEmpty ? 'لا توجد رسالة' : controller.announcementMessage.value,
            )),
            // Announcement Active Status
            Obx(() => _buildInfoRow(
              context,
              'حالة الإعلان:',
              controller.announcementActive.value ? 'مفعل' : 'غير مفعل',
            )),
            // Store Status
            Obx(() => _buildInfoRow(
              context,
              'حالة المتجر:',
              statusDisplayNames[controller.status.value] ?? 'غير متوفر',
            )),
          ],
        ),
      ),
    );
  }
}