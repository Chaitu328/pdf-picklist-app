import 'package:get/get.dart';
import '../main.dart';

class ThemeController extends GetxController {
  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = box.read("is_dark_mode") ?? false;
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    box.write("is_dark_mode", isDarkMode.value);
  }
}
