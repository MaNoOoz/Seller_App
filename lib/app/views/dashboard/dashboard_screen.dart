import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart'; // For platform-based scaling
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../routes/app_pages.dart';
import '../../utils/CopyableTextWidget.dart';
import '../../utils/theme_service.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

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
            tooltip: 'تعديل',
            onPressed: () {
              controller.goToEditStore(controller.shopDocId!);
            },
          ),
          SizedBox(width: 22),
        ],
      ),
      body: Obx(() {
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
                    onPressed: () => Get.offAllNamed(Routes.NO_ACCESS),
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

        return LayoutBuilder(
          builder: (context, constraints) {
            // Determine if it's a web or mobile screen
            bool isMobile = constraints.maxWidth < 600;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStoreInfoSection(context, isMobile),
                  const SizedBox(height: 24),
                  _buildStatsGrid(context),
                  const SizedBox(height: 24),
                  _buildSocialMediaSection(context),
                  const SizedBox(height: 24),
                  _buildAdditionalInfoSection(context),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  // Store Info Section
  Widget _buildStoreInfoSection(BuildContext context, bool isMobile) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
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
                width: isMobile ? 80 : 100,
                height: isMobile ? 80 : 100,
                fit: BoxFit.cover,
              )
                  : Icon(Icons.store, size: isMobile ? 80 : 100, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.shopName.value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                      fontSize: isMobile ? 20 : 24,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.description.value.isNotEmpty ? controller.description.value : 'لا يوجد وصف للمتجر.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: isMobile ? 20 : 24,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Stats Grid Section (products, offers)
  Widget _buildStatsGrid(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      children: [
        _buildStatCard('إجمالي المنتجات', controller.totalProductsCount.value.toString(), Icons.shopping_bag),
        _buildStatCard('إجمالي العروض', controller.totalOffersCount.value.toString(), Icons.local_offer),
        _buildStatCard('العروض النشطة', controller.activeOffersCount.value.toString(), Icons.notifications_active),
      ],
    );
  }

  // Stat Card Widget
  Widget _buildStatCard(String title, String count, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.blue),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  // Social Media Section
  Widget _buildSocialMediaSection(BuildContext context) {
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
              'حسابات التواصل الاجتماعي',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Row(
              children: controller.socialLinks.entries.map((entry) {
                return IconButton(
                  icon: _getSocialIcon(entry.key),
                  onPressed: () => _openSocialLink(entry.value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Get Social Media Icon Based on Platform
  Widget _getSocialIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return Icon(FontAwesomeIcons.facebook, size: 30, color: Colors.blue);
      case 'twitter':
        return Icon(FontAwesomeIcons.twitter, size: 30, color: Colors.lightBlue);
      case 'instagram':
        return Icon(FontAwesomeIcons.instagram, size: 30, color: Colors.pink);
      case 'linkedin':
        return Icon(FontAwesomeIcons.linkedin, size: 30, color: Colors.blueAccent);
      case 'whatsapp':
        return Icon(FontAwesomeIcons.whatsapp, size: 30, color: Colors.green);
      case 'youtube':
        return Icon(FontAwesomeIcons.youtube, size: 30, color: Colors.red);
      case 'tiktok':
        return Icon(FontAwesomeIcons.tiktok, size: 30, color: Colors.black);
      case 'snapchat':
        return Icon(FontAwesomeIcons.snapchat, size: 30, color: Colors.yellow);
      case 'pinterest':
        return Icon(FontAwesomeIcons.pinterest, size: 30, color: Colors.red);
      case 'reddit':
        return Icon(FontAwesomeIcons.reddit, size: 30, color: Colors.orange);
      case 'telegram':
        return Icon(FontAwesomeIcons.telegram, size: 30, color: Colors.blue);
      case 'discord':
        return Icon(FontAwesomeIcons.discord, size: 30, color: Colors.blueGrey); // Discord color
      case 'github':
        return Icon(FontAwesomeIcons.github, size: 30, color: Colors.black);
      default:
        return Icon(Icons.link, size: 30, color: Colors.grey);
    }
  }

  // Open Social Link
  void _openSocialLink(String url) async {
    if (url.isNotEmpty && await canLaunch(url)) {
      await launch(url);
    } else {
      Get.snackbar('خطأ', 'لا يمكن فتح الرابط: $url');
    }
  }

  // Additional Info Section
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
            CopyableTextWidget(
              labelText: "معرف المتجر:",
              textToCopy: controller.shopDocId ?? 'غير متوفر',
            ),
            _buildInfoRow('العنوان:', controller.location.value.isEmpty ? 'غير متوفر' : controller.location.value),
            _buildInfoRow('خيارات التوصيل:', controller.deliveryOptions.isEmpty ? 'غير متوفر' : controller.deliveryOptions.join(', ')),
            _buildInfoRow('طرق الدفع:', controller.paymentMethods.isEmpty ? 'غير متوفر' : controller.paymentMethods.join(', ')),
            _buildInfoRow('الإعلان:', controller.announcementActive.value ? 'مفعل' : 'غير مفعل'),
          ],
        ),
      ),
    );
  }

  // Helper Method to Build Info Rows
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }
}
