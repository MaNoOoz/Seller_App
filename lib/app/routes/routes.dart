// lib/app/routes/routes.dart
part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const SPLASH = _Paths.SPLASH;
  static const HOME = _Paths.HOME;
  static const CART = _Paths.CART;
  static const LOGIN = _Paths.LOGIN;
  static const DASHBOARD = _Paths.DASHBOARD;
  static const REGISTER = _Paths.REGISTER;
  static const NO_ACCESS = _Paths.NO_ACCESS;
  static const EDIT_STORE = _Paths.EDIT_STORE; // <--- NEW
  static const ADD_PRODUCT = _Paths.ADD_PRODUCT; // <--- NEW (for future)
  static const PRODUCTS_LIST = _Paths.PRODUCTS_LIST; // <--- NEW (for future)
  static const ADD_OFFER = _Paths.ADD_OFFER; // <--- NEW (for future)
  static const OFFERS_LIST = _Paths.OFFERS_LIST;
  static const EDIT_OFFER = _Paths.EDIT_OFFER;
  static const EDIT_PRODUCT = _Paths.EDIT_PRODUCT;


}

abstract class _Paths {
  _Paths._();
  static const SPLASH = '/splash';
  static const HOME = '/home';
  static const CART = '/cart';
  static const LOGIN = '/login';
  static const DASHBOARD = '/dashboard';
  static const REGISTER = '/register';
  static const NO_ACCESS = '/no-access';
  static const EDIT_STORE = '/edit-store'; // <--- NEW
  static const ADD_PRODUCT = '/add-product'; // <--- NEW (for future)
  static const PRODUCTS_LIST = '/products-list'; // <--- NEW (for future)
  static const ADD_OFFER = '/add-offer'; // <--- NEW (for future)
  static const OFFERS_LIST = '/offers-list'; // <--- NEW (for future)
  static const EDIT_OFFER = '/edit-offer'; // <--- NEW (for future)
  static const EDIT_PRODUCT = '/edit-product'; // <--- NEW (for future)
}