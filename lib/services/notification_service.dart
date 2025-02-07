import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final Set<String?> _shownNotificationIds = {};

  Future<void> initialize() async {
    await _configureNotifications();
    await _setupNotificationHandlers();
  }

  Future<void> _configureNotifications() async {
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  Future<void> _setupNotificationHandlers() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleInitialMessage(initialMessage);
    }
  }

  Future<void> updatePushToken(String userId) async {
    final token = await _messaging.getToken();
    if (token != null) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .update({'pushToken': token});
    }
  }

  Future<bool> checkCallState(String channelId) async {
    final callDoc = await FirebaseFirestore.instance
        .collection('calls')
        .doc(channelId)
        .get();
    return callDoc.exists && callDoc.data()?['status'] == 'ongoing';
  }

  Future<void> showCallkitIncoming({
    required String channelId,
    required String name,
    required String avatar,
    required String callTime,
    required String callType,
  }) async {
    final uuid = const Uuid().v4();
    final params = CallKitParams(
      id: uuid,
      nameCaller: name,
      appName: 'Hookup4u',
      avatar: avatar,
      handle: callType,
      type: 0,
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      extra: <String, dynamic>{
        'channel_id': channelId,
        'call_time': callTime,
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
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (_shownNotificationIds.contains(message.messageId)) return;
    _shownNotificationIds.add(message.messageId);

    if (message.data['type'] == 'Call') {
      _handleCallNotification(message);
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    if (_shownNotificationIds.contains(message.messageId)) return;
    _shownNotificationIds.add(message.messageId);

    if (message.data['type'] == 'Call') {
      _handleCallNotification(message);
    }
  }

  void _handleInitialMessage(RemoteMessage message) {
    if (_shownNotificationIds.contains(message.messageId)) return;
    _shownNotificationIds.add(message.messageId);

    if (message.data['type'] == 'Call') {
      _handleCallNotification(message);
    }
  }

  Future<void> _handleCallNotification(RemoteMessage message) async {
    final isCallActive = await checkCallState(message.data['channel_id']);
    if (isCallActive) {
      await showCallkitIncoming(
        channelId: message.data['channel_id'],
        name: message.data['senderName'],
        avatar: message.data['senderPicture'],
        callTime: message.data['time'],
        callType: message.notification?.body ?? 'Incoming Call',
      );
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService().initialize();
  NotificationService()._handleBackgroundMessage(message);
} 