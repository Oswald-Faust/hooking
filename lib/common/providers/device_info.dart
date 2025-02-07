import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_user_agentx/flutter_user_agent.dart';

abstract class UserAgentRepo {
  // Future<void> setupUserAgent();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  Future<Map<String, dynamic>> getUserAgent();
}

class UserAgentRepoImpl extends UserAgentRepo {
  @override
  Future<Map<String, dynamic>> getUserAgent() async {
    var deviceData = <String, dynamic>{};
    try {
      // if (kIsWeb) {
      //   WebBrowserInfo browserInfo = await deviceInfo.webBrowserInfo;

      //   deviceData = browserInfo.toMap();
      // } else {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

        deviceData = _readAndroidBuildData(androidInfo);
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

        deviceData = _readIosDeviceInfo(iosInfo);
      }
      // }
      log(deviceData.toString());

      return deviceData;
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
      return deviceData;
    }
  }
}

Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
  return <String, dynamic>{
    'device_name': build.device,
    'model': '${build.model}, ${build.brand}',
    'systemVersion': build.version.release,
    'systemName': 'android',
  };
}

Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
  return <String, dynamic>{
    'device_name': data.name,
    'model': data.model,
    'systemName': data.systemName,
    'systemVersion': data.systemVersion,
  };
}
