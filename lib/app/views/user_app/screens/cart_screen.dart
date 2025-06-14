import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'controllers/cart_controller.dart';


class CartScreen extends StatelessWidget {
  final CartController cartController = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سلة المشتريات'),
      ),
      body: Obx(() {
        final cartItems = cartController.cartItems;

        if (cartItems.isEmpty) {
          return const Center(child: Text('السلة فارغة'));
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (_, index) {
                  final item = cartItems[index];
                  final product = item['product'];
                  final quantity = item['quantity'];

                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text('${product.price.toStringAsFixed(0)} ل.س × $quantity'),
                    trailing: Text(
                      '${(product.price * quantity).toStringAsFixed(0)} ل.س',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),

            // 🧾 Total & Clear
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'الإجمالي:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${cartController.totalPrice.toStringAsFixed(0)} ل.س',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            Get.defaultDialog(
                              title: "تأكيد",
                              middleText: "هل أنت متأكد من مسح السلة؟",
                              confirm: TextButton(
                                onPressed: () {
                                  cartController.clearCart();
                                  Get.back();
                                },
                                child: const Text("نعم"),
                              ),
                              cancel: TextButton(
                                onPressed: () => Get.back(),
                                child: const Text("لا"),
                              ),
                            );
                          },
                          label: const Text('مسح السلة'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon( FontAwesomeIcons.whatsapp),
                          label: const Text('طلب عبر واتساب'),
                          onPressed: () {
                            final name = Get.arguments['restaurantName'] ?? '';
                            final phone = Get.arguments['whatsappNumber'] ?? '';
                            final message = cartController.generateWhatsAppMessage(name);
                            final url = "https://wa.me/$phone?text=$message";
                            launchUrl(Uri.parse(url));
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
