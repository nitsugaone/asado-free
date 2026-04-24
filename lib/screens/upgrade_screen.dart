import 'package:flutter/material.dart';
import '../services/purchase_service.dart';
import '../app_state.dart';

/// Pantalla de upgrade Free → Pro.
/// Solo se muestra desde la versión Free.
class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  final _purchaseService = PurchaseService();
  bool _cargando = false;
  String? _mensaje;

  @override
  void initState() {
    super.initState();
    _purchaseService.initialize();
    _purchaseService.onPurchaseSuccess = _onExito;
    _purchaseService.onPurchaseError   = _onError;
    _purchaseService.onPurchasePending = _onPendiente;
  }

  @override
  void dispose() {
    _purchaseService.dispose();
    super.dispose();
  }

  Future<void> _onExito() async {
    setState(() { _cargando = false; _mensaje = null; });
    
    // Desbloquear versión Pro instantáneamente y guardar estado
    await AppState.instance.unlockPro();

    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF242424),
        title: const Text('¡Bienvenido a Pro!', style: TextStyle(color: Color(0xFFA78BFA))),
        content: const Text('¡Gracias por tu compra! Todas las funciones Pro ya están desbloqueadas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Color(0xFF7C3AED))),
          ),
        ],
      ),
    );
  }

  void _onError(String error) {
    setState(() { _cargando = false; _mensaje = error; });
  }

  void _onPendiente() {
    setState(() { _cargando = true; _mensaje = 'Procesando pago...'; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF242424),
        title: const Text('Pasar a Pro'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Badge Pro
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF7C3AED), width: 2),
              ),
              child: const Center(
                child: Text('PRO', style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFA78BFA),
                )),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Asador Patagónico Pro',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF60A5FA))),
            const SizedBox(height: 8),
            const Text('Una sola compra. Sin suscripción.',
                style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF))),
            const SizedBox(height: 32),

            // Comparativa
            _buildComparativa(),
            const SizedBox(height: 32),

            // Botón comprar
            if (_mensaje != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_mensaje!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _mensaje!.contains('Error') || _mensaje!.contains('no')
                          ? const Color(0xFFEF4444)
                          : const Color(0xFFF59E0B),
                    )),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _cargando ? null : () async {
                  setState(() { _cargando = true; _mensaje = null; });
                  await _purchaseService.comprarPro();
                },
                child: _cargando
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Comprar versión Pro', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),

            // Restaurar compra
            TextButton(
              onPressed: () => _purchaseService.restaurarCompras(),
              child: const Text('Restaurar compra anterior',
                  style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
            ),
            const SizedBox(height: 8),
            const Text(
              'El pago se procesa a través de Google Play / App Store.\n'
              'Compra única, sin renovación automática.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparativa() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF374151)),
      ),
      child: Column(
        children: [
          _filaComparativa('Calculadora completa',       free: true,  pro: true),
          _filaComparativa('Panel termodinámico',        free: true,  pro: true),
          _filaComparativa('Historial cifrado',          free: true,  pro: true),
          _filaComparativa('Sin publicidad',             free: false, pro: true),
          _filaComparativa('Acceso a futuras funciones', free: false, pro: true),
        ],
      ),
    );
  }

  Widget _filaComparativa(String feature, {required bool free, required bool pro}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(feature, style: const TextStyle(fontSize: 14))),
          SizedBox(width: 60, child: Center(child: _check(free))),
          SizedBox(width: 60, child: Center(child: _check(pro, isPro: true))),
        ],
      ),
    );
  }

  Widget _check(bool activo, {bool isPro = false}) {
    if (activo) {
      return Icon(Icons.check_circle,
          color: isPro ? const Color(0xFFA78BFA) : const Color(0xFF22C55E), size: 20);
    }
    return const Icon(Icons.remove_circle_outline, color: Color(0xFF4B5563), size: 20);
  }
}
