import 'package:calcu/presentation/pages/home_page.dart';
import 'package:calcu/presentation/providers/home_provider.dart';
import 'package:calcu/theme/app_theme.dart';
import 'package:calcu/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<HomeProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<ThemeProvider>()),
      ],
      child: Consumer<ThemeProvider>(builder: (context, value, _) {
        return MaterialApp(
          title: 'Calcu App',
          theme: AppTheme.defalultTheme,
          home: const HomePage(),
          themeMode: value.themeMode,
          darkTheme: AppTheme.darkTheme,
          debugShowCheckedModeBanner: false,
        );
      }),
    );
  }
}
