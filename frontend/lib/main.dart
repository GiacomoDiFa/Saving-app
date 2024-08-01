import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/screens/otp_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/home_screen.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

void main() {
  runApp(ProviderScope(
    child: MyApp(),
  ));
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.circle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..maskType = EasyLoadingMaskType.black
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      builder: EasyLoading.init(),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/otp': (context) => OtpScreen(),
        '/signup': (context) => RegistrationScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
