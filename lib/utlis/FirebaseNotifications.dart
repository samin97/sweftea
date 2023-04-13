// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:overlay_support/overlay_support.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:swfteaproject/ui/mainscreen.dart';

// class FirebaseNotifications {
//   FirebaseMessaging _firebaseMessaging;
//   Function notification;

//   FirebaseNotifications(this.notification);

//   void setUpFirebase() {
//     _firebaseMessaging = FirebaseMessaging();
//     firebaseCloudMessaging_Listeners();
//   }

//   void firebaseCloudMessaging_Listeners() {
//     _firebaseMessaging.getToken().then((token) {
//       print(token);
//     });
//     _firebaseMessaging.requestNotificationPermissions();

//     _firebaseMessaging.configure(
//       onMessage: (Map<String, dynamic> message) async {
//         print('on message $message');
//         this.notification(0, message['notification']['title'],
//             message['notification']['body'], message['notification']['body']);
//       },
//       onResume: (Map<String, dynamic> message) async {
//         print('on resume $message');
//         this.notification(0, message['notification']['title'],
//             message['notification']['body'], message['notification']['body']);
//       },
//       onLaunch: (Map<String, dynamic> message) async {
//         print('on launch $message');
//         this.notification(0, message['notification']['title'],
//             message['notification']['body'], message['notification']['body']);
//       },
//     );
//   }
// }
