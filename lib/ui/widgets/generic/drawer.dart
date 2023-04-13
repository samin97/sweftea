import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:localstorage/localstorage.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:swfteaproject/constants/GlobalWidgets.dart';
import 'package:swfteaproject/constants/constants.dart';
import 'package:swfteaproject/main.dart';
import 'package:swfteaproject/providers/UserProvider.dart';
import 'package:swfteaproject/ui/Screens/WebView.dart';
import 'package:swfteaproject/ui/mainscreen.dart';
import 'package:swfteaproject/ui/widgets/generic/blurryDialouge.dart';
import 'package:swfteaproject/ui/widgets/generic/dialougeBox.dart';
import 'package:swfteaproject/ui/widgets/generic/levelbot.dart';
import 'package:swfteaproject/ui/widgets/generic/restart.dart';
import 'package:swfteaproject/utlis/Replacer.dart';
import 'package:url_launcher/url_launcher.dart';

class MainDrawer extends StatefulWidget {
  MainDrawer({this.skey});
  final GlobalKey skey;
  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  String versionName = '';
  String versionCode = '';

  LocalStorage storage = new LocalStorage('swftea_app');
  @override
  void initState() {
    super.initState();
    new Future.delayed(Duration.zero, () async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        versionName = packageInfo.version;
        versionCode = packageInfo.buildNumber;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            margin: const EdgeInsets.all(0),
            accountEmail: Text(userProvider.user.username),
            accountName: Text(userProvider.user.name),
            currentAccountPicture: InkWell(
              child: CustomNetworkImage(
                url: userProvider.user.picture,
              ),
              splashColor: Colors.blue,
              onTap: () {
                Get.toNamed(PROFILE_SCREEN, arguments: {
                  "id": userProvider.user.username,
                });
              },
            ),
            otherAccountsPictures: <Widget>[
              LevelBot(userProvider.user.level.value)
            ],
          ),
          Container(
            margin: EdgeInsets.all(0),
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.shopping_basket,
                    size: 20,
                    // color: Colors.white,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Get.toNamed(GIFTS_SCREEN);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 25.0),
                  child: IconButton(
                    icon: Icon(
                      Icons.notifications,
                      size: 20,
                      // color: Colors.white,

                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Get.toNamed(NOTIFICATION_SCREEN);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.only(top: 0.0),
              children: [
                ListTile(
                  leading: Icon(
                    Icons.home,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text('Home'),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.account_box,
                    color: Theme.of(context).primaryColor,
                  ),
                  onTap: () => Get.toNamed(MY_ACCOUNT),
                  title: Text('My Account'),
                ),
                ListTile(
                  leading: Icon(
                    Icons.speaker,
                    color: Theme.of(context).primaryColor,
                  ),
                  onTap: () => Get.toNamed(ANNOUNCEMENT_SCREEN),
                  title: Text('Announcements'),
                ),
                ListTile(
                  leading: Icon(
                    Icons.nature_people,
                    color: Theme.of(context).primaryColor,
                  ),
                  onTap: () => Get.toNamed(SEARCH_FRIENDS_SCREEN),
                  title: Text('Search Users'),
                ),
                ListTile(
                  leading: Icon(
                    Icons.explore,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text('SwfTea World'),
                  onTap: () => Get.toNamed(EXPLORER_SCREEN),
                ),
                ListTile(
                  leading: Icon(
                    Icons.casino,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text('SwfTea Mania'),
                  onTap: () => Get.toNamed(BETTING_SYSTEM),
                ),
                ListTile(
                  leading: Icon(
                    Icons.gamepad,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text('SwfTea Mission'),
                  onTap: () => Get.toNamed(MISSION_INIT),
                ),
                // ListTile(
                //   leading: Icon(
                //     Icons.attach_money,
                //     color: Theme.of(context).primaryColor,
                //   ),
                //   title: Text('Watch and Earn'),
                //   onTap: () => Get.toNamed(WATCH_AND_EARN),
                // ),
                ListTile(
                  leading: Icon(
                    Icons.settings,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text('Settings'),
                  onTap: () {
                    Get.toNamed(SETTINGS_SCREEN);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.exit_to_app,
                    color: Theme.of(context).primaryColor,
                  ),
                  onTap: () async {
                    Get.dialog(
                      BlurryDialog(
                        "",
                        "Are you sure to logout?",
                        () async {
                          // exit(0);
                          GlobalObject.audioPlayer.stop();
                          storage.setItem('@body', null);
                          Navigator.of(context).pushReplacementNamed(SIGN_IN);
                        },
                      ),
                    );
                  },
                  title: Text('Logout'),
                ),
              ],
            ),
          ),
          Divider(),
          Container(
            padding: const EdgeInsets.only(
              top: 5,
              bottom: 5,
            ),
            child: Center(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (await canLaunch(
                              'https://www.facebook.com/groups/757010658417938')) {
                            await launch(
                                'https://www.facebook.com/groups/757010658417938');
                          }
                        },
                        child: Image.asset(
                          "assets/images/fblogo.jpg",
                          height: 16,
                          width: 16,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WebviewApp(
                                  BASE_FULL_URL + 'custom/privacy-policy',
                                  "Privacy Policy"),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.privacy_tip,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WebviewApp(
                                  BASE_FULL_URL + 'custom/about-us',
                                  "About Us"),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.info,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text('SwfTea v' + versionName),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
