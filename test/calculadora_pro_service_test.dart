import 'package:flutter_test/flutter_test.dart';
import 'package:asador_patagonico/models/tipo_carne_pro.dart';
import 'package:asador_patagonico/services/calculadora_pro_service.dart';

void main() {
  late CalculadoraProService sut;

  setUp(() => sut = CalculadoraProService());

  // ---------------------------------------------------------------------------
  // Factores de cocción del catálogo
  // ---------------------------------------------------------------------------
  group('Factores de cocción', () {
    test('Vacuno sin hueso: pérdida 30% → factor ~1.428', () {
      final info = CatalogoCarne.get(TipoCarneId.vacunoSinHueso);
      expect(info.factorCoccion, closeTo(1.4285, 0.001));
    });

    test('Vacuno con hueso: pérdida 35% → factor ~1.538', () {
      final info = CatalogoCarne.get(TipoCarneId.vacunoConHueso);
      expect(info.factorCoccion, closeTo(1.538, 0.001));
    });

    test('Cerdo cortes: pérdida 25% → factor ~1.333', () {
      final info = CatalogoCarne.get(TipoCarneId.cerdoCortes);
      expect(info.factorCoccion, closeTo(1.333, 0.001));
    });

    test('Lechón entero: pérdida 40% → factor ~1.667', () {
      final info = CatalogoCarne.get(TipoCarneId.lechonEntero);
      expect(info.factorCoccion, closeTo(1.666, 0.001));
    });

    test('Pollo: pérdida 20% → factor 1.25', () {
      final info = CatalogoCarne.get(TipoCarneId.pollo);
      expect(info.factorCoccion, closeTo(1.25, 0.001));
    });

    test('Pollo compra MENOS kg que vacuno con hueso para mismas personas', () {
      final pollo  = CatalogoCarne.get(TipoCarneId.pollo);
      final vacuno = CatalogoCarne.get(TipoCarneId.vacunoConHueso);
      expect(pollo.kgCrudosPorPersona, lessThan(vacuno.kgCrudosPorPersona));
    });
  });

  // ---------------------------------------------------------------------------
  // Validación de selección
  // ---------------------------------------------------------------------------
  group('Validación de selección', () {
    test('Selección con 100% vacuno es válida', () {
      final sel = [const SeleccionCarne(tipoId: TipoCarneId.vacunoSinHueso, porcentaje: 1.0)];
      expect(sut.validarSeleccion(sel), isTrue);
    });

    test('Mezcla 50/50 es válida', () {
      final sel = [
        const SeleccionCarne(tipoId: TipoCarneId.vacunoSinHueso, porcentaje: 0.5),
        const SeleccionCarne(tipoId: TipoCarneId.cerdoCortes,     porcentaje: 0.5),
      ];
      expect(sut.validarSeleccion(sel), isTrue);
    });

    test('Selección que no suma 1.0 es inválida', () {
      final sel = [
        const SeleccionCarne(tipoId: TipoCarneId.vacunoSinHueso, porcentaje: 0.6),
        const SeleccionCarne(tipoId: TipoCarneId.cerdoCortes,     porcentaje: 0.3),
        // 0.9 total → inválido
      ];
      expect(sut.validarSeleccion(sel), isFalse);
    });

    test('Selección vacía es inválida', () {
      expect(sut.validarSeleccion([]), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // Cálculo de kg
  // ---------------------------------------------------------------------------
  group('Cálculo de kg crudos', () {
    test('100% vacuno sin hueso, 10 personas → 350g × 10 × 1.428 ≈ 5.0 kg', () {
      final sel = [const SeleccionCarne(tipoId: TipoCarneId.vacunoSinHueso, porcentaje: 1.0)];
      final total = sut.totalKgCrudos(personas: 10, seleccion: sel);
      // 0.350 * (1/0.70) * 10 = 5.0
      expect(total, closeTo(5.0, 0.01));
    });

    test('100% pollo, 10 personas → 350g × 10 × 1.25 = 4.375 kg', () {
      final sel = [const SeleccionCarne(tipoId: TipoCarneId.pollo, porcentaje: 1.0)];
      final total = sut.totalKgCrudos(personas: 10, seleccion: sel);
      expect(total, closeTo(4.375, 0.01));
    });

    test('50% vaca / 50% cerdo, 20 personas: total correcto', () {
      final sel = [
        const SeleccionCarne(tipoId: TipoCarneId.vacunoSinHueso, porcentaje: 0.5),
        const SeleccionCarne(tipoId: TipoCarneId.cerdoCortes,     porcentaje: 0.5),
      ];
      final desglose = sut.calcularDesglose(personas: 20, seleccion: sel);
      final totalManual = desglose.fold(0.0, (acc, r) => acc + r.kgCrudos);
      final totalServicio = sut.totalKgCrudos(personas: 20, seleccion: sel);
      expect(totalServicio, closeTo(totalManual, 0.001));
    });

    test('Pollo necesita menos kg que lechón para mismas personas', () {
      final selPollo  = [const SeleccionCarne(tipoId: TipoCarneId.pollo,       porcentaje: 1.0)];
      final selLechon = [const SeleccionCarne(tipoId: TipoCarneId.lechonEntero, porcentaje: 1.0)];
      final kgPollo  = sut.totalKgCrudos(personas: 20, seleccion: selPollo);
      final kgLechon = sut.totalKgCrudos(personas: 20, seleccion: selLechon);
      expect(kgPollo, lessThan(kgLechon));
    });

    test('Mezcla de 5 carnes con porcentajes iguales (20% c/u)', () {
      final sel = [
        const SeleccionCarne(tipoId: TipoCarneId.vacunoSinHueso, porcentaje: 0.2),
        const SeleccionCarne(tipoId: TipoCarneId.vacunoConHueso, porcentaje: 0.2),
        const SeleccionCarne(tipoId: TipoCarneId.cerdoCortes,    porcentaje: 0.2),
        const SeleccionCarne(tipoId: TipoCarneId.lechonEntero,   porcentaje: 0.2),
        const SeleccionCarne(tipoId: TipoCarneId.pollo,          porcentaje: 0.2),
      ];
      expect(sut.validarSeleccion(sel), isTrue);
      expect(() => sut.calcularDesglose(personas: 50, seleccion: sel), returnsNormally);
    });
  });

  // ---------------------------------------------------------------------------
  // Normalización
  // ---------------------------------------------------------------------------
  group('Normalización de porcentajes', () {
    test('Normalizar [0.6, 0.6] → suma 1.0', () {
      final sel = [
        const SeleccionCarne(tipoId: TipoCarneId.vacunoSinHueso, porcentaje: 0.6),
        const SeleccionCarne(tipoId: TipoCarneId.cerdoCortes,     porcentaje: 0.6),
      ];
      final normalizada = sut.normalizar(sel);
      final suma = normalizada.fold(0.0, (acc, s) => acc + s.porcentaje);
      expect(suma, closeTo(1.0, 0.001));
    });

    test('Selección vacía se devuelve sin crash', () {
      expect(() => sut.normalizar([]), returnsNormally);
    });
  });

  // ---------------------------------------------------------------------------
  // Desglose ordenado
  // ---------------------------------------------------------------------------
  group('Desglose ordenado', () {
    test('Desglose se ordena de mayor a menor porcentaje', () {
      final sel = [
        const SeleccionCarne(tipoId: TipoCarneId.pollo,          porcentaje: 0.2),
        const SeleccionCarne(tipoId: TipoCarneId.vacunoSinHueso, porcentaje: 0.5),
        const SeleccionCarne(tipoId: TipoCarneId.cerdoCortes,    porcentaje: 0.3),
      ];
      final desglose = sut.calcularDesglose(personas: 30, seleccion: sel);
      for (int i = 0; i < desglose.length - 1; i++) {
        expect(desglose[i].porcentaje, greaterThanOrEqualTo(desglose[i + 1].porcentaje));
      }
    });
  });
}
