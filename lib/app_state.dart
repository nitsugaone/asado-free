import 'package:flutter/foundation.dart';
import 'services/storage_service.dart';
import 'flavors/flavor_config.dart';

/// Estado global de la aplicación.
/// Maneja reactivamente si el usuario tiene acceso a la versión Pro.
class AppState {
  static final AppState instance = AppState._();
  
  AppState._();

  final _storage = StorageService();

  /// Notifier para que la UI reaccione cuando cambie el estado Pro.
  final ValueNotifier<bool> isProNotifier = ValueNotifier<bool>(false);

  bool get isPro => isProNotifier.value;

  /// Inicializa el estado leyendo de almacenamiento seguro.
  /// Si ya se había comprado la versión Pro, o si el flavor base es Pro, desbloquea.
  Future<void> initialize() async {
    final isBasePro = FlavorConfig.instance.flavor == Flavor.pro;
    
    if (isBasePro) {
      _setProState(true);
    } else {
      final purchased = await _storage.getProStatus();
      _setProState(purchased);
    }
  }

  /// Desbloquea la versión Pro y persiste el estado.
  Future<void> unlockPro() async {
    _setProState(true);
    await _storage.setProStatus(true);
  }

  void _setProState(bool pro) {
    isProNotifier.value = pro;
    
    // Si queremos que también se refleje en FlavorConfig para componentes legacy
    // que aún lean de FlavorConfig.instance.isPro, podríamos hacerlo si isPro fuera mutable.
    // Como es final en la implementación actual, los widgets deberán leer de AppState.
  }
}
