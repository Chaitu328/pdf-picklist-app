import 'package:get/get_navigation/src/routes/get_route.dart';

import '../../common_widgets/bottom_navigation_bar/bottom_navigation_view.dart' hide ViewPickList;
import '../modules/home/views/expand_screen.dart';
import '../modules/login/views/login_view.dart';
import '../modules/regester_village/views/picklist_view.dart';
import '../modules/register/views/register_view.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/worker/views/worker_submit_view.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String bottomMain = '/bottomMain';
  static const String registerVillage = '/registerVillage';
  static const String expandInfo = '/expandInfo';
  static const String workerSubmit = '/workerSubmit';

  static List<GetPage> getPages = [
    GetPage(name: splash, page: () => SplashView()),
    GetPage(name: login, page: () => const LoginView(),binding: LoginBinding(),),
    GetPage(name: register, page: () => RegisterView()),
    GetPage(name: bottomMain, page: () => BottomMainBar()),
    GetPage(name: registerVillage, page: () => ViewPickList()),
    GetPage(name: expandInfo, page: () => ExpandScreen()),
    GetPage(name: workerSubmit, page: () => WorkerSubmitView()),
  ];
}
