import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../flavors/flavor_config.dart';
import '../app_state.dart';

/// Banner publicitario que solo se renderiza en la versión Free.
/// Se muestra en la parte inferior de la pantalla (rectangulo chico, no invasivo).
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  // IDs de prueba de Google — reemplazar con IDs reales en producción.
  static const String _adUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _adUnitIdIOS     = 'ca-app-pub-3940256099942544/2934735716';

  @override
  void initState() {
    super.initState();
    // Solo cargar ads si el flavor dice showAds Y no somos Pro
    if (!FlavorConfig.instance.showAds || AppState.instance.isPro) return;
    _loadAd();
  }

  void _loadAd() {
    final adUnitId = Theme.of(context).platform == TargetPlatform.iOS
        ? _adUnitIdIOS
        : _adUnitIdAndroid;

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner, // 320x50 — no invasivo
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isLoaded = true),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!FlavorConfig.instance.showAds || AppState.instance.isPro || !_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }
    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
