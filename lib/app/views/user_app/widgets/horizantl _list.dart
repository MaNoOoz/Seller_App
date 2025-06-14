import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
import '../models/product.dart';
import '../screens/controllers/home_controller.dart';

class ProductsHorizontalList extends StatelessWidget {
  final HomeController homeController;

  const ProductsHorizontalList({super.key, required this.homeController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
       RxList<Product> list = homeController.filteredMenuItems;

      return SizedBox(
        height: 360,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            return _buildAnimatedCard(item, theme);
          },
        ),
      );
    });
  }

  Widget _buildAnimatedCard( Product item, ThemeData theme) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: item.images.first,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 40),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 12,
                      right: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            item.name,
                            style: TextStyle(

                              fontFamily: 'DG Sahabah',
                            ),
                            // style: GoogleFonts.cairo(
                            //   color: Colors.white,
                            //   fontSize: 18,
                            //   fontWeight: FontWeight.bold,
                            // ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
