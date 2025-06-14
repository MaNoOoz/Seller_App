import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/controllers/home_controller.dart'; // For launching URLs (phone, email, social)


class StoreInfoWidget extends StatelessWidget {
  final HomeController homeController;

  const StoreInfoWidget({Key? key, required this.homeController}) : super(key: key);

  // Helper to launch URLs
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      Get.snackbar('خطأ', 'لا يمكن فتح الرابط: $url', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final store = homeController.storeInfo.value;

      return AnimatedOpacity(
        opacity: store != null ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500), // Smooth fade-in
        child: AnimatedSize(
          duration: const Duration(milliseconds: 500), // Smooth size transition
          alignment: Alignment.topCenter,
          child: store == null
              ? _buildLoadingState(context) // Show loading state
              : Material(
            elevation: 4,
            shadowColor: Theme.of(context).colorScheme.shadow,
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).colorScheme.surface, // Main card background
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Store Header: Logo, Name, Description, Status ---
                  _buildSectionContainer(
                    context,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: store.logoUrl,
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                            const Icon(Icons.store, size: 80, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                store.name,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                store.description,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Chip(
                            label: Text(store.status,
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSecondary,
                                  fontWeight: FontWeight.bold,
                                )),
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    padding: const EdgeInsets.all(16),
                  ),

                  const SizedBox(height: 20), // Spacing between sections

                  // --- Location & Contact Info Section ---
                  _buildSectionContainer(
                    context,
                    title: 'معلومات التواصل',
                    child: Column(
                      children: [
                        _buildInfoRow(
                          context,
                          icon: Icons.location_on,
                          label: 'الموقع',
                          value: store.location,
                        ),
                        _buildClickableInfoRow(
                          context,
                          icon: Icons.phone,
                          label: 'الهاتف',
                          value: store.phone,
                          onTap: () => _launchUrl('tel:${store.phone.replaceAll(' ', '')}'),
                        ),
                        _buildClickableInfoRow(
                          context,
                          icon: Icons.email,
                          label: 'البريد الإلكتروني',
                          value: store.contactEmail,
                          onTap: () => _launchUrl('mailto:${store.contactEmail}'),
                        ),
                        if (store.social.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('تواصل اجتماعي:', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                              Row(
                                children: [
                                  if (store.social['instagram'] != null && store.social['instagram']!.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.photo_camera_outlined), // More specific icon for Instagram
                                      color: Theme.of(context).colorScheme.primary,
                                      onPressed: () => _launchUrl(store.social['instagram']),
                                      tooltip: 'Instagram',
                                    ),
                                  // Add more social media icons as needed (e.g., if you have Facebook, Twitter)
                                ],
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  ),

                  const SizedBox(height: 20),

                  // --- Operational Info Section ---
                  _buildSectionContainer(
                    context,
                    title: 'معلومات التشغيل',
                    child: Column(
                      children: [
                        _buildWorkingHours(context, store.workingHours),
                        _buildInfoRow(
                          context,
                          icon: Icons.delivery_dining,
                          label: 'خيارات التوصيل',
                          value: store.deliveryOptions.join(', '),
                        ),
                        _buildInfoRow(
                          context,
                          icon: Icons.payment,
                          label: 'طرق الدفع',
                          value: store.paymentMethods.join(', '),
                        ),
                      ],
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  ),

                  // --- Announcement (if active) ---
                  if (store.announcementActive && store.announcementMessage.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildSectionContainer(
                      context,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.campaign, color: Theme.of(context).colorScheme.onPrimaryContainer),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'إعلان: ${store.announcementMessage}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                      padding: const EdgeInsets.all(12),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // Helper method to build consistent section containers
  Widget _buildSectionContainer(
      BuildContext context, {
        String? title,
        required Widget child,
        Color? backgroundColor,
        EdgeInsetsGeometry padding = const EdgeInsets.all(16),
      }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        // color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Divider(height: 20, thickness: 1),
          ],
          child,
        ],
      ),
    );
  }

  // Helper method for generic info rows
  Widget _buildInfoRow(BuildContext context, {required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), size: 20),
          const SizedBox(width: 10),
          Expanded(
            flex: 2, // Label takes less space
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3, // Value takes more space
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
              textAlign: TextAlign.end, // Align value to the right
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for clickable info rows (phone, email)
  Widget _buildClickableInfoRow(BuildContext context, {required IconData icon, required String label, required String value, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: Text(
                  '$label:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary, // Make clickable text stand out
                    decoration: TextDecoration.underline,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for working hours display
  Widget _buildWorkingHours(BuildContext context, Map<String, dynamic> workingHours) {
    if (workingHours.isEmpty) {
      return _buildInfoRow(context, icon: Icons.access_time, label: 'ساعات العمل', value: 'غير متوفرة');
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), size: 20),
              const SizedBox(width: 10),
              Text(
                'ساعات العمل:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 30.0), // Indent working hours
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: workingHours.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Day on left, hours on right
                    children: [
                      Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        entry.value.toString(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildLoadingState(BuildContext context) {
    return Material(
      elevation: 4,
      shadowColor: Theme.of(context).colorScheme.shadow,
      borderRadius: BorderRadius.circular(16),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 24, width: 150, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      Container(height: 16, width: 200, color: Colors.grey[200]),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            Container(height: 20, width: 120, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Container(height: 14, width: double.infinity, color: Colors.grey[200]),
            const SizedBox(height: 8),
            Container(height: 14, width: double.infinity, color: Colors.grey[200]),
            const SizedBox(height: 8),
            Container(height: 14, width: double.infinity, color: Colors.grey[200]),
          ],
        ),
      ),
    );
  }
}

