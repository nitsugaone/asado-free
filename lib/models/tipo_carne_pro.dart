/// Modelo extendido de tipos de carne para la versión Pro.
/// Encapsula: pérdida por cocción, porción cocida deseada y descripción.
///
/// Fórmula base:
///   kg_a_comprar = (porcionCocidaKg × personas) × factorCoccion
///
/// factorCoccion = 1 / (1 - perdidaCoccion)
/// Ejemplo vacuno sin hueso: 1 / (1 - 0.30) = 1.428...

enum TipoCarneId {
  vacunoSinHueso,
  vacunoConHueso,
  cerdoCortes,
  lechonEntero,
  pollo,
}

class TipoCarneInfo {
  final TipoCarneId id;
  final String nombre;
  final String descripcion;
  final String emoji;
  final double perdidaCoccion;     // fracción: 0.30 = 30%
  final double porcionCocidaKg;    // kg de carne cocida deseada por persona

  const TipoCarneInfo({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.emoji,
    required this.perdidaCoccion,
    required this.porcionCocidaKg,
  });

  /// Factor por el que hay que multiplicar el peso cocido para obtener crudo.
  double get factorCoccion => 1.0 / (1.0 - perdidaCoccion);

  /// kg crudos necesarios por persona.
  double get kgCrudosPorPersona => porcionCocidaKg * factorCoccion;
}

/// Catálogo oficial de carnes — base 350g cocidos por persona.
class CatalogoCarne {
  static const double _porcionBase = 0.350; // kg cocidos

  static const Map<TipoCarneId, TipoCarneInfo> catalogo = {
    TipoCarneId.vacunoSinHueso: TipoCarneInfo(
      id: TipoCarneId.vacunoSinHueso,
      nombre: 'Vacuno sin hueso',
      descripcion: 'Vacío, matambre, cuadril',
      emoji: '🥩',
      perdidaCoccion: 0.30, // 30% → factor 1.43x
      porcionCocidaKg: _porcionBase,
    ),
    TipoCarneId.vacunoConHueso: TipoCarneInfo(
      id: TipoCarneId.vacunoConHueso,
      nombre: 'Vacuno con hueso',
      descripcion: 'Asado de tira, costillar',
      emoji: '🦴',
      perdidaCoccion: 0.35, // 35% → factor 1.54x
      porcionCocidaKg: _porcionBase,
    ),
    TipoCarneId.cerdoCortes: TipoCarneInfo(
      id: TipoCarneId.cerdoCortes,
      nombre: 'Cerdo (cortes)',
      descripcion: 'Bondiola, paleta, costillas',
      emoji: '🐷',
      perdidaCoccion: 0.25, // 25% → factor 1.33x
      porcionCocidaKg: _porcionBase,
    ),
    TipoCarneId.lechonEntero: TipoCarneInfo(
      id: TipoCarneId.lechonEntero,
      nombre: 'Lechón entero',
      descripcion: 'Animal completo (8–12 kg)',
      emoji: '🐖',
      perdidaCoccion: 0.40, // 40% → factor 1.67x (mayor pérdida por huesos+piel)
      porcionCocidaKg: _porcionBase,
    ),
    TipoCarneId.pollo: TipoCarneInfo(
      id: TipoCarneId.pollo,
      nombre: 'Pollo',
      descripcion: 'Pollo entero o en presas',
      emoji: '🍗',
      perdidaCoccion: 0.20, // 20% → factor 1.25x
      porcionCocidaKg: _porcionBase,
    ),
  };

  static TipoCarneInfo get(TipoCarneId id) => catalogo[id]!;
  static List<TipoCarneInfo> get todos => catalogo.values.toList();
}

/// Representa la selección de una carne con su porcentaje del total (0.0–1.0).
class SeleccionCarne {
  final TipoCarneId tipoId;
  final double porcentaje; // 0.0 a 1.0

  const SeleccionCarne({
    required this.tipoId,
    required this.porcentaje,
  });

  TipoCarneInfo get info => CatalogoCarne.get(tipoId);

  SeleccionCarne copyWith({TipoCarneId? tipoId, double? porcentaje}) {
    return SeleccionCarne(
      tipoId: tipoId ?? this.tipoId,
      porcentaje: porcentaje ?? this.porcentaje,
    );
  }
}

/// Resultado del desglose de una carne individual.
class ResultadoCarnePro {
  final TipoCarneInfo tipo;
  final double porcentaje;
  final double kgCrudos;

  const ResultadoCarnePro({
    required this.tipo,
    required this.porcentaje,
    required this.kgCrudos,
  });
}
