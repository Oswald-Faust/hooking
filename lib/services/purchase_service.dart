import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/foundation.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  
  PurchaseService._internal();

  bool _isInitialized = false;
  InAppPurchase? _iap;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final List<PurchaseDetails> _purchases = [];
  bool _isPurchased = false;

  bool get isPurchased => _isPurchased;
  List<PurchaseDetails> get purchases => _purchases;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      if (kIsWeb) {
        debugPrint('Les achats in-app ne sont pas disponibles sur le web');
        return;
      }

      _iap = InAppPurchase.instance;
      
      if (_iap != null) {
        final Stream<List<PurchaseDetails>> purchaseUpdated = _iap!.purchaseStream;
        _subscription = purchaseUpdated.listen(
          _onPurchaseUpdate,
          onDone: () {
            _subscription?.cancel();
          },
          onError: (error) {
            debugPrint('Erreur dans le stream des achats: $error');
            _subscription?.cancel();
          },
        );
        
        _isInitialized = true;
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation des achats: $e');
      _isInitialized = false;
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        _isPurchased = true;
        _purchases.add(purchaseDetails);
        
        if (purchaseDetails.pendingCompletePurchase) {
          try {
            await _iap?.completePurchase(purchaseDetails);
          } catch (e) {
            debugPrint('Erreur lors de la finalisation de l\'achat: $e');
          }
        }
      }
    });
  }

  Future<void> updateUserPurchaseStatus(String userId, bool isPurchased) async {
    try {
      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'isPremium': isPurchased,
        'purchaseDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour du statut d\'achat: $e');
      rethrow;
    }
  }

  Future<void> buyProduct(ProductDetails product) async {
    if (!_isInitialized || _iap == null) {
      throw Exception('Le service d\'achat n\'est pas initialisé');
    }

    try {
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      await _iap!.buyConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('Erreur lors de l\'achat: $e');
      rethrow;
    }
  }

  Future<List<ProductDetails>> getProducts(Set<String> ids) async {
    if (!_isInitialized || _iap == null) {
      throw Exception('Le service d\'achat n\'est pas initialisé');
    }

    try {
      final ProductDetailsResponse response = await _iap!.queryProductDetails(ids);
      return response.productDetails;
    } catch (e) {
      debugPrint('Erreur lors de la récupération des produits: $e');
      rethrow;
    }
  }

  void dispose() {
    _subscription?.cancel();
    _isInitialized = false;
  }
} 