import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/controllers/home_controller.dart';


class StoreInfoWidget extends StatelessWidget {
  final HomeController homeController;

  const StoreInfoWidget({Key? key, required this.homeController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (homeController.storeInfo.value == null) {
        return Container(); // No store info to display
      }

      final store = homeController.storeInfo.value!;
      return Container(
        padding: EdgeInsets.all(16),
        color: Theme.of(context).colorScheme.background,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Store logo
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(store.logoUrl, height: 60, width: 60, fit: BoxFit.cover),
            ),
            SizedBox(height: 28),
            // Store name
            Column(
              children: [
                Text(store.name, style: Theme.of(context).textTheme.displaySmall),
                SizedBox(height: 4),
                // Store description
                Text(store.description, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                SizedBox(height: 8),
                // Store location and contact info
                Text('Location: ${store.location}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                SizedBox(height: 4),

                Text('Phone: ${store.phone}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                SizedBox(height: 4),

                Text('Email: ${store.location}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),


          ],
        ),
      );
    });
  }
}
