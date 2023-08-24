import 'package:calcu/config/app_variable.dart';
import 'package:calcu/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'config/app_routes.dart';
import 'config/app_strings.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.calcu,
      routes: AppRoutes.pages,
    );
  }
}
