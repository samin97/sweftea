import 'dart:io';

class AdsProvider {
  static String get appId {
    if (Platform.isAndroid) {
      return "ca-app-pub-5010188239748758~6259342979";
      // return FirebaseAdMob.testAppId;
    } else if (Platform.isIOS) {
      return "ca-app-pub-5010188239748758~6175582493";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-5010188239748758/4946261301";
      // return RewardedVideoAd.testAdUnitId;
    } else if (Platform.isIOS) {
      return "ca-app-pub-5010188239748758/4892815635";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}
