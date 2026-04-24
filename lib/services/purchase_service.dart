import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Servicio que gestiona la compra de la versión Pro desde la versión Free.
/// Usa in_app_purchase (Google Play Billing / App Store StoreKit).
class PurchaseService {
  static const String _productIdPro = 'asador_patagonico_pro';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Callbacks para notificar a la UI
  void Function()? onPurchaseSuccess;
  void Function(String error)? onPurchaseError;
  void Function()? onPurchasePending;

  /// Inicializar y escuchar el stream de compras.
  void initialize() {
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (error) => onPurchaseError?.call(error.toString()),
    );
  }

  void dispose() {
    _subscription?.cancel();
  }

  /// Inicia el flujo de compra de la versión Pro.
  Future<void> comprarPro() async {
    final disponible = await _iap.isAvailable();
    if (!disponible) {
      onPurchaseError?.call('Tienda no disponible. Verificá tu conexión.');
      return;
    }

    final response = await _iap.queryProductDetails({_productIdPro});
    if (response.error != null || response.productDetails.isEmpty) {
      onPurchaseError?.call('No se encontró el producto. Intentá más tarde.');
      return;
    }

    final producto = response.productDetails.first;
    final params = PurchaseParam(productDetails: producto);
    await _iap.buyNonConsumable(purchaseParam: params);
  }

  /// Restaurar compras previas (requerido por Apple).
  Future<void> restaurarCompras() async {
    await _iap.restorePurchases();
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.productID != _productIdPro) continue;

      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _iap.completePurchase(purchase);
          onPurchaseSuccess?.call();
          break;
        case PurchaseStatus.pending:
          onPurchasePending?.call();
          break;
        case PurchaseStatus.error:
          onPurchaseError?.call(purchase.error?.message ?? 'Error desconocido.');
          break;
        case PurchaseStatus.canceled:
          // No hacer nada, el usuario canceló.
          break;
      }
    }
  }
}
