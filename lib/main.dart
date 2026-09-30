import 'package:flutter/material.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'screens/main_menu_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UrWarApp());
}

class UrWarApp extends StatelessWidget {
  const UrWarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainMenuScreen(),
    );
  }
}
