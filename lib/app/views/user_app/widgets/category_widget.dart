import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/controllers/home_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/controllers/home_controller.dart';

class CategoryWidget extends StatelessWidget {
  final HomeController homeController;

  const CategoryWidget({Key? key, required this.homeController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount:  homeController.categories.length,
          itemBuilder: (context, idx) {
            final cat = homeController.categories[idx];
            final isSelected = homeController.selectedCategory.value == cat;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ChoiceChip(
                label: Text(cat),
                selected: isSelected,
                onSelected: (sel) {
                  if (sel) {
                    homeController.filterByCategory(cat);
                  }
                },
                selectedColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                labelStyle: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
