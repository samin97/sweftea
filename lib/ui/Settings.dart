import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swfteaproject/constants/constants.dart';
import 'package:swfteaproject/utlis/Replacer.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: [
              BlackTitle(
                title: "Account",
              ),
              Divider(),
              InkWell(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      SecondaryTitle(
                        title: "Change Pin",
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Get.toNamed(PINCODE_CHANGE_SETTINGS_SCREEN);
                },
              ),
              InkWell(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.vpn_key,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      SecondaryTitle(
                        title: "Change Password",
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Get.toNamed(PASSWORD_CHANGE_SETTINGS_SCREEN);
                },
              ),
              SizedBox(
                height: 10,
              ),
              // BlackTitle(
              //   title: "General",
              // ),
              // Divider(),
              // InkWell(
              //   child: Padding(
              //     padding: const EdgeInsets.all(10),
              //     child: Row(
              //       children: [
              //         SecondaryTitle(
              //           title: "Load images on chatroom",
              //         ),
              //       ],
              //     ),
              //   ),
              //   onTap: () {
              //     print("A");
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
