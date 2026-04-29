import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'core/di/injection.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/providers/calculator_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'theme/app_theme.dart';

class CalcuApp extends StatelessWidget {
  const CalcuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CalculatorProvider>(
          create: (_) => sl<CalculatorProvider>(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => sl<ThemeProvider>(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(412, 892),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return Consumer<ThemeProvider>(
            builder: (context, theme, _) {
              final pack = theme.activePack;
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Calcu',
                theme: AppTheme.build(
                  palette: pack.lightPalette,
                  brightness: Brightness.light,
                ),
                darkTheme: AppTheme.build(
                  palette: pack.darkPalette,
                  brightness: Brightness.dark,
                ),
                themeMode: theme.themeMode,
                home: const HomePage(),
              );
            },
          );
        },
      ),
    );
  }
}
