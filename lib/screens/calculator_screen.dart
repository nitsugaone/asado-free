import 'package:flutter/material.dart';
import '../models/calculo_asado.dart';
import '../services/calculadora_service.dart';
import '../services/storage_service.dart';
import '../flavors/flavor_config.dart';
import '../widgets/banner_ad_widget.dart';
import '../models/tipo_carne_pro.dart';
import '../services/calculadora_pro_service.dart';
import '../widgets/selector_carnes_pro.dart';
import '../app_state.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _calculadora = CalculadoraService();
  final _storage = StorageService();

  late ParametrosAsado _params;
  late ResultadoAsado _resultado;

  // Estado Pro: mezcla de carnes
  List<SeleccionCarne> _seleccionCarnes = CalculadoraProService.seleccionDefault();
  double _totalKgCarnesPro = 0.0;
  final _calculadoraPro = CalculadoraProService();

  @override
  void initState() {
    super.initState();
    _params = const ParametrosAsado(
      personas: 50,
      tipoCarne: TipoCarne.sinHueso,
      escenario: Escenario.afuera,
      temperatura: 10,
      viento: 30,
    );
    _resultado = _calculadora.calcular(_params);
    _cargarUltimosParametros();
  }

  Future<void> _cargarUltimosParametros() async {
    final guardados = await _storage.cargarParametros();
    if (guardados != null) {
      setState(() {
        _params = guardados;
        _resultado = _calculadora.calcular(_params);
      });
    }
  }

  void _actualizar(ParametrosAsado nuevos) {
    setState(() {
      _params = nuevos;
      _resultado = _calculadora.calcular(_params);
      if (AppState.instance.isPro) {
        _totalKgCarnesPro = _calculadoraPro.totalKgCrudos(
          personas: _params.personas,
          seleccion: _seleccionCarnes,
        );
      }
    });
    _storage.guardarParametros(_params);
  }

  void _onSeleccionCarnesChanged(List<SeleccionCarne> nueva) {
    setState(() {
      _seleccionCarnes = nueva;
      _totalKgCarnesPro = _calculadoraPro.totalKgCrudos(
        personas: _params.personas,
        seleccion: _seleccionCarnes,
      );
    });
  }

  Color _alertaColor() {
    switch (_resultado.alertaNivel) {
      case AlertaNivel.critico:  return const Color(0xFFEF4444); // red
      case AlertaNivel.moderado: return const Color(0xFFF59E0B); // yellow
      case AlertaNivel.leve:     return const Color(0xFF22C55E); // green
      case AlertaNivel.optimo:   return const Color(0xFF9CA3AF); // gray
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppState.instance.isProNotifier,
      builder: (context, isPro, child) {
        final mostrarPanelPro = _params.escenario != Escenario.quincho;

        return Scaffold(
          bottomNavigationBar: const BannerAdWidget(),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // --- Header ---
                  _buildHeader(isPro, mostrarPanelPro),
                  const SizedBox(height: 16),

                  // --- Resumen rápido ---
                  _buildResumen(),
                  const SizedBox(height: 16),

                  // --- Título ---
                  Text(
                    'Lista de Compras para ${_params.personas} personas',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),

                  // --- Items ---
                  _buildItems(),
                  const SizedBox(height: 16),

                  // --- Controles ---
                  _buildControles(),
                  const SizedBox(height: 12),

                  // --- Panel Pro termodinámico ---
                  if (mostrarPanelPro) _buildPanelTermodinamico(),
                  // Panel de mezcla de carnes (solo Pro)
                  if (isPro) ...[
                    const SizedBox(height: 12),
                    SelectorCarnesPro(
                      seleccionInicial: _seleccionCarnes,
                      personas: _params.personas,
                      onChanged: _onSeleccionCarnesChanged,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isPro, bool mostrarPanelPro) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF374151)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      FlavorConfig.instance.appName,
                      style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold,
                        color: Color(0xFF60A5FA),
                      ),
                    ),
                    if (isPro) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('PRO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _resultado.alertaMensaje,
                  style: TextStyle(fontSize: 12, color: _alertaColor()),
                ),
                if (mostrarPanelPro)
                  Text(
                    'Multiplicador Térmico: ${_resultado.factorFuego.toStringAsFixed(2)}x',
                    style: const TextStyle(fontSize: 11, color: Color(0xFFA78BFA), fontFamily: 'monospace'),
                  ),
              ],
            ),
          ),
          // Botón upgrade (solo versión Free)
          if (!isPro)
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed('/upgrade'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.5)),
                ),
                child: const Column(
                  children: [
                    Text('PRO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFA78BFA))),
                    Text('Obtener', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResumen() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF374151)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _resumenItem('CARNE TOTAL', '${_resultado.totalCarne.toStringAsFixed(1)} kg'),
          _resumenItem('CHORIZOS', '${_resultado.totalChorizos} uds'),
          _resumenItem('FUEGO', '${_resultado.totalFuego.toStringAsFixed(1)} kg'),
        ],
      ),
    );
  }

  Widget _resumenItem(String label, String valor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF))),
        const SizedBox(height: 4),
        Text(valor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildItems() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _itemRow('🥩', 'Carne Principal',
              _params.tipoCarne == TipoCarne.conHueso ? 'Con Hueso (Asado/Costillar)' : 'Sin Hueso (Vacío/Matambre)',
              '${_resultado.totalCarne.toStringAsFixed(1)} KG', const Color(0xFFEF4444), true),
          _itemRow('🌭', 'Chorizos', 'Entrada clásica',
              '${_resultado.totalChorizos} UDS', const Color(0xFFF59E0B), true),
          _itemRow('🔥', 'Carbón',
              'Total: ${_resultado.totalCarbon.toStringAsFixed(1)}kg (4kg c/u)',
              '${_resultado.bolsasCarbon} BOLSAS', const Color(0xFF3B82F6), true),
          _itemRow('🪵', 'Leña',
              'Total: ${_resultado.totalLena.toStringAsFixed(1)}kg (3kg c/u)',
              '${_resultado.bolsasLena} BOLSAS', const Color(0xFF22C55E), false),
        ],
      ),
    );
  }

  Widget _itemRow(String emoji, String titulo, String subtitulo, String valor, Color color, bool divider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(subtitulo, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: color),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(valor, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ),
        if (divider) Divider(height: 1, color: Colors.grey[800]),
      ],
    );
  }

  Widget _buildControles() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF374151)),
      ),
      child: Column(
        children: [
          // Personas
          Row(
            children: [
              const SizedBox(width: 70, child: Text('Personas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
              Expanded(
                child: Slider(
                  value: _params.personas.toDouble(),
                  min: 1, max: 150, divisions: 149,
                  activeColor: const Color(0xFF3B82F6),
                  onChanged: (v) => _actualizar(_params.copyWith(personas: v.round())),
                ),
              ),
              SizedBox(
                width: 40,
                child: Text('${_params.personas}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Tipo de carne
          Row(
            children: [
              const SizedBox(width: 70, child: Text('Carne', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
              Expanded(
                child: DropdownButton<TipoCarne>(
                  value: _params.tipoCarne,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF2D2D2D),
                  items: const [
                    DropdownMenuItem(value: TipoCarne.sinHueso, child: Text('Sin Hueso (Vacío/Matambre)', style: TextStyle(fontSize: 13))),
                    DropdownMenuItem(value: TipoCarne.conHueso, child: Text('Con Hueso (Asado/Costillar)', style: TextStyle(fontSize: 13))),
                  ],
                  onChanged: (v) { if (v != null) _actualizar(_params.copyWith(tipoCarne: v)); },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Escenario
          Row(
            children: [
              const SizedBox(width: 70, child: Text('Escenario', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
              Expanded(
                child: DropdownButton<Escenario>(
                  value: _params.escenario,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF2D2D2D),
                  items: const [
                    DropdownMenuItem(value: Escenario.quincho,  child: Text('Quincho (Interior)', style: TextStyle(fontSize: 13))),
                    DropdownMenuItem(value: Escenario.chulengo, child: Text('Chulengo (Exterior protegido)', style: TextStyle(fontSize: 13))),
                    DropdownMenuItem(value: Escenario.afuera,   child: Text('Afuera (Intemperie)', style: TextStyle(fontSize: 13))),
                  ],
                  onChanged: (v) { if (v != null) _actualizar(_params.copyWith(escenario: v)); },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPanelTermodinamico() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1033),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AJUSTE TERMODINÁMICO LOCAL',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                  color: Color(0xFFA78BFA), letterSpacing: 1.2)),
          const SizedBox(height: 12),
          // Temperatura
          Row(
            children: [
              const SizedBox(width: 80, child: Text('Temp. (°C)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
              Expanded(
                child: Slider(
                  value: _params.temperatura.toDouble(),
                  min: -10, max: 40, divisions: 50,
                  activeColor: const Color(0xFF7C3AED),
                  onChanged: (v) => _actualizar(_params.copyWith(temperatura: v.round())),
                ),
              ),
              SizedBox(width: 44, child: Text('${_params.temperatura}°C', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12))),
            ],
          ),
          // Viento
          Row(
            children: [
              const SizedBox(width: 80, child: Text('Viento\n(km/h)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
              Expanded(
                child: Slider(
                  value: _params.viento.toDouble(),
                  min: 0, max: 120, divisions: 120,
                  activeColor: const Color(0xFF7C3AED),
                  onChanged: (v) => _actualizar(_params.copyWith(viento: v.round())),
                ),
              ),
              SizedBox(width: 44, child: Text('${_params.viento} km/h', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12))),
            ],
          ),
        ],
      ),
    );
  }
}
