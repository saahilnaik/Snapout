import 'package:in_app_purchase/in_app_purchase.dart';

/// Thin wrapper over [InAppPurchase] for the single non-consumable Pro unlock.
///
/// Until the `snapout_pro` product exists in Play Console and the app is
/// installed from a Play track, [available]/[proProduct] return false/null —
/// the UI falls back to a default price label and the debug unlock.
class PurchaseService {
  static const productIdAnnual = 'snapout_pro_annual';
  static const productIdLifetime = 'snapout_pro_lifetime';

  final InAppPurchase _iap = InAppPurchase.instance;

  Stream<List<PurchaseDetails>> get purchaseStream => _iap.purchaseStream;

  Future<bool> available() => _iap.isAvailable();

  Future<List<ProductDetails>> queryProducts() async {
    final resp = await _iap.queryProductDetails({productIdAnnual, productIdLifetime});
    return resp.productDetails;
  }

  Future<void> buyNonConsumable(ProductDetails product) =>
      _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product));

  Future<void> buySubscription(ProductDetails product) =>
      _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product));

  Future<void> restore() => _iap.restorePurchases();

  Future<void> complete(PurchaseDetails purchase) => _iap.completePurchase(purchase);
}
