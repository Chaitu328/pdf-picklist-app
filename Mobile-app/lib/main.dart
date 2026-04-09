import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'app/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
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
