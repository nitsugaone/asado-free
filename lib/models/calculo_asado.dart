/// Modelo que encapsula todos los parámetros y resultados del cálculo.

enum TipoCarne { sinHueso, conHueso }
enum Escenario { quincho, chulengo, afuera }

class ParametrosAsado {
  final int personas;
  final TipoCarne tipoCarne;
  final Escenario escenario;
  final int temperatura; // °C, relevante si escenario != quincho
  final int viento;      // km/h, relevante si escenario != quincho

  const ParametrosAsado({
    required this.personas,
    required this.tipoCarne,
    required this.escenario,
    required this.temperatura,
    required this.viento,
  });

  ParametrosAsado copyWith({
    int? personas,
    TipoCarne? tipoCarne,
    Escenario? escenario,
    int? temperatura,
    int? viento,
  }) {
    return ParametrosAsado(
      personas: personas ?? this.personas,
      tipoCarne: tipoCarne ?? this.tipoCarne,
      escenario: escenario ?? this.escenario,
      temperatura: temperatura ?? this.temperatura,
      viento: viento ?? this.viento,
    );
  }
}

class ResultadoAsado {
  final double totalCarne;
  final int totalChorizos;
  final double totalCarbon;
  final int bolsasCarbon;
  final double totalLena;
  final int bolsasLena;
  final double factorFuego;
  final String alertaMensaje;
  final AlertaNivel alertaNivel;

  const ResultadoAsado({
    required this.totalCarne,
    required this.totalChorizos,
    required this.totalCarbon,
    required this.bolsasCarbon,
    required this.totalLena,
    required this.bolsasLena,
    required this.factorFuego,
    required this.alertaMensaje,
    required this.alertaNivel,
  });

  double get totalFuego => totalCarbon + totalLena;
}

enum AlertaNivel { optimo, leve, moderado, critico }
