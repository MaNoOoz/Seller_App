import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../../models/product.dart';

class CartController extends GetxController {
  // Enhanced logging configuration
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      colors: true,
      printEmojis: true,
      printTime: true, // Added time for better debugging
    ),
  );

  // Reactive cart items with type safety
  final RxList<CartItem> _cartItems = <CartItem>[].obs;
  List<CartItem> get cartItems => _cartItems.toList();

  /// Add product to cart or increment quantity
  void addToCart(Product product, {int quantity = 1}) {
    try {
      final existingIndex = _cartItems.indexWhere((item) => item.product.id == product.id);

      if (existingIndex != -1) {
        _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
            quantity: _cartItems[existingIndex].quantity + quantity
        );
        _logger.i('➕ Increased quantity for ${product.name}');
      } else {
        _cartItems.add(CartItem(product: product, quantity: quantity));
        _logger.i('🛒 Added to cart: ${product.name}');
        _showSnackbar(
          title: "تمت الإضافة",
          message: "${product.name} أضيف إلى السلة",
          type: SnackbarType.success,
        );
      }
    } catch (e) {
      _logger.e('❌ Error adding to cart: $e');
      _showSnackbar(
        title: "خطأ",
        message: "فشل إضافة المنتج",
        type: SnackbarType.error,
      );
    }
  }

  /// Decrease quantity or remove item if quantity reaches zero
  void decreaseQuantity(Product product) {
    try {
      final index = _cartItems.indexWhere((item) => item.product.id == product.id);
      if (index == -1) return;

      final currentItem = _cartItems[index];
      if (currentItem.quantity > 1) {
        _cartItems[index] = currentItem.copyWith(quantity: currentItem.quantity - 1);
      } else {
        removeFromCart(product);
      }
    } catch (e) {
      _logger.e('❌ Error decreasing quantity: $e');
    }
  }

  /// Remove specific product from cart
  void removeFromCart(Product product) {
    _cartItems.removeWhere((item) => item.product.id == product.id);
    _showSnackbar(
      title: "تم الحذف",
      message: "${product.name} تمت إزالته من السلة",
      type: SnackbarType.error,
    );
    _logger.w('🗑️ Removed ${product.name} from cart');
  }

  /// Clear entire cart with confirmation
  Future<void> clearCart() async {
    if (_cartItems.isEmpty) return;

    _cartItems.clear();
    _logger.w("🧹 Cart cleared");
    _showSnackbar(
      title: "تم التفريغ",
      message: "تم تفريغ السلة بنجاح",
      type: SnackbarType.info,
    );
  }

  /// Get total cart value
  double get totalPrice => _cartItems.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));

  /// Get total number of items in cart
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  /// Generate formatted WhatsApp order message
  String generateWhatsAppMessage(String restaurantName) {
    if (_cartItems.isEmpty) return Uri.encodeComponent("سلة الطلبات فارغة.");

    final buffer = StringBuffer()
      ..writeln("مرحباً، أود الطلب من $restaurantName:")
      ..writeln("-------------------------------");

    for (final item in _cartItems) {
      final total = (item.product.price * item.quantity).toStringAsFixed(0);
      buffer.writeln("• ${item.product.name} × ${item.quantity} = $total ل.س");

      // Add product notes if available
      if (item.notes != null && item.notes!.isNotEmpty) {
        buffer.writeln("  - ملاحظات: ${item.notes}");
      }
    }

    buffer
      ..writeln("-------------------------------")
      ..writeln("الإجمالي: ${totalPrice.toStringAsFixed(0)} ل.س")
      ..writeln("\nشكراً لكم!");

    return Uri.encodeComponent(buffer.toString());
  }

  /// Update product notes
  void updateProductNotes(Product product, String notes) {
    final index = _cartItems.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      _cartItems[index] = _cartItems[index].copyWith(notes: notes);
      _logger.i('📝 Updated notes for ${product.name}');
    }
  }

  /// Show customized snackbar
  void _showSnackbar({
    required String title,
    required String message,
    required SnackbarType type,
  }) {
    final theme = Get.theme;
    late final Color backgroundColor;
    late final Color textColor;

    switch (type) {
      case SnackbarType.success:
        backgroundColor = theme.colorScheme.primaryContainer;
        textColor = theme.colorScheme.onPrimaryContainer;
        break;
      case SnackbarType.error:
        backgroundColor = theme.colorScheme.errorContainer;
        textColor = theme.colorScheme.onErrorContainer;
        break;
      case SnackbarType.info:
      default:
        backgroundColor = theme.colorScheme.surfaceVariant;
        textColor = theme.colorScheme.onSurface;
        break;
    }

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor,
      colorText: textColor,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
      animationDuration: const Duration(milliseconds: 300),
      mainButton: _cartItems.isNotEmpty
          ? TextButton(
        onPressed: () => Get.toNamed('/cart'),
        child: Text(
          'عرض السلة ($itemCount)',
          style: TextStyle(color: theme.colorScheme.primary),
        ),
      )
          : null,
    );
  }
}

/// Type-safe cart item model
class CartItem {
  final Product product;
  final int quantity;
  final String? notes;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.notes,
  });

  CartItem copyWith({
    Product? product,
    int? quantity,
    String? notes,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }
}

/// Snackbar types
enum SnackbarType { success, error, info }