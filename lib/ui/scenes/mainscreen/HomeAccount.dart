import 'package:flutter/material.dart';
// import 'package:hexcolor/hexcolor.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:provider/provider.dart';
import 'package:swfteaproject/constants/GlobalWidgets.dart';
import 'package:swfteaproject/constants/constants.dart';
import 'package:swfteaproject/model/User.dart';
import 'package:swfteaproject/providers/UserProvider.dart';
import 'package:swfteaproject/ui/widgets/generic/dialougeBox.dart';
import 'package:swfteaproject/ui/widgets/generic/levelbot.dart';
import 'package:swfteaproject/providers/SwfTeaController.dart';
import 'package:get/get.dart';
import 'package:swfteaproject/utlis/ApiProvider.dart';
import 'package:swfteaproject/utlis/Replacer.dart';


class HomeAccount extends StatelessWidget {
  final Controller controller = Get.find();
  @override
  Widget build(BuildContext context) {
    int onlinecount = controller.friends
        .where((element) => element.extrainfo['presence'] == 'Online')
        .length;
    int totalfriends = controller.friends.length;
    return Container(
      child: Column(
        children: <Widget>[
          homeProfileBlock(controller.user, context),
          homeAlerts(controller.unreadnotification, context),
          homeEmails(0, context),
          Divider(
            height: 1,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            color: Colors.white,
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.people_outline,
                      color: Theme.of(context).primaryColor,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 5),
                      child: Text(
                        "Friends",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.normal),
                      ),
                    ),
                    Text(
                      " (" +
                          onlinecount.toString() +
                          "/" +
                          totalfriends.toString() +
                          ")",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    controller.fetchFriends(showLoading: true);
                  },
                ),
              ],
            ),
          ),
          Flexible(
            child: RefreshIndicator(
              onRefresh: () async {
                controller.fetchFriends(showLoading: true);
              },
              child: ListView(
                children: controller.friends.reversed.map(
                  (element) {
                    int index = controller.friends.indexOf(element);
                    return Container(
                      color: index == controller.focusedFriend
                          ? Colors.white
                          : Colors.white,
                      height: 50,
                      child: Row(
                        children: <Widget>[
                          Flexible(
                            child: InkWell(
                              onTap: () {
                                if (controller.focusedFriend == index) {
                                  controller.joinThread(
                                    threadid: element.extrainfo['commonid']
                                        .toString(),
                                    threadname: element.username,
                                    receiverid: element.id.toString(),
                                  );
                                } else {
                                  controller.focusedFriend = index;
                                  controller.update();
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 5, top: 5, bottom: 5, right: 5),
                                child: Row(
                                  children: <Widget>[
                                    element.extrainfo['presence'] == "Online"
                                        ? Image(
                                            image: AssetImage(
                                                "assets/images/Online.png"),
                                            height: 20,
                                            width: 20,
                                          )
                                        : Image(
                                            image: AssetImage(
                                                "assets/images/Offline.png"),
                                            height: 20,
                                            width: 20,
                                          ),
                                    Flexible(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              element.username,
                                              style: TextStyle(
                                                color: controller
                                                            .focusedFriend ==
                                                        index
                                                    ? Colors.white
                                                    : Colors.white,
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 10, right: 10),
                                                child: Marquee(
                                                  child: controller
                                                              .focusedFriend ==
                                                          index
                                                      ? Text(
                                                          element.status ?? "")
                                                      : Text(" "),
                                                  textDirection:
                                                      TextDirection.ltr,
                                                  backDuration: Duration(
                                                      milliseconds: 5000),
                                                  pauseDuration: Duration(
                                                      milliseconds: 2500),
                                                  directionMarguee:
                                                      DirectionMarguee
                                                          .oneDirection,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          controller.focusedFriend == index
                              ? Padding(
                                  padding: EdgeInsets.only(top: 5, bottom: 5),
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.toNamed(PROFILE_SCREEN,
                                          arguments: {"id": element.username});
                                    },
                                    child: CustomNetworkImage(
                                      url: element.picture,
                                      height: 30,
                                      width: 30,
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  height: 1,
                                ),
                        ],
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget homeProfileBlock(User user, BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    String tempStatus = user.status;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      height: 70,
      color: Theme.of(context).primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: InkWell(
              child: CustomNetworkImage(
                url: user.picture,
                height: 50,
                width: 50,
              ),
              splashColor: Colors.blue,
              onTap: () {
                Get.toNamed(PROFILE_SCREEN, arguments: {
                  "id": userProvider.user.username,
                });
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                            color: Colors.green[700],
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        user.username,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Wrap(
                      children: [
                        GestureDetector(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 22.0),
                            child: Text(
                              user.status,
                              style: TextStyle(color: Colors.white),
                              overflow: TextOverflow.fade,
                              softWrap: true,
                            ),
                          ),
                          onTap: () {
                            Get.dialog(
                              CustomDialog(
                                title: "Edit status",
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: 0.0,
                                      ),
                                      child: TextField(
                                        controller: TextEditingController(
                                            text: user.status),
                                        onChanged: (value) {
                                          tempStatus = value;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                onSubmit: () {
                                  if (tempStatus.length > 300) {
                                    Get.snackbar("Error",
                                        "Status message cannot be more than 300 character long.");
                                  } else if (tempStatus.length < 5) {
                                    Get.snackbar("Error",
                                        "Status message cannot be less than 5 character.");
                                  } else {
                                    controller.user.status = tempStatus;
                                    controller.update();
                                    CallApi(context).postDataFuture(
                                      {
                                        "status": tempStatus,
                                      },
                                      'user/updateStatus',
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            child: GlobalWidgets.AudioPlayer,
            width: 75,
          ),
          LevelBot(user.level.value)
        ],
      ),
    );
  }

  Widget homeAlerts(alert, BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        color: Colors.grey[300],
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.notification_important,
                  color: Theme.of(context).primaryColor,
                ),
                Container(
                  margin: const EdgeInsets.only(left: 5),
                  child: Text(
                    "SwfTea Alerts",
                    style: TextStyle(
                        color: alert > 0
                            ? Theme.of(context).secondaryHeaderColor
                            : Theme.of(context).primaryColor,
                        fontWeight:
                            alert > 0 ? FontWeight.bold : FontWeight.normal),
                  ),
                ),
                Text(
                  " (" + alert.toString() + ")",
                  style: TextStyle(
                      color: Colors.deepOrange,
                      fontWeight:
                          alert > 0 ? FontWeight.bold : FontWeight.normal),
                ),
              ],
            ),
          ],
        ),
      ),
      onTap: () => Get.toNamed(NOTIFICATION_SCREEN),
    );
  }

  Widget homeEmails(alert, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      color: Colors.white,
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.email,
                color: Theme.of(context).primaryColor,
              ),
              Container(
                margin: const EdgeInsets.only(left: 5),
                child: Text(
                  "Emails",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight:
                          alert > 0 ? FontWeight.bold : FontWeight.normal),
                ),
              ),
              Text(
                " (" + alert.toString() + ")",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight:
                        alert > 0 ? FontWeight.bold : FontWeight.normal),
              ),
            ],
          ),
          Icon(
            Icons.add,
            color: Theme.of(context).primaryColor,
          )
        ],
      ),
    );
  }
}
