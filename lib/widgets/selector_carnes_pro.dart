import 'package:flutter/material.dart';
import '../models/tipo_carne_pro.dart';
import '../services/calculadora_pro_service.dart';

/// Widget Pro: selector de mezcla de carnes con sliders de porcentaje.
/// Solo se instancia desde la versión Pro (FlavorConfig.isPro == true).
class SelectorCarnesPro extends StatefulWidget {
  final List<SeleccionCarne> seleccionInicial;
  final int personas;
  final void Function(List<SeleccionCarne> seleccion) onChanged;

  const SelectorCarnesPro({
    super.key,
    required this.seleccionInicial,
    required this.personas,
    required this.onChanged,
  });

  @override
  State<SelectorCarnesPro> createState() => _SelectorCarnesProState();
}

class _SelectorCarnesProState extends State<SelectorCarnesPro> {
  final _service = CalculadoraProService();
  late List<SeleccionCarne> _seleccion;

  @override
  void initState() {
    super.initState();
    _seleccion = List.from(widget.seleccionInicial);
  }

  void _agregarCarne(TipoCarneId id) {
    if (_seleccion.any((s) => s.tipoId == id)) return;
    _seleccion.add(SeleccionCarne(tipoId: id, porcentaje: 0.0));
    _normalizar();
  }

  void _quitarCarne(TipoCarneId id) {
    if (_seleccion.length <= 1) return; // mínimo una
    _seleccion.removeWhere((s) => s.tipoId == id);
    _normalizar();
  }

  /// Cuando el usuario mueve el slider de una carne, ajustamos el resto
  /// proporcionalmente para mantener la suma en 1.0.
  void _ajustarPorcentaje(TipoCarneId id, double nuevoPct) {
    final idx = _seleccion.indexWhere((s) => s.tipoId == id);
    if (idx < 0) return;

    final clamp = nuevoPct.clamp(0.05, 1.0); // mínimo 5%
    final delta = clamp - _seleccion[idx].porcentaje;
    if (delta == 0) return;

    // Distribuir el delta entre las otras carnes proporcionalmente
    final otros = _seleccion.where((s) => s.tipoId != id).toList();
    final sumaOtros = otros.fold(0.0, (acc, s) => acc + s.porcentaje);

    _seleccion[idx] = _seleccion[idx].copyWith(porcentaje: clamp);

    if (sumaOtros > 0) {
      for (int i = 0; i < _seleccion.length; i++) {
        if (_seleccion[i].tipoId == id) continue;
        final proporcion = _seleccion[i].porcentaje / sumaOtros;
        final nuevo = (_seleccion[i].porcentaje - delta * proporcion).clamp(0.0, 1.0);
        _seleccion[i] = _seleccion[i].copyWith(porcentaje: nuevo);
      }
    }

    _normalizar();
  }

  void _normalizar() {
    setState(() {
      _seleccion = _service.normalizar(_seleccion);
    });
    widget.onChanged(_seleccion);
  }

  @override
  Widget build(BuildContext context) {
    final desglose = _service.calcularDesglose(
      personas: widget.personas,
      seleccion: _seleccion,
    );
    final totalKg = desglose.fold(0.0, (acc, r) => acc + r.kgCrudos);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1033),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MEZCLA DE CARNES PRO',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                            color: Color(0xFFA78BFA), letterSpacing: 1.2)),
                    SizedBox(height: 2),
                    Text('350g cocidos por persona · pérdida real por tipo',
                        style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                  ],
                ),
              ),
              // Total kg
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${totalKg.toStringAsFixed(1)} KG total',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                      color: Color(0xFFA78BFA)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sliders de carnes seleccionadas
          ..._seleccion.map((s) => _buildSliderCarne(s, desglose)),
          const SizedBox(height: 12),

          // Botón agregar carne
          _buildAgregarCarne(),
        ],
      ),
    );
  }

  Widget _buildSliderCarne(SeleccionCarne s, List<ResultadoCarnePro> desglose) {
    final info = s.info;
    final resultado = desglose.firstWhere((r) => r.tipo.id == s.tipoId,
        orElse: () => ResultadoCarnePro(tipo: info, porcentaje: 0, kgCrudos: 0));

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(info.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(info.nombre,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    Text(
                      '${info.descripcion} · pérdida ${(info.perdidaCoccion * 100).round()}% · '
                      '${resultado.kgCrudos.toStringAsFixed(1)}kg crudos',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
              // Porcentaje
              SizedBox(
                width: 42,
                child: Text(
                  '${(s.porcentaje * 100).round()}%',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                      color: Color(0xFFA78BFA)),
                ),
              ),
              // Botón quitar
              if (_seleccion.length > 1)
                GestureDetector(
                  onTap: () => _quitarCarne(s.tipoId),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.remove_circle_outline,
                        size: 18, color: Color(0xFFEF4444)),
                  ),
                ),
            ],
          ),
          Slider(
            value: s.porcentaje,
            min: 0.05,
            max: 1.0,
            divisions: 19,
            activeColor: const Color(0xFF7C3AED),
            inactiveColor: const Color(0xFF374151),
            onChanged: (v) => _ajustarPorcentaje(s.tipoId, v),
          ),
        ],
      ),
    );
  }

  Widget _buildAgregarCarne() {
    final disponibles = CatalogoCarne.todos
        .where((c) => !_seleccion.any((s) => s.tipoId == c.id))
        .toList();

    if (disponibles.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        const Text('Agregar: ',
            style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
        ...disponibles.map((c) => GestureDetector(
          onTap: () => _agregarCarne(c.id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF242424),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 12, color: const Color(0xFFA78BFA)),
                const SizedBox(width: 4),
                Text('${c.emoji} ${c.nombre}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFFA78BFA))),
              ],
            ),
          ),
        )),
      ],
    );
  }
}
