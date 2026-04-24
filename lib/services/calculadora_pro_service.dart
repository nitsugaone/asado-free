import '../models/tipo_carne_pro.dart';

/// Servicio de cálculo extendido para la versión Pro.
/// Soporta mezcla libre de carnes con porcentajes variables.
class CalculadoraProService {

  /// Valida que los porcentajes de la selección sumen exactamente 1.0 (±0.01).
  bool validarSeleccion(List<SeleccionCarne> seleccion) {
    if (seleccion.isEmpty) return false;
    final suma = seleccion.fold(0.0, (acc, s) => acc + s.porcentaje);
    return (suma - 1.0).abs() <= 0.01;
  }

  /// Calcula el desglose de kg crudos por cada tipo de carne seleccionada.
  ///
  /// Para cada carne:
  ///   personas_para_esta_carne = personas × porcentaje
  ///   kg_crudos = personas_para_esta_carne × kgCrudosPorPersona
  ///
  /// Retorna lista ordenada por porcentaje descendente.
  List<ResultadoCarnePro> calcularDesglose({
    required int personas,
    required List<SeleccionCarne> seleccion,
  }) {
    assert(validarSeleccion(seleccion), 'Los porcentajes deben sumar 1.0');

    final resultados = seleccion.map((s) {
      final info = s.info;
      final personasEsta = personas * s.porcentaje;
      final kgCrudos = personasEsta * info.kgCrudosPorPersona;
      return ResultadoCarnePro(
        tipo: info,
        porcentaje: s.porcentaje,
        kgCrudos: kgCrudos,
      );
    }).toList();

    resultados.sort((a, b) => b.porcentaje.compareTo(a.porcentaje));
    return resultados;
  }

  /// Suma total de kg crudos de todas las carnes.
  double totalKgCrudos({
    required int personas,
    required List<SeleccionCarne> seleccion,
  }) {
    return calcularDesglose(personas: personas, seleccion: seleccion)
        .fold(0.0, (acc, r) => acc + r.kgCrudos);
  }

  /// Normaliza automáticamente los porcentajes para que sumen 1.0.
  /// Útil cuando el usuario agrega/quita carnes o ajusta sliders.
  List<SeleccionCarne> normalizar(List<SeleccionCarne> seleccion) {
    if (seleccion.isEmpty) return seleccion;
    final suma = seleccion.fold(0.0, (acc, s) => acc + s.porcentaje);
    if (suma == 0) {
      // Distribuir equitativamente
      final igualitario = 1.0 / seleccion.length;
      return seleccion.map((s) => s.copyWith(porcentaje: igualitario)).toList();
    }
    return seleccion.map((s) => s.copyWith(porcentaje: s.porcentaje / suma)).toList();
  }

  /// Selección por defecto al abrir la pantalla Pro: 100% vacuno sin hueso.
  static List<SeleccionCarne> seleccionDefault() => const [
    SeleccionCarne(tipoId: TipoCarneId.vacunoSinHueso, porcentaje: 1.0),
  ];
}
