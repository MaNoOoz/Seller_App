// lib/app/routes/app_pages.dart
import 'package:app/app/views/user_app/screens/cart_screen.dart';
import 'package:get/get.dart';

import '../../main.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/dashboard/dashboard_controller.dart';
import '../views/dashboard/dashboard_screen.dart';

import '../views/edit_screen/edit_store_controller.dart';
import '../views/edit_screen/edit_store_screen.dart';
import '../views/no_access_screen.dart';
import '../views/offers/add_offer_controller.dart';
import '../views/offers/add_offer_screen.dart';
import '../views/offers/edit_offer_controller.dart';
import '../views/offers/edit_offer_screen.dart';
import '../views/offers/offers_list_controller.dart';
import '../views/offers/offers_list_screen.dart';
import '../views/products/add_product_controller.dart';
import '../views/products/add_product_screen.dart';
import '../views/products/edit_product_controller.dart';
import '../views/products/edit_product_screen.dart';
import '../views/products/products_list_controller.dart';
import '../views/products/products_list_screen.dart';
import '../views/splash.dart';
import '../views/user_app/screens/controllers/cart_controller.dart';
import '../views/user_app/screens/home_screen.dart';


part 'routes.dart';

class AppPages {
  static final routes = [


    GetPage(
      name: Routes.HOME,
      page: () =>  HomeScreen(),
    ),
    GetPage(
      name: Routes.CART,
      page: () =>  CartScreen(),

    ),
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginScreen(),
    ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () => DashboardScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DashboardController>(() => DashboardController());
      }),
    ),
    // GetPage(
    //   name: Routes.REGISTER,
    //   page: () => RegisterScreen(),
    // ),
    GetPage(
      name: Routes.NO_ACCESS,
      page: () => const NoAccessScreen(),
    ),
    GetPage(
      name: Routes.EDIT_STORE, // <--- NEW PAGE DEFINITION
      page: () => const EditStoreScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EditStoreController>(() => EditStoreController());
      }),
    ),
    GetPage( // <--- NEW PAGE DEFINITION for Add Product
      name: Routes.ADD_PRODUCT,
      page: () => const AddProductScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AddProductController>(() => AddProductController());
      }),
    ),
    GetPage( // <--- NEW PAGE DEFINITION for Products List
      name: Routes.PRODUCTS_LIST,
      page: () => const ProductsListScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProductsListController>(() => ProductsListController());
      }),
    ),
    GetPage( // <--- NEW PAGE DEFINITION for Add Offer
      name: Routes.ADD_OFFER,
      page: () => const AddOfferScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AddOfferController>(() => AddOfferController());
      }),
    ),
    GetPage( // <--- NEW PAGE DEFINITION for Offers List
      name: Routes.OFFERS_LIST,
      page: () => const OffersListScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OffersListController>(() => OffersListController());
      }),
    ),
    GetPage(
      name: Routes.EDIT_OFFER, // New route for editing offer
      page: () => const EditOfferScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => EditOfferController())),
    ),
    GetPage(
      name: _Paths.EDIT_PRODUCT, // New route for editing product
      page: () => const EditProductScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => EditProductController())),
    ),
    // Future routes for product/offer management
    // GetPage(name: Routes.ADD_PRODUCT, page: () => AddProductScreen(), binding: AddProductBinding()),
    // GetPage(name: Routes.PRODUCTS_LIST, page: () => ProductsListScreen(), binding: ProductsListBinding()),
    // GetPage(name: Routes.ADD_OFFER, page: () => AddOfferScreen(), binding: AddOfferBinding()),
    // GetPage(name: Routes.OFFERS_LIST, page: () => OffersListScreen(), binding: OffersListBinding()),
  ];
}