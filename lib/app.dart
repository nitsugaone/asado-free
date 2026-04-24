import 'package:flutter/material.dart';
import 'flavors/flavor_config.dart';
import 'screens/calculator_screen.dart';
import 'screens/upgrade_screen.dart';

class AsadorApp extends StatelessWidget {
  const AsadorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: FlavorConfig.instance.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6), // blue-500
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        useMaterial3: true,
      ),
      home: const CalculatorScreen(),
      routes: {
        '/upgrade': (_) => const UpgradeScreen(),
      },
    );
  }
}
