/// Configuración de flavor: define si la app corre en modo Free o Pro.
/// Se inyecta en el punto de entrada (main_free.dart / main_pro.dart).

enum Flavor { free, pro }

class FlavorConfig {
  final Flavor flavor;
  final String appName;
  final String bundleId;
  final bool showAds;
  final bool isPro;

  static FlavorConfig? _instance;

  FlavorConfig._({
    required this.flavor,
    required this.appName,
    required this.bundleId,
    required this.showAds,
    required this.isPro,
  });

  static void initialize({
    required Flavor flavor,
    required String appName,
    required String bundleId,
    required bool showAds,
    required bool isPro,
  }) {
    _instance = FlavorConfig._(
      flavor: flavor,
      appName: appName,
      bundleId: bundleId,
      showAds: showAds,
      isPro: isPro,
    );
  }

  static FlavorConfig get instance {
    assert(_instance != null, 'FlavorConfig no fue inicializado. Llamar initialize() en main.');
    return _instance!;
  }
}
