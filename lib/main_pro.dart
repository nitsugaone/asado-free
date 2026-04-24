import 'package:flutter/material.dart';
import 'flavors/flavor_config.dart';
import 'app.dart';

void main() {
  FlavorConfig.initialize(
    flavor: Flavor.pro,
    appName: 'Asador Patagónico Pro',
    bundleId: 'com.olmosle.asado.pro',
    showAds: false,
    isPro: true,
  );
  runApp(const AsadorApp());
}
