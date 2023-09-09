import 'package:get/get.dart';
import '../pages/home_page.dart';

class AppRoutes {
  static final getPages = [
    GetPage(name: home, page: () => const HomePage()),
  ];
  static const home = '/home';
}
 