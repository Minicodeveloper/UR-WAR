import 'package:flutter/material.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'screens/main_menu_screen.dart';
// Herramienta que instalamos para compartir datos
import 'package:provider/provider.dart';

// Nuestro cerebro del juego 
import 'providers/game_state.dart';

void main() {
  // Envolvemos toda la aplicación en este 'Provider'
  runApp(
    ChangeNotifierProvider(
      // Aquí "creamos" el cerebro y lo encendemos
      create: (context) => GameState(),
      // 'child' es tu aplicación original. Así la app queda "dentro" del proveedor.
      child: const UrWarApp(), // (Nota: Si tu app no se llama MyApp, usa el nombre normal; ósea: UrWarApp())
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
