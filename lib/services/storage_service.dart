import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/calculo_asado.dart';

/// Servicio de almacenamiento cifrado con flutter_secure_storage.
/// En Android usa EncryptedSharedPreferences (AES-256 via Android Keystore).
/// En iOS usa Keychain.
class StorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const _keyUltimosParametros = 'ultimos_parametros';
  static const _keyHistorial = 'historial_calculos';
  static const _keyIsPro = 'is_pro_purchased';

  /// Guarda los últimos parámetros usados para restaurarlos al abrir la app.
  Future<void> guardarParametros(ParametrosAsado p) async {
    final json = jsonEncode({
      'personas': p.personas,
      'tipoCarne': p.tipoCarne.index,
      'escenario': p.escenario.index,
      'temperatura': p.temperatura,
      'viento': p.viento,
    });
    await _storage.write(key: _keyUltimosParametros, value: json);
  }

  /// Carga los últimos parámetros guardados. Retorna null si no hay nada.
  Future<ParametrosAsado?> cargarParametros() async {
    final raw = await _storage.read(key: _keyUltimosParametros);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return ParametrosAsado(
        personas: map['personas'] as int,
        tipoCarne: TipoCarne.values[map['tipoCarne'] as int],
        escenario: Escenario.values[map['escenario'] as int],
        temperatura: map['temperatura'] as int,
        viento: map['viento'] as int,
      );
    } catch (_) {
      return null;
    }
  }

  /// Agrega una entrada al historial (máx. 20 entradas).
  Future<void> agregarAlHistorial(ParametrosAsado p, DateTime fecha) async {
    final raw = await _storage.read(key: _keyHistorial) ?? '[]';
    final lista = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    lista.insert(0, {
      'personas': p.personas,
      'tipoCarne': p.tipoCarne.index,
      'escenario': p.escenario.index,
      'temperatura': p.temperatura,
      'viento': p.viento,
      'fecha': fecha.toIso8601String(),
    });
    // Máximo 20 entradas
    final recortada = lista.take(20).toList();
    await _storage.write(key: _keyHistorial, value: jsonEncode(recortada));
  }

  /// Limpia todos los datos almacenados.
  Future<void> limpiarTodo() async {
    await _storage.deleteAll();
  }

  /// Guarda el estado de si la versión Pro fue comprada.
  Future<void> setProStatus(bool isPro) async {
    await _storage.write(key: _keyIsPro, value: isPro.toString());
  }

  /// Carga el estado de si la versión Pro fue comprada.
  Future<bool> getProStatus() async {
    final raw = await _storage.read(key: _keyIsPro);
    return raw == 'true';
  }
}
