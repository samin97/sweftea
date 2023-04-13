import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:hexcolor/hexcolor.dart';
import 'package:swfteaproject/providers/SwfTeaController.dart';
import 'package:swfteaproject/ui/Announcements.dart';
import 'package:swfteaproject/utlis/ApiProvider.dart';
import 'package:swfteaproject/utlis/Replacer.dart';

class Notifications extends StatefulWidget {
  final Controller controller = Get.find();
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List notifications = [];
  @override
  void initState() {
    super.initState();

    new Future.delayed(Duration.zero, () async {
      widget.controller.unreadnotification = 0;
      widget.controller.update();
      var response =
          await CallApi(Get.context).getDataFuture('notifications/all');
      dynamic data = json.decode(response.body);
      setState(() {
        notifications = data['data'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
      ),
      body: notifications.isNotEmpty
          ? ListView.separated(
              separatorBuilder: (context, index) {
                return Divider(
                  height: 1,
                );
              },
              itemBuilder: (context, index) {
                Color bgColor = notifications[index]['status'] == 0
                    ? Colors.white : Colors.white;
                // HexColor('#EFF7FD')
                //     : HexColor('#fff');

                print(notifications[index]['navigate']);
                return GestureDetector(
                  onTap: () {
                    // if ((notifications[index]['navigate'] ?? null) != null) {
                    // Get.toNamed(notifications[index]['navigate'],
                    //     arguments: notifications[index]['params']);
                    if (notifications[index]['navigate'] == "Announcements") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Announcements()),
                      );
                    }
                    // }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: <Widget>[
                        (notifications[index]['avatar'] ?? null) == null
                            ? SizedBox(
                                height: 0.1,
                              )
                            : CachedNetworkImage(
                                imageUrl: notifications[index]['avatar'],
                                height: 50,
                                width: 50,
                              ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(left: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                (notifications[index]['title'] ?? null) == null
                                    ? SizedBox(
                                        height: 0.1,
                                      )
                                    : Text(
                                        notifications[index]['title'],
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                (notifications[index]['description'] ?? null) ==
                                        null
                                    ? SizedBox(
                                        height: 0.1,
                                      )
                                    : Text(
                                        notifications[index]['description'],
                                      ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  Replacer().timeAgo(
                                      notifications[index]['created_at']),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    color: bgColor,
                  ),
                );
              },
              itemCount: notifications.length,
            )
          : Container(
              child: Center(
                child: Text("Empty notifications.."),
              ),
            ),
    );
  }
}
