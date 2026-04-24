import '../models/calculo_asado.dart';

/// Servicio puro con toda la lógica de cálculo.
/// Sin dependencias de UI — fácil de testear.
class CalculadoraService {
  ResultadoAsado calcular(ParametrosAsado p) {
    // --- Carne ---
    final double ratioCarne = p.tipoCarne == TipoCarne.conHueso ? 1.0 : 0.8;
    final double totalCarne = p.personas * ratioCarne;
    final int totalChorizos = (p.personas * 0.6).ceil();

    // --- Factor termodinámico ---
    double factorFuego = 1.0;
    String alertaMensaje = 'Condiciones óptimas en el interior.';
    AlertaNivel alertaNivel = AlertaNivel.optimo;

    if (p.escenario != Escenario.quincho) {
      final double base = p.escenario == Escenario.chulengo ? 1.1 : 1.2;
      double penFrio = p.temperatura < 15 ? (15 - p.temperatura) * 0.03 : 0.0;
      double penViento = (p.viento / 10) * 0.1;

      if (p.escenario == Escenario.chulengo) {
        penFrio *= 0.5;
        penViento *= 0.3;
      }

      factorFuego = base + penFrio + penViento;

      if (p.viento > 60 && p.escenario == Escenario.afuera) {
        alertaMensaje = '⚠️ ALERTA: Fuga convectiva extrema. Imposible mantener calor estable.';
        alertaNivel = AlertaNivel.critico;
      } else if (p.temperatura < 5) {
        alertaMensaje = '⚠️ ALERTA: Consumo alto por frío intenso.';
        alertaNivel = AlertaNivel.critico;
      } else if (factorFuego < 1.3) {
        alertaMensaje = 'Clima benévolo. Pérdida térmica mínima.';
        alertaNivel = AlertaNivel.leve;
      } else {
        alertaMensaje = 'Pérdida térmica activa por exposición.';
        alertaNivel = AlertaNivel.moderado;
      }
    }

    // --- Combustible: costo fijo + variable ---
    final double totalCarbon = (4.0 + (p.personas * 0.32)) * factorFuego;
    final double totalLena   = (3.0 + (p.personas * 0.18)) * factorFuego;
    final int bolsasCarbon   = (totalCarbon / 4).ceil();
    final int bolsasLena     = (totalLena / 3).ceil();

    return ResultadoAsado(
      totalCarne: totalCarne,
      totalChorizos: totalChorizos,
      totalCarbon: totalCarbon,
      bolsasCarbon: bolsasCarbon,
      totalLena: totalLena,
      bolsasLena: bolsasLena,
      factorFuego: factorFuego,
      alertaMensaje: alertaMensaje,
      alertaNivel: alertaNivel,
    );
  }
}
