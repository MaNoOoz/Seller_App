import 'package:app/app/views/user_app/widgets/category_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/StoreInfoWidget.dart';
import '../widgets/horizantl _list.dart';
import 'controllers/home_controller.dart';

class HomeScreen extends StatelessWidget {
  // final HomeController homeController = Get.put(HomeController());
  final HomeController homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text("${homeController.storeInfo.value?.name}"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    title: Text('البحث في القائمة'),
                    content: TextField(
                      decoration: InputDecoration(
                        hintText: 'ابحث عن منتج أو وصف...',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Obx(() {
        // if (homeController.isLoading.value) {
        //   return Center(child: CircularProgressIndicator());
        // }

        return ListView(
          children: [
            // Banner: A large offer banner at the top
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Container(
                margin: EdgeInsets.only(top: 10),
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(homeController.offers.isNotEmpty ? homeController.offers[0].bannerImageUrl : ''),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Big Sale!",
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Up to 50% off on all items",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Category Filter Widget
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ChoiceChip(
                    selected: false,
                    label: Text('عرض الكل'),
                    onSelected: (sel) {
                      if (sel) {
                        homeController.resetCategoryFilter();
                      }
                    },
                  ),
                  Expanded(child: CategoryWidget(homeController: homeController)),
                ],
              ),
            ),

            // Product Grid Widget
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              // child: ProductGrid(homeController: homeController),
              child: ProductsHorizontalList(homeController: homeController),
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   // child: ProductGrid(homeController: homeController),
            //   child: StoreInfoWidget(homeController: homeController),
            // ),
          ],
        );
      }),
    );
  }
}
