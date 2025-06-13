import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../views/dashboard/dashboard_controller.dart';
import '../views/dashboard/admin_controller.dart';
import '../views/user_app/screens/controllers/home_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(HomeController(), permanent: true);

    // Get.put<AuthController>(AuthController(), permanent: true);
    // Get.put<DashboardController>(DashboardController(), permanent: true);
    // Get.put<AdminController>(AdminController(), permanent: true);
  }
}

