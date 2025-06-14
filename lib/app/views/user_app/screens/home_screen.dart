import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../../../routes/app_pages.dart';
import '../models/product.dart';
import '../widgets/StoreInfoWidget.dart';
import 'controllers/cart_controller.dart';
import 'controllers/home_controller.dart';

class HomeScreen extends StatelessWidget {
  final HomeController homeController = Get.find<HomeController>();
  final CartController cartController = Get.find<CartController>();

  // final ProductController controller = Get.find<ProductController>();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          Obx(() {
            final storeReady = homeController.storeInfo.value?.name != null && homeController.storeInfo.value?.phone != null;

            return IconButton(
              icon: Badge(
                label: Obx(() => Text("${Get.find<CartController>().cartItems.length}")),
                child: const Icon(FontAwesomeIcons.cartPlus),
              ),
              onPressed: storeReady
                  ? () {
                      Get.toNamed(
                        Routes.CART,
                        arguments: {
                          "restaurantName": homeController.storeInfo.value?.name ?? '',
                          "whatsappNumber": homeController.storeInfo.value?.phone ?? '',
                        },
                        // transition: Transition.fadeIn,
                        // duration: const Duration(milliseconds: 300),
                      );
                    }
                  : () {
                      Get.snackbar(
                        'يرجى الانتظار',
                        'يتم تحميل بيانات المطعم...',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.black87,
                        colorText: Colors.white,
                      );
                    },
              tooltip: 'السلة',
            );
          }),
        ]
        // backgroundColor: Colors.white,
        // surfaceTintColor: Colors.pink.shade100,
        // shape: BeveledRectangleBorder(
        //   borderRadius: BorderRadius.circular(22),
        // ),
        ,
        title: Obx(() {
          return Text(
            homeController.storeInfo.value?.name ?? 'جاري التحميل...',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'DG Sahabah',
                  fontSize: 16,
                ),
          );
        }),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 2), // Adjust this value

        child: Directionality(
          // RTL support
          textDirection: TextDirection.rtl,
          child: Obx(() {
            Logger().d('Loading: ${homeController.isLoading.value}');
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  // _buildWelcomeSection(context),

                  // Offers Carousel
                  // _buildOffersCarousel(context),

                  // Menu Title
                  _buildSectionTitle(context, "قائمة الطعام"),

                  // Categories Products
                  _buildCategoriesProducts(context),

                  // Store Info
                  // _buildStoreInfo(context),
                  // StoreInfoWidget(homeController: homeController),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }


  Widget _buildSectionTitle(BuildContext context, String title) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book, color: Colors.blue),
            const SizedBox(width: 18),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'DG Sahabah',
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesProducts(BuildContext context) {
    return Obx(() => Column(
          children: homeController.categories.map((categoryName) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        const Icon(Icons.category, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          categoryName,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onBackground,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'DG Sahabah',
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 33),
                  SizedBox(
                    height: 320,
                    child: _buildProductsForCategory(context, categoryName),
                  ),
                ],
              ),
            );
          }).toList(),
        ));
  }

  Widget _buildProductsForCategory(BuildContext context, String categoryName) {
    final products = homeController.getProductsByCategory(categoryName);
    if (products.isEmpty) return const SizedBox.shrink();

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: products.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: 10,
            top: 10,
            right: index == 0 ? 20 : 8, // RTL adjustment
            left: index == products.length - 1 ? 20 : 0, // RTL adjustment
          ),
          child: _buildFlipCard(products[index], context),
        );
      },
    );
  }

  Widget _buildFlipCard(Product product, BuildContext context) {
    return GestureDetector(
      onTap: () => homeController.toggleCardFlip(product),
      child: Obx(() {
        final isFlipped = homeController.isCardFlipped(product);
        return TweenAnimationBuilder(
          tween: Tween<double>(begin: isFlipped ? 1 : 0, end: isFlipped ? 1 : 0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          builder: (_, value, __) {
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(value * 3.1416),
              alignment: Alignment.center,
              child: value < 0.5
                  ? _buildCardFront(product, context)
                  : Transform(
                      transform: Matrix4.identity()..rotateY(3.1416),
                      alignment: Alignment.center,
                      child: _buildCardBack(product, context),
                    ),
            );
          },
        );
      }),
    );
  }

  Widget _buildCardFront(Product product, BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Replace Expanded with Positioned.fill
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: product.images.first,
                fit: BoxFit.cover,
                placeholder: (_, __) => Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                errorWidget: (_, __, ___) => const Icon(Icons.fastfood),
              ),
            ),
          ),

          // Rest of your Stack children remain the same
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                product.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'DG Sahabah',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const Align(
              alignment: Alignment.bottomRight,
              child: Icon(Icons.touch_app, size: 16)
          ),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              color: Colors.deepPurple,
              icon: const Icon(Icons.shopping_cart_checkout, size: 33),
              onPressed: () {
                cartController.addToCart(product);
              },
              tooltip: 'إضافة إلى السلة',
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildCardBack(Product product, BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'DG Sahabah',
            ),
          ),
          const Divider(height: 20),
          Text(
            product.description,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'DG Sahabah',
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${product.price.toStringAsFixed(2)} ر.س',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'DG Sahabah',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.shopping_cart_checkout),
                onPressed: () {
                  cartController.addToCart(product);
                },
                tooltip: 'إضافة إلى السلة',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoreInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.store, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'معلومات المتجر',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontFamily: 'DG Sahabah',
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final store = homeController.storeInfo.value;
            if (store == null) return const CircularProgressIndicator();

            return Column(
              children: [
                _buildInfoRow(Icons.access_time, 'ساعات العمل: ${store.workingHours}'),
                _buildInfoRow(Icons.phone, 'الهاتف: ${store.phone}'),
                _buildInfoRow(Icons.location_on, 'العنوان: ${store.location}'),
                _buildInfoRow(Icons.email, 'البريد: ${store.contactEmail}'),
              ],
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontFamily: 'DG Sahabah'),
            ),
          ),
        ],
      ),
    );
  }
}

