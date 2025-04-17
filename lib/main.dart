import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:world_clock_app/controllers/theme_controller.dart';
import 'package:world_clock_app/screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'utils/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeService = await Get.putAsync(() => ThemeService().init());

  runApp(MyApp(themeService));
}

class MyApp extends StatelessWidget {
  final ThemeService themeService;

  const MyApp(this.themeService, {super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: themeService.themeMode,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.white,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121212),
          appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
        ),
        home: SplashScreen(),
      ),
    );
  }
}
