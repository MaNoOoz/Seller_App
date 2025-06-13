import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/controllers/home_controller.dart';

class ProductsHorizontalList extends StatelessWidget {
  final HomeController homeController;

  const ProductsHorizontalList({Key? key, required this.homeController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = homeController.filteredMenuItems;
      // if (list.isEmpty) {
      //   return const SizedBox(
      //     height: 200,
      //     child: Center(child: Text('لا توجد منتجات')),
      //   );
      // }

      return Card(
        child: SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Container(
                  width: 180,
                  margin: const EdgeInsets.only(right: 12),
                  child: Stack(
                    children: [
                      // Full-background image

                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(item.images.first),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      // Semi-transparent overlay (optional)
                      // ClipRRect(
                      //   borderRadius: BorderRadius.circular(12),
                      //   child: Container(
                      //     color: Colors.black.withOpacity(0.2),
                      //   ),
                      // ),

                      // Price badge
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${item.price.toStringAsFixed(2)} ل.س',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${item.name}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${item.category}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Product name at bottom
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}
