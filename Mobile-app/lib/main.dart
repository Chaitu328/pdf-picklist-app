import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/routes/app_routes.dart';
import 'package:flutter/services.dart';
import 'services/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔒 LOCK ORIENTATION (Portrait only)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await GetStorage.init();
  Get.put(ThemeController());
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventory Management',
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.getPages,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    ),
  );
}

final box = GetStorage();
