// // import 'package:firebase_admob/firebase_admob.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:swfteaproject/ui/widgets/generic/CountdownTimer.dart';
// // import 'package:swfteaproject/ui/widgets/generic/nicebuttom.dart';
// // import 'package:swfteaproject/utlis/AdsProvider.dart';
// // import 'package:swfteaproject/utlis/Replacer.dart';

// // class WatchAndEarn extends StatefulWidget {
// //   @override
// //   _WatchAndEarnState createState() => _WatchAndEarnState();
// // }

// // class _WatchAndEarnState extends State<WatchAndEarn> {
// //   bool timeCompleted = false;
// //   int timeLeft = 10;
// //   bool rewardLoaded = false;
// //   static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
// //     keywords: <String>['Book', 'Game'],
// //     nonPersonalizedAds: true,
// //   );
// //   RewardedVideoAd videoAd = RewardedVideoAd.instance;
// //   @override
// //   void initState() {
// //     super.initState();
// //     FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);
// //     videoAd.listener = (
// //       RewardedVideoAdEvent event, {
// //       String rewardType,
// //       int rewardAmount,
// //     }) {
// //       if (event == RewardedVideoAdEvent.rewarded) {
// //         setState(() {
// //           timeLeft = 30 * 60;
// //           timeCompleted = false;
// //         });
// //       }
// //       if (event == RewardedVideoAdEvent.loaded) {
// //         setState(() {
// //           rewardLoaded = true;
// //         });
// //       }
// //       if (event == RewardedVideoAdEvent.failedToLoad) {
// //         Get.snackbar('Error', "Failed to load ads.");
// //       }
// //     };

// //     videoAd.load(
// //       adUnitId: AdsProvider.rewardedAdUnitId,
// //       targetingInfo: MobileAdTargetingInfo(),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return
// // }
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:firebase_admob/firebase_admob.dart';
// import 'package:get/get.dart';
// import 'package:swfteaproject/ui/widgets/generic/CountdownTimer.dart';
// import 'package:swfteaproject/ui/widgets/generic/dialougeBox.dart';
// import 'package:swfteaproject/ui/widgets/generic/nicebuttom.dart';
// import 'package:swfteaproject/utlis/AdsProvider.dart';
// import 'package:swfteaproject/utlis/ApiProvider.dart';
// import 'package:swfteaproject/utlis/Replacer.dart';

// class WatchAndEarn extends StatefulWidget {
//   @override
//   _WatchAndEarnState createState() => _WatchAndEarnState();
// }

// class _WatchAndEarnState extends State<WatchAndEarn> {
//   static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
//     keywords: <String>['Insurance', 'Car', 'Beauty', 'Food', 'Book', 'Game'],
//     nonPersonalizedAds: true,
//     testDevices: ['FEB433ADC700CE81D33EA794A6A7C175'],
//   );
//   bool videoLoaded = false;
//   bool timeCompleted = false;
//   int timeLeft = 10000;
//   int rewardAmount = 0;
//   RewardedVideoAd videoAd = RewardedVideoAd.instance;

//   @override
//   void initState() {
//     super.initState();
//     FirebaseAdMob.instance.initialize(appId: AdsProvider.appId);
//     videoAd.listener = (
//       RewardedVideoAdEvent event, {
//       String rewardType,
//       int rewardAmount,
//     }) {
//       if (event == RewardedVideoAdEvent.rewarded) {
//         setState(() {
//           timeCompleted = false;
//           timeLeft = 30 * 60;
//           rewardAmount = rewardAmount + 50;
//         });
//         Get.dialog(
//           CustomDialog(
//             title: "Success",
//             child: Text(
//                 "Please verify your reward from account history. Wait next 30 minutes for more reward."),
//           ),
//         );
//         CallApi(context).getData('purchaseRewardCoins');
//       }
//       if (event == RewardedVideoAdEvent.loaded) {
//         setState(() {
//           videoLoaded = true;
//         });
//       }
//       if (event == RewardedVideoAdEvent.failedToLoad) {
//         setState(() {
//           timeCompleted = false;
//           timeLeft = 30 * 60;
//           rewardAmount = rewardAmount + 50;
//         });
//         Get.dialog(
//           CustomDialog(
//             title: "Success",
//             child: Text(
//                 "Please verify your reward from account history. Wait next 30 minutes for more reward."),
//           ),
//         );
//         CallApi(context).getData('purchaseRewardCoins');
//       }
//     };

//     new Future.delayed(Duration.zero, () async {
//       dynamic response =
//           await CallApi(context).getDataFuture('fetchRewardData');
//       var details = json.decode(response.body);
//       setState(() {
//         timeCompleted = details['canGetReward'];
//         timeLeft = details['nextRewardIn'];
//         rewardAmount = details['rewardAmount'];
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Watch and Earn"),
//       ),
//       body: Card(
//         child: ListView(
//           children: <Widget>[
//             Container(
//               color: Theme.of(context).primaryColor,
//               padding: const EdgeInsets.all(5),
//               child: Column(
//                 children: <Widget>[
//                   Text(
//                     "Next reward",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 25,
//                     ),
//                   ),
//                   CircleAvatar(
//                     radius: 50,
//                     backgroundColor: Colors.red,
//                     child: Text(
//                       rewardAmount.toString(),
//                       style: TextStyle(color: Colors.white, fontSize: 40),
//                     ),
//                   ),
//                   Text(
//                     timeCompleted ? "Time Completed" : "after",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 25,
//                     ),
//                   ),
//                   CountDownTimer(
//                     secondsRemaining: timeLeft,
//                     whenTimeExpires: () {
//                       print("TIME DONE");
//                       setState(() {
//                         timeCompleted = true;
//                       });
//                     },
//                     countDownTimerStyle: TextStyle(
//                       color: Theme.of(context).secondaryHeaderColor,
//                       fontSize: 30,
//                     ),
//                   )
//                 ],
//               ),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             timeCompleted
//                 ? NiceButton(
//                     bgColor: Theme.of(context).secondaryHeaderColor,
//                     child: SizedBox(
//                       height: 50,
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: <Widget>[
//                           Icon(
//                             Icons.monetization_on,
//                             color: Colors.white,
//                           ),
//                           Text(
//                             videoLoaded ? " Click to earn" : " Load video",
//                             style: TextStyle(
//                               color: Colors.white,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     onPressed: () async {
//                       if (videoLoaded) {
//                         videoAd.show();
//                       } else {
//                         videoAd
//                           ..load(
//                             adUnitId: AdsProvider.rewardedAdUnitId,
//                             targetingInfo: targetingInfo,
//                           );
//                       }
//                     },
//                   )
//                 : SizedBox(
//                     height: 0.1,
//                   ),
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(5),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     SecondaryTitle(
//                       title: "FAQ",
//                     ),
//                     Divider(),
//                     Text(
//                       "What is watch and earn?",
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       "Watch and earn is one of the basic features in our app, which helps users to earn free credits by watching video ads.",
//                       style: TextStyle(fontWeight: FontWeight.normal),
//                     ),
//                     Divider(
//                       height: 13,
//                     ),
//                     Text(
//                       "How does it work? ",
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       "When you click on the \"Watch and earn\" menu you will be directed to the watch and earn page where you will find \"Load Video\". After you click on \"Load Video\" you will find the \"watch to earn\" option on the screen; click on \"watch to earn\" then ads will appear on the screen. After you complete viewing ads you will get a reward as credits.",
//                       style: TextStyle(fontWeight: FontWeight.normal),
//                     ),
//                     Divider(
//                       height: 13,
//                     ),
//                     Text(
//                       "Where can I find rewarded credits?",
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       "After you claim the reward, it is added to your account automatically. You can find your reward amount in the \"My Account \" Section via Main Menu.",
//                       style: TextStyle(fontWeight: FontWeight.normal),
//                     ),
//                     Divider(
//                       height: 13,
//                     ),
//                     Text(
//                       "How many times can I earn?",
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       "You can earn unlimited times. But, you shouldn't re-login the app. Each video will appear in 30 minutes from the last time you have claimed a reward.",
//                       style: TextStyle(fontWeight: FontWeight.normal),
//                     ),
//                     Divider(
//                       height: 13,
//                     ),
//                     Text(
//                       "What if I re-login after logout? ",
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       "If you re-login after logout then your time will be reset to starter mode and you will just earn 100 credits. You have to repeat the same watch process to get extra credits.",
//                       style: TextStyle(fontWeight: FontWeight.normal),
//                     ),
//                     Divider(
//                       height: 13,
//                     ),
//                     Text(
//                       "Can I transfer or join games with the earned credits? ",
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       "Yes, you can join games and transfer earned credits because we don't have any such secondary credits menu while all your earned are added to be primary credits.",
//                       style: TextStyle(fontWeight: FontWeight.normal),
//                     ),
//                     Divider(
//                       height: 13,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
