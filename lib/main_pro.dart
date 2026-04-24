import 'package:flutter/material.dart';
import 'flavors/flavor_config.dart';
import 'app_state.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  FlavorConfig.initialize(
    flavor: Flavor.pro,
    appName: 'Asador Patagónico Pro',
    bundleId: 'com.olmosle.asado.pro',
    showAds: false,
    isPro: true,
  );

  // Inicializar el estado reactivo global
  await AppState.instance.initialize();

  runApp(const AsadorApp());
}
