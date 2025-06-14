import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/Offer.dart';
import '../models/product.dart';
import '../widgets/StoreInfoWidget.dart';
import 'controllers/home_controller.dart';

class HomeScreen extends StatelessWidget {
  final HomeController homeController = Get.find<HomeController>();
  final ProductController controller = Get.put(ProductController());

  // final ProductController controller = Get.find<ProductController>();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
        ),

        toolbarHeight: 80,
        // Increased height for modern look
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        // For Material 3
        elevation: 0.5,
        // Subtle shadow
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
          tooltip: 'القائمة', // Arabic for 'Menu'
        ),
        title: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                homeController.storeInfo.value?.name ?? 'جاري التحميل...',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'DG Sahabah',
                ),
              ),
              SizedBox(height: 4),

              if (homeController.storeInfo.value != null)
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'متجرك المفضل', // "Your favorite store" in Arabic
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontFamily: 'DG Sahabah',
                        ),
                  ),
                ),
            ],
          );
        }),
        actions: [
          IconButton(
            icon: Badge(
              // Notification badge
              label: const Text('3'), // Replace with dynamic count
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
      ),
      body: Directionality(
        // RTL support
        textDirection: TextDirection.rtl,
        child: Obx(() {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                _buildWelcomeSection(context),

                // Offers Carousel
                _buildOffersCarousel(context),

                // Menu Title
                _buildSectionTitle(context, "القائمة الرئيسية"),

                // Categories Products
                _buildCategoriesProducts(context),

                // Store Info
                // _buildStoreInfo(context),
                StoreInfoWidget(homeController: homeController),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      child: Row(
        children: [
          const Icon(Icons.waving_hand, color: Colors.amber),
          const SizedBox(width: 8),
          Text(
            "مرحبا بكم! 👋",
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'DG Sahabah',
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersCarousel(BuildContext context) {
    if (homeController.offers.isEmpty && !homeController.isLoading.value) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            'لا توجد عروض متاحة حالياً',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                  fontFamily: 'DG Sahabah',
                ),
          ),
        ),
      );
    }

    return CarouselSlider.builder(
      itemCount: homeController.offers.isEmpty ? 1 : homeController.offers.length,
      itemBuilder: (context, index, _) {
        if (homeController.offers.isEmpty) {
          return _buildLoadingOfferCard(context);
        }
        return _buildOfferCard(context, homeController.offers[index]);
      },
      options: CarouselOptions(
        height: 200.0,
        enlargeCenterPage: true,
        autoPlay: true,
        aspectRatio: 16 / 9,
        viewportFraction: 0.8,
      ),
    );
  }

  Widget _buildLoadingOfferCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[300],
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildOfferCard(BuildContext context, Offer offer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: CachedNetworkImageProvider(offer.bannerImageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16, // RTL adjustment
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end, // RTL adjustment
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_offer, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        offer.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'DG Sahabah',
                            ),
                      ),
                    ],
                  ),
                  Text(
                    offer.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          fontFamily: 'DG Sahabah',
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      child: Row(
        children: [
          const Icon(Icons.menu_book, color: Colors.blue),
          const SizedBox(width: 8),
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
    );
  }

  Widget _buildCategoriesProducts(BuildContext context) {
    return Obx(() => Column(
          children: homeController.categories.map((categoryName) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
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
            right: index == 0 ? 20 : 8, // RTL adjustment
            left: index == products.length - 1 ? 20 : 0, // RTL adjustment
          ),
          child: _buildFlipCard(products[index], context),
        );
      },
    );
  }

  Widget _buildFlipCard(Product product, BuildContext context) {
    final controller = Get.find<ProductController>();
    return GestureDetector(
      onTap: () => controller.toggleCardFlip(product),
      child: Obx(() {
        final isFlipped = controller.isCardFlipped(product);
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
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: product.images.first,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (_, __) => Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                errorWidget: (_, __, ___) => const Icon(Icons.fastfood),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            product.name,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'DG Sahabah',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.touch_app, size: 16),
              SizedBox(width: 4),
              Text('', style: TextStyle(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(Product product, BuildContext context) {
    return Container(
      width: 180,
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
                onPressed: () {},
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

class ProductController extends GetxController {
  final flippedCards = <String, bool>{}.obs;

  bool isCardFlipped(Product product) {
    return flippedCards[product.id] ?? false;
  }

  void toggleCardFlip(Product product) {
    flippedCards[product.id] = !isCardFlipped(product);
  }
}