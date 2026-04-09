import 'package:get/get.dart';
import '../../../../main.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 2), () {
      final token = box.read("user_token");
      if (token != null && token.toString().isNotEmpty) {
        Get.offAllNamed(AppRoutes.bottomMain);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    });
  }
}
