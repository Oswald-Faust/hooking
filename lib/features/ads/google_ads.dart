import 'dart:io';

import '../../config/app_config.dart';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return bannerAdUnitIdAndriod;
    } else if (Platform.isIOS) {
      return bannerAdUnitIdIOS;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return interstitialAdUnitIdAndriod;
    } else if (Platform.isIOS) {
      return interstitialAdUnitIdIOS;
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return rewardedAdUnitIdAndriod;
    } else if (Platform.isIOS) {
      return rewardedAdUnitIdIOS;
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
}
