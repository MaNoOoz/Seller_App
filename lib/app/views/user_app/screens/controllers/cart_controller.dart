import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../../models/product.dart';

class CartController extends GetxController {
  final Logger logger = Logger();

  /// List of maps: each map has a Product and its quantity
  final RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;

  /// Add a product to cart
  void addToCart(Product product) {
    logger.i('Adding to cart: ${product.name}');
    final index = cartItems.indexWhere((item) => item['product'].id == product.id);
    if (index != -1) {
      cartItems[index]['quantity'] += 1;
      Get.snackbar(
        "تم التحديث",
        "تم زيادة الكمية لـ ${product.name}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.surfaceVariant,
        colorText: Get.theme.colorScheme.onSurface,
        duration: const Duration(seconds: 2),
      );
    } else {
      cartItems.add({'product': product, 'quantity': 1});
      Get.snackbar(
        "تمت الإضافة",
        "${product.name} أضيف إلى السلة",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
        duration: const Duration(seconds: 2),
      );
    }
  }


  /// Decrease quantity or remove
  void decreaseQuantity(Product product) {
    final index = cartItems.indexWhere((item) => item['product'].id == product.id);
    if (index != -1) {
      final qty = cartItems[index]['quantity'];
      if (qty > 1) {
        cartItems[index]['quantity'] = qty - 1;
      } else {
        cartItems.removeAt(index);
        Get.snackbar(
          "تم الحذف",
          "${product.name} تمت إزالته من السلة",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.errorContainer,
          colorText: Get.theme.colorScheme.onErrorContainer,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }


  /// Remove completely
  void removeFromCart(Product product) {
    cartItems.removeWhere((item) => item['product'].id == product.id);
    Get.snackbar(
      "تم الحذف",
      "${product.name} تمت إزالته من السلة",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.errorContainer,
      colorText: Get.theme.colorScheme.onErrorContainer,
      duration: const Duration(seconds: 2),
    );
  }


  /// Clear all
  void clearCart() {
    cartItems.clear();
  }

  /// Calculate total
  double get totalPrice => cartItems.fold(0.0, (sum, item) {
    final product = item['product'] as Product;
    final qty = item['quantity'] as int;
    return sum + (product.price * qty);
  });

  /// Generate WhatsApp message
  String generateWhatsAppMessage(String restaurantName) {
    if (cartItems.isEmpty) return "سلة الطلبات فارغة.";

    final buffer = StringBuffer("مرحباً، أود الطلب من $restaurantName:\n\n");

    for (var item in cartItems) {
      final product = item['product'] as Product;
      final quantity = item['quantity'] as int;
      buffer.writeln("• ${product.name} × $quantity = ${(product.price * quantity).toStringAsFixed(0)} ل.س");
    }

    buffer.writeln("\nالإجمالي: ${totalPrice.toStringAsFixed(0)} ل.س");

    return Uri.encodeComponent(buffer.toString());
  }
}
