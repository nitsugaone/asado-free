import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'flavors/flavor_config.dart';
import 'app_state.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Google Mobile Ads
  await MobileAds.instance.initialize();

  FlavorConfig.initialize(
    flavor: Flavor.free,
    appName: 'Asador Patagónico',
    bundleId: 'com.olmosle.asado.free',
    showAds: true,
    isPro: false,
  );

  // Inicializar el estado reactivo global
  await AppState.instance.initialize();

  runApp(const AsadorApp());
}
