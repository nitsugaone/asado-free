import 'package:flutter/material.dart';
import 'flavors/flavor_config.dart';
import 'app.dart';

void main() {
  FlavorConfig.initialize(
    flavor: Flavor.free,
    appName: 'Asador Patagónico',
    bundleId: 'com.olmosle.asado.free',
    showAds: true,
    isPro: false,
  );
  runApp(const AsadorApp());
}
