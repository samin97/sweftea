import 'package:flutter/material.dart';
import 'package:flutter_pusher/pusher.dart';
import 'package:get/get.dart';
import 'package:swfteaproject/constants/constants.dart';
import 'package:swfteaproject/providers/SwfTeaController.dart';
import 'package:swfteaproject/ui/widgets/generic/restart.dart';

class Logout extends StatefulWidget {
  final Controller _controller = Get.find();
  @override
  _LogoutState createState() => _LogoutState();
}

class _LogoutState extends State<Logout> {
  @override
  void initState() {
    super.initState();
    new Future.delayed(Duration.zero, () async {
      await Pusher.disconnect();
      RestartWidget.of(context).restartApp();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("Please wait..."),
    );
  }
}
