import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants.dart';
import 'core/save_system.dart';
import 'core/theme.dart';
import 'providers/game_state.dart';
import 'screens/main_menu_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SaveSystem.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (context) => GameState(),
      child: const UrWarApp(),
    ),
  );
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
