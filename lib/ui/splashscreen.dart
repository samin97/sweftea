import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:localstorage/localstorage.dart';

import 'package:provider/provider.dart';
import 'package:swfteaproject/constants/constants.dart';
import 'package:swfteaproject/model/Level.dart';
import 'package:swfteaproject/model/User.dart';
import 'package:swfteaproject/providers/UserProvider.dart';
import 'package:swfteaproject/utlis/FirebaseNotifications.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => new SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  var _visible = true;

  AnimationController animationController;
  Animation<double> animation;

  LocalStorage storage = new LocalStorage('swftea_app');

  startTime() async {
    var _duration = new Duration(seconds: 3);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() {
    try {
      var body = storage.getItem('@body');
      if (body == null)
        Navigator.of(context).pushReplacementNamed(SIGN_IN);
      else {
        UserProvider userProvider = Provider.of<UserProvider>(context);
        userProvider.setUser(
          new User(
            body["user"]["id"],
            body["user"]["username"],
            body["user"]["email"],
            body["user"]["name"],
            body["user"]["profile_picture"],
            body["user"]["main_status"],
            new Level(
              body["user"]["level"]["name"],
              body["user"]["level"]["value"],
            ),
            body["access_token"],
            color: body["user"]["color"],
          ),
        );
        Get.offAllNamed(MAIN_SCREEN);
      }
    } catch (_) {
      Navigator.of(context).pushReplacementNamed(SIGN_IN);
    }
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var androidInitializationSettings;
  var iOSInitializationSettings;
  var initializationSettings;

  @override
  void initState() {
    super.initState();
    androidInitializationSettings =
        new AndroidInitializationSettings('app_icon');
    iOSInitializationSettings =
        new IOSInitializationSettings(onDidReceiveLocalNotification: onDidRec);
    initializationSettings = new InitializationSettings(
        androidInitializationSettings, iOSInitializationSettings);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // var firebase = new FirebaseNotifications(showNotification);
    // firebase.setUpFirebase();
    animationController = new AnimationController(
        vsync: this, duration: new Duration(seconds: 2));
    animation =
        new CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    animation.addListener(() => this.setState(() {}));
    animationController.forward();

    setState(() {
      _visible = !_visible;
    });
    startTime();
  }

  Future<void> showNotification(
      int id, String title, String body, String payload) async {
    var android = AndroidNotificationDetails('id', 'channel ', 'description',
        priority: Priority.High,
        importance: Importance.Max,
        ticker: "Tricker test");
    var iOS = IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);

    await flutterLocalNotificationsPlugin.show(id, title, body, platform,
        payload: body);
  }

  Future onDidRec(int id, String title, String body, String payload) async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Image.asset(
                'assets/images/logo.png',
                width: animation.value * 250,
                height: animation.value * 250,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
