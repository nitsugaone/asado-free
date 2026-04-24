import 'package:flutter_test/flutter_test.dart';
import 'package:asador_patagonico/models/calculo_asado.dart';
import 'package:asador_patagonico/services/calculadora_service.dart';

void main() {
  late CalculadoraService sut;

  setUp(() => sut = CalculadoraService());

  // ---------------------------------------------------------------------------
  // Carne
  // ---------------------------------------------------------------------------
  group('Cálculo de carne', () {
    test('Sin hueso: 0.8 kg por persona', () {
      final r = sut.calcular(const ParametrosAsado(
        personas: 10, tipoCarne: TipoCarne.sinHueso,
        escenario: Escenario.quincho, temperatura: 20, viento: 0,
      ));
      expect(r.totalCarne, closeTo(8.0, 0.01));
    });

    test('Con hueso: 1.0 kg por persona', () {
      final r = sut.calcular(const ParametrosAsado(
        personas: 10, tipoCarne: TipoCarne.conHueso,
        escenario: Escenario.quincho, temperatura: 20, viento: 0,
      ));
      expect(r.totalCarne, closeTo(10.0, 0.01));
    });

    test('Chorizos: ceil(0.6 * personas)', () {
      final r = sut.calcular(const ParametrosAsado(
        personas: 7, tipoCarne: TipoCarne.sinHueso,
        escenario: Escenario.quincho, temperatura: 20, viento: 0,
      ));
      // ceil(7 * 0.6) = ceil(4.2) = 5
      expect(r.totalChorizos, equals(5));
    });
  });

  // ---------------------------------------------------------------------------
  // Factor termodinámico
  // ---------------------------------------------------------------------------
  group('Factor termodinámico', () {
    test('Quincho: factor siempre 1.0', () {
      final r = sut.calcular(const ParametrosAsado(
        personas: 20, tipoCarne: TipoCarne.sinHueso,
        escenario: Escenario.quincho, temperatura: -5, viento: 100,
      ));
      expect(r.factorFuego, closeTo(1.0, 0.001));
    });

    test('Chulengo sin viento ni frío: base 1.1', () {
      final r = sut.calcular(const ParametrosAsado(
        personas: 20, tipoCarne: TipoCarne.sinHueso,
        escenario: Escenario.chulengo, temperatura: 20, viento: 0,
      ));
      expect(r.factorFuego, closeTo(1.1, 0.001));
    });

    test('Afuera sin viento ni frío: base 1.2', () {
      final r = sut.calcular(const ParametrosAsado(
        personas: 20, tipoCarne: TipoCarne.sinHueso,
        escenario: Escenario.afuera, temperatura: 20, viento: 0,
      ));
      expect(r.factorFuego, closeTo(1.2, 0.001));
    });

    test('Afuera con frío intenso (0°C): penalización activa', () {
      final r = sut.calcular(const ParametrosAsado(
        personas: 20, tipoCarne: TipoCarne.sinHueso,
        escenario: Escenario.afuera, temperatura: 0, viento: 0,
      ));
      // base 1.2 + penFrio (15-0)*0.03 = 0.45
      expect(r.factorFuego, closeTo(1.65, 0.001));
    });

    test('Afuera con viento patagónico (80 km/h): alerta crítica', () {
      final r = sut.calcular(const ParametrosAsado(
        personas: 20, tipoCarne: TipoCarne.sinHueso,
        escenario: Escenario.afuera, temperatura: 15, viento: 80,
      ));
      expect(r.alertaNivel, equals(AlertaNivel.critico));
    });

    test('Temperatura < 5°C activa alerta crítica', () {
      final r = sut.calcular(const ParametrosAsado(
        personas: 20, tipoCarne: TipoCarne.sinHueso,
        escenario: Escenario.afuera, temperatura: 3, viento: 10,
      ));
      expect(r.alertaNivel, equals(AlertaNivel.critico));
    });

    test('Chulengo atenúa penalizaciones', () {
      final rChulengo = sut.calcular(const ParametrosAsado(
        personas: 20, tipoCarne: TipoCarne.sinHueso,
        escenario: Escenario.chulengo, temperatura: 0, viento: 40,
      ));
      final rAfuera = sut.calcular(const ParametrosAsado(
        personas: 20, tipoCarne: TipoCarne.sinHueso,
        escenario: Escenario.afuera, temperatura: 0, viento: 40,
      ));
      expect(rChulengo.factorFuego, lessThan(rAfuera.factorFuego));
    });
  });

  // ---------------------------------------------------------------------------
  // Combustible
  // ---------------------------------------------------------------------------
  group('Cálculo de combustible', () {
    test('Quincho 50 personas: carbón = (4 + 50*0.32)*1.0 = 20.0 kg', () {
      final r = sut.calcular(const ParametrosAsado(
        personas: 50, tipoCarne: TipoCarne.sinHueso,
        escenario: Escenario.quincho, temperatura: 20, viento: 0,
      ));
      expect(r.totalCarbon, closeTo(20.0, 0.01));
    });

    test('Quincho 50 personas: leña = (3 + 50*0.18)*1.0 = 12.0 kg', () {
      final r = sut.calcular(const ParametrosAsado(
        personas: 50, tipoCarne: TipoCarne.sinHueso,
        escenario: Escenario.quincho, temperatura: 20, viento: 0,
      ));
      expect(r.totalLena, closeTo(12.0, 0.01));
    });

    test('Bolsas de carbón: ceil(totalCarbon / 4)', () {
      final r = sut.calcular(const ParametrosAsado(
        personas: 50, tipoCarne: TipoCarne.sinHueso,
        escenario: Escenario.quincho, temperatura: 20, viento: 0,
      ));
      // 20.0 / 4 = 5 exactas
      expect(r.bolsasCarbon, equals(5));
    });

    test('totalFuego = totalCarbon + totalLena', () {
      final r = sut.calcular(const ParametrosAsado(
        personas: 30, tipoCarne: TipoCarne.conHueso,
        escenario: Escenario.chulengo, temperatura: 10, viento: 20,
      ));
      expect(r.totalFuego, closeTo(r.totalCarbon + r.totalLena, 0.001));
    });
  });

  // ---------------------------------------------------------------------------
  // Edge cases
  // ---------------------------------------------------------------------------
  group('Edge cases', () {
    test('1 persona sin hueso quincho', () {
      final r = sut.calcular(const ParametrosAsado(
        personas: 1, tipoCarne: TipoCarne.sinHueso,
        escenario: Escenario.quincho, temperatura: 20, viento: 0,
      ));
      expect(r.totalCarne, closeTo(0.8, 0.01));
      expect(r.totalChorizos, equals(1)); // ceil(0.6) = 1
    });

    test('150 personas (máximo): sin overflow', () {
      expect(
        () => sut.calcular(const ParametrosAsado(
          personas: 150, tipoCarne: TipoCarne.conHueso,
          escenario: Escenario.afuera, temperatura: -10, viento: 120,
        )),
        returnsNormally,
      );
    });
  });
}
