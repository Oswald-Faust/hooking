class CallKitParams {
  final String id;
  final String nameCaller;
  final String appName;
  final String avatar;
  final String handle;
  final int type;
  final int duration;
  final String textAccept;
  final String textDecline;
  final String textMissedCall;
  final String textCallback;
  final Map<String, dynamic> extra;
  final Map<String, dynamic> headers;
  final AndroidParams android;
  final IOSParams ios;

  const CallKitParams({
    required this.id,
    required this.nameCaller,
    required this.appName,
    required this.avatar,
    required this.handle,
    required this.type,
    required this.duration,
    required this.textAccept,
    required this.textDecline,
    required this.textMissedCall,
    required this.textCallback,
    required this.extra,
    required this.headers,
    required this.android,
    required this.ios,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nameCaller': nameCaller,
      'appName': appName,
      'avatar': avatar,
      'handle': handle,
      'type': type,
      'duration': duration,
      'textAccept': textAccept,
      'textDecline': textDecline,
      'textMissedCall': textMissedCall,
      'textCallback': textCallback,
      'extra': extra,
      'headers': headers,
      'android': android.toMap(),
      'ios': ios.toMap(),
    };
  }
}

class AndroidParams {
  final bool isCustomNotification;
  final bool isShowLogo;
  final bool isShowCallback;
  final String ringtonePath;
  final String backgroundColor;
  final String backgroundUrl;
  final String actionColor;

  const AndroidParams({
    required this.isCustomNotification,
    required this.isShowLogo,
    required this.isShowCallback,
    required this.ringtonePath,
    required this.backgroundColor,
    required this.backgroundUrl,
    required this.actionColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'isCustomNotification': isCustomNotification,
      'isShowLogo': isShowLogo,
      'isShowCallback': isShowCallback,
      'ringtonePath': ringtonePath,
      'backgroundColor': backgroundColor,
      'backgroundUrl': backgroundUrl,
      'actionColor': actionColor,
    };
  }
}

class IOSParams {
  final String iconName;
  final String handleType;
  final bool supportsVideo;
  final int maximumCallGroups;
  final int maximumCallsPerCallGroup;
  final String audioSessionMode;
  final bool audioSessionActive;
  final double audioSessionPreferredSampleRate;
  final double audioSessionPreferredIOBufferDuration;
  final bool supportsDTMF;
  final bool supportsHolding;
  final bool supportsGrouping;
  final bool supportsUngrouping;
  final String ringtonePath;

  const IOSParams({
    required this.iconName,
    required this.handleType,
    required this.supportsVideo,
    required this.maximumCallGroups,
    required this.maximumCallsPerCallGroup,
    required this.audioSessionMode,
    required this.audioSessionActive,
    required this.audioSessionPreferredSampleRate,
    required this.audioSessionPreferredIOBufferDuration,
    required this.supportsDTMF,
    required this.supportsHolding,
    required this.supportsGrouping,
    required this.supportsUngrouping,
    required this.ringtonePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'iconName': iconName,
      'handleType': handleType,
      'supportsVideo': supportsVideo,
      'maximumCallGroups': maximumCallGroups,
      'maximumCallsPerCallGroup': maximumCallsPerCallGroup,
      'audioSessionMode': audioSessionMode,
      'audioSessionActive': audioSessionActive,
      'audioSessionPreferredSampleRate': audioSessionPreferredSampleRate,
      'audioSessionPreferredIOBufferDuration': audioSessionPreferredIOBufferDuration,
      'supportsDTMF': supportsDTMF,
      'supportsHolding': supportsHolding,
      'supportsGrouping': supportsGrouping,
      'supportsUngrouping': supportsUngrouping,
      'ringtonePath': ringtonePath,
    };
  }
} 