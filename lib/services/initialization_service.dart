import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:uuid/uuid.dart';
import 'package:hookup4u2/services/notificatiion.dart';

class InitializationService {
  static final InitializationService _instance = InitializationService._internal();
  factory InitializationService() => _instance;
  InitializationService._internal();

  final Set<String?> shownNotificationIds = {};
  String? currentUuid;
  final _uuid = const Uuid();
  StreamSubscription<List<PurchaseDetails>>? purchaseSubscription;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint("💻 Initialisation web - certains services sont désactivés");
      return;
    }

    try {
      if (!_isInitialized) {
        await _initializeFirebase();
        await _initializeCallKit();
        await _initializeInAppPurchase();

        _isInitialized = true;
      }
    } catch (e) {
      debugPrint("Erreur d'initialisation: $e");
      rethrow;
    }
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
    await _configureFirebaseMessaging();
    currentUuid = _uuid.v4();
  }

  Future<void> _configureFirebaseMessaging() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  Future<void> _initializeCallKit() async {
    final params = CallKitParams(
      id: 'default_id',
      nameCaller: '',
      appName: 'Hookup4u',
      avatar: '',
      handle: '',
      type: 0,
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      extra: <String, dynamic>{
        'android': {
          'isCustomNotification': true,
          'isShowLogo': false,
          'ringtonePath': 'system_ringtone_default',
          'backgroundColor': '#0955fa',
          'backgroundUrl': 'assets/test.png',
          'actionColor': '#4CAF50',
        },
        'ios': {
          'iconName': 'CallKitLogo',
          'handleType': 'generic',
          'supportsVideo': true,
          'maximumCallGroups': 2,
          'maximumCallsPerCallGroup': 1,
          'audioSessionMode': 'default',
          'audioSessionActive': true,
          'audioSessionPreferredSampleRate': 44100.0,
          'audioSessionPreferredIOBufferDuration': 0.005,
          'supportsDTMF': true,
          'supportsHolding': true,
          'supportsGrouping': false,
          'supportsUngrouping': false,
          'ringtonePath': 'system_ringtone_default',
        },
      },
      headers: <String, dynamic>{},
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
    await FlutterCallkitIncoming.endAllCalls();
  }

  Future<void> _initializeInAppPurchase() async {
    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      print('In-app purchases not available');
      return;
    }

    const Set<String> _kIds = <String>{'premium_subscription'};
    final Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;
    purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      print('Purchase stream done');
    }, onError: (error) {
      print('Error listening to purchase updates: $error');
    });

    try {
      await InAppPurchase.instance.restorePurchases();
    } catch (e) {
      print('Error restoring purchases: $e');
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // Verify purchase here
        // Update user's purchase status in Firestore
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchaseDetails);
      }
    });
  }

  void dispose() {
    purchaseSubscription?.cancel();
  }
} 