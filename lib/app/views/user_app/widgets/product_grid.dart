import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/controllers/home_controller.dart';

class ProductGrid extends StatelessWidget {
  final HomeController homeController;

  const ProductGrid({Key? key, required this.homeController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Adjust based on screen size
        childAspectRatio: 0.7, // Adjust aspect ratio to improve card size
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: homeController.filteredMenuItems.length,
      itemBuilder: (context, index) {
        final item = homeController.filteredMenuItems[index];
        return Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Display Image or Placeholder if no image
              item.images.isNotEmpty
                  ? Image.network(
                item.images[0],
                fit: BoxFit.cover,
                height: 140,
                width: double.infinity,
              )
                  : Container(
                height: 140,
                color: Colors.grey[200],
                child: Icon(Icons.broken_image),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  item.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '${item.price} ريال',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
