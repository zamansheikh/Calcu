import 'package:calcu/pages/calcu_page.dart';
import '../pages/home_page.dart';

class AppRoutes {
  static final pages = {
    calcu: (context) => const CalcuPage(),
    home: (context) => const HomePage(),
  };
  static const calcu = '/calcu';
  static const home = '/home';
}
