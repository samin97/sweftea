import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
// import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:swfteaproject/constants/Const.dart';
import 'package:swfteaproject/constants/constants.dart';
import 'package:swfteaproject/model/AppTab.dart';
import 'package:swfteaproject/model/User.dart';
import 'package:swfteaproject/providers/SwfTeaController.dart';
import 'package:swfteaproject/ui/scenes/mainscreen/HomeAccount.dart';
import 'package:swfteaproject/ui/scenes/mainscreen/HomeChatroom.dart';
import 'package:swfteaproject/ui/scenes/mainscreen/HomeChatrooms.dart';
import 'package:swfteaproject/model/Message.dart';
import 'package:swfteaproject/model/Emoji.dart';
import 'package:swfteaproject/model/MessageContainer.dart';
import 'package:swfteaproject/ui/widgets/generic/blurryDialouge.dart';
import 'package:swfteaproject/ui/widgets/generic/dialougeBox.dart';
import 'package:swfteaproject/utlis/ApiProvider.dart';

class Replacer {
  String getLevelBotImage(level) {
    return BASE_FULL_URL + 'storage/levels/' + level.toString() + '.png';
  }

  dynamic calcumatePriceWithDiscount(dynamic price, dynamic discount) {
    double dis_price = double.parse(price) - (double.parse(price) * (double.parse(discount) / 100));
    if (dis_price == 0) {
      return '0.00 FREE';
    } else {
      return dis_price.toStringAsFixed(2) + ' credits';
    }
  }

  getDeviceInfo() async {
    return await PackageInfo.fromPlatform();
  }

  String getApplicationStatus(int status) {
    switch (status) {
      case 0:
        return 'Rejected';
      case 1:
        return 'Reviewing';
      case 2:
        return 'Accepted';
      case 3:
        return 'Resolved';
      default:
        return 'None';
    }
  }

  dynamic getPublicImagePath(String image) {
    var images = image.split("/");
    if (images[0] == "public") {
      images[0] = "storage";
    }
    return BASE_FULL_URL + images.join("/");
  }

  String timeAgo(String time) {
    final df = new DateFormat('yyyy-MM-dd, hh:mm a');
    final dt = DateTime.parse(time);
    return df.format(dt);
  }

  Icon getHomeTabIcon(type) {
    switch (type) {
      case "home":
        return Icon(Icons.home);
      case "chatrooms":
        return Icon(Icons.cloud_circle);
      case "chatroom":
        return Icon(Icons.chat_bubble_outline);
      default:
        return Icon(Icons.accessibility);
    }
  }

  Widget getTabContent(AppTab appTab) {
    switch (appTab.type) {
      case "home":
        return HomeAccount();
      case "chatrooms":
        return HomeChatrooms();
      case "chatroom":
        return Chatroom(
          appTab: appTab,
        );
      case "thread":
        return Chatroom(
          appTab: appTab,
        );
      default:
        return HomeAccount();
    }
  }

  Widget emojiRenderer(String emoji, List<Emoji> emojies) {
    List<Emoji> emojidetails = emojies.where((element) => element.name == emoji).toList();
    if (emojidetails.isEmpty) {
      return Text(emoji);
    } else {
      return Container(
        child: CachedNetworkImage(
          imageUrl: emojidetails[0].url,
          height: 16,
          width: 16,
        ),
      );
    }
  }

  Widget gameEmojiRenderer(dynamic emoji, dynamic extras) {
    print("IMAGE " + extras);
    print("EMOJI " + emoji);
    return Container(
      child: CachedNetworkImage(
        imageUrl: 'https://static.vecteezy.com/system/resources/thumbnails/000/420/759/small/Web__28111_29.jpg',
        height: 18,
        width: 18,
      ),
    );
  }
}

class ChatroomTile extends StatelessWidget {
  ChatroomTile({this.room, this.removeFavourite = false, this.addFavourite = true});
  final dynamic room;
  final bool removeFavourite;
  final bool addFavourite;
  final Controller controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onLongPress: () {
        if (this.removeFavourite) {
          Get.dialog(
            BlurryDialog(
              "",
              "Are you sure to remove this chatroom from your favourites?",
              () async {
                Navigator.of(context).pop();
                await CallApi(context).postDataFuture(
                  {'chatroom_id': room['id']},
                  'chatroom/removeFromFavourite',
                );
                controller.clearFavouritesRoom();
                var res1 = await CallApi(context).getDataFuture("chatrooms/favourites");
                List<dynamic> body = json.decode(res1.body).toList();
                body.forEach((element) {
                  controller.setFavouriteChatrooms(element);
                });
              },
            ),
          );
        }
        if (this.addFavourite) {
          Get.dialog(
            BlurryDialog(
              "",
              "Are you sure to add this chatroom to your favourites?",
              () async {
                Navigator.of(context).pop();
                var res = await CallApi(context).postDataFuture(
                  {'chatroom_id': room['id']},
                  'chatroom/addAsFavourite',
                );
                controller.clearFavouritesRoom();
                var res1 = await CallApi(context).getDataFuture("chatrooms/favourites");
                List<dynamic> body = json.decode(res1.body).toList();
                body.forEach((element) {
                  controller.setFavouriteChatrooms(element);
                });
              },
            ),
          );
        }
      },
      onPressed: () {
        controller.joinChatroom(
          chatroomid: room['id'].toString(),
          chatroomname: room['name'],
        );
      },
      child: Container(
        height: 45,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              room["name"],
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
            Text(
              "(" + room["members_count"].toString() + "/" + room["capacity"].toString() + ")",
              style: TextStyle(fontWeight: FontWeight.normal),
            )
          ],
        ),
      ),
    );
  }
}

class AppTabBar extends StatelessWidget {
  final Controller controller = Get.find();
  final Function drawerPress;
  AppTabBar(this.drawerPress);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: Colors.white54,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            margin: EdgeInsets.all(0),
            padding: EdgeInsets.all(0),
            color: Theme.of(context).primaryColor,
            child: IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.white,
              ),
              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
              onPressed: this.drawerPress,
              splashColor: Colors.black,
            ),
          ),
          Expanded(
            child: ScrollablePositionedList.builder(
              itemScrollController: controller.tabBarController,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => TabIcon(controller.tabs[index]),
              itemCount: controller.tabs.length,
            ),
          ),
        ],
      ),
    );
  }
}

class TabIcon extends StatelessWidget {
  TabIcon(this.appTab);
  final AppTab appTab;
  final Controller controller = Get.find();
  @override
  Widget build(BuildContext context) {
    if (appTab.type == 'home' || appTab.type == 'chatrooms') {
      return GestureDetector(
        onTap: () {
          int index = controller.tabs.indexOf(appTab);
          controller.tabController.jumpToPage(index);
        },
        child: Container(
          color: appTab.blinking ? Theme.of(context).secondaryHeaderColor : (appTab.active ? Theme.of(context).primaryColor : Colors.white),
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Row(
            children: <Widget>[
              GetIcon(appTab),
              Text(
                ' ' + appTab.label,
                style: TextStyle(
                  color: appTab.active ? Colors.white : Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    } else if (appTab.active) {
      return InkWell(
        onTap: () {
          int index = controller.tabs.indexOf(appTab);
          controller.tabController.jumpToPage(index);
        },
        splashColor: Theme.of(context).primaryColor,
        child: Container(
          color: Theme.of(context).primaryColor,
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Row(
            children: <Widget>[
              GetIcon(appTab),
              Text(
                ' ' + appTab.label ?? "Private Chat",
                style: TextStyle(color: appTab.active ? Colors.white : Theme.of(context).primaryColor),
              ),
            ],
          ),
        ),
      );
    } else {
      return Tooltip(
        message: appTab.label,
        preferBelow: true,
        child: InkWell(
          splashColor: Theme.of(context).primaryColor,
          onTap: () {
            int index = controller.tabs.indexOf(appTab);
            controller.tabController.jumpToPage(index);
          },
          child: Container(
            color: appTab.blinking
                ? Color.fromRGBO(254, 141, 19, 1)
                // Theme.of(context).secondaryHeaderColor
                : Colors.white,
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              children: <Widget>[
                GetIcon(appTab),
              ],
            ),
          ),
        ),
      );
    }
  }
}

class GetIcon extends StatelessWidget {
  GetIcon(this.appTab);
  final AppTab appTab;
  @override
  Widget build(BuildContext context) {
    switch (appTab.type) {
      case 'home':
        return Icon(
          Icons.home,
          color: (appTab.blinking || appTab.active) ? Colors.white : Theme.of(context).primaryColor,
        );
      case 'chatrooms':
        return Icon(
          Icons.chat_bubble_outline_sharp,
          color: (appTab.blinking || appTab.active) ? Colors.white : Theme.of(context).primaryColor,
        );
      case 'chatroom':
        return Icon(
          Icons.chat_bubble,
          color: (appTab.blinking || appTab.active) ? Colors.white : Theme.of(context).primaryColor,
        );
      default:
        return Icon(
          Icons.ac_unit,
          color: (appTab.blinking || appTab.active) ? Colors.white : Theme.of(context).primaryColor,
        );
    }
  }
}

class SecondaryTitle extends StatelessWidget {
  SecondaryTitle({this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 15, fontWeight: FontWeight.bold),
    );
  }
}

class PrimaryTitle extends StatelessWidget {
  PrimaryTitle({this.title, this.size = 18.0});
  final String title;
  final double size;
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(color: Theme.of(context).primaryColor, fontSize: this.size, fontWeight: FontWeight.bold),
    );
  }
}

class BoldText extends StatelessWidget {
  BoldText({this.text, this.size = 16.0});
  final String text;
  final double size;
  @override
  Widget build(BuildContext context) {
    return Text(
      this.text,
      style: TextStyle(
        fontSize: this.size,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class BlurryBgContainer extends StatelessWidget {
  BlurryBgContainer({@required this.bgImage, @required this.child});
  final ImageProvider bgImage;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: this.bgImage,
          fit: BoxFit.cover,
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: this.child,
        ),
      ),
    );
  }
}

class MissionText extends StatelessWidget {
  MissionText({
    this.text,
    this.size = 16,
    this.isBold = false,
    this.color = Colors.black,
  });
  final String text;
  final double size;
  final bool isBold;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: this.size,
        fontWeight: this.isBold ? FontWeight.bold : FontWeight.normal,
        color: this.color,
        fontFamily: 'MissionFont',
        letterSpacing: 1.2,
      ),
    );
  }
}

class BlackTitle extends StatelessWidget {
  BlackTitle({this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class WhiteTitle extends StatelessWidget {
  WhiteTitle({this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class CustomNetworkImage extends StatelessWidget {
  final height;
  final width;
  final url;
  CustomNetworkImage({
    this.height = 50.0,
    this.width = 50.0,
    @required this.url,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.toDouble(),
      height: height.toDouble(),
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
        image: new DecorationImage(
          fit: BoxFit.cover,
          image: new NetworkImage(url),
        ),
      ),
    );
  }
}

class MessageBuilder extends StatelessWidget {
  MessageBuilder({@required this.message, @required this.messageContainer});
  final SwfTeaMessage message;
  final MessageContainer messageContainer;
  final Controller controller = Get.find();
  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case 'message':
        return NormalMessage(
          message: message,
        );
      case 'instantmessage':
        return NormalInstantMessage(
          message: message,
        );
      case 'roomjoin':
        return InfoMessage(
          from: messageContainer.name,
          message: message,
        );
        break;
      case 'roomleave':
        return InfoMessage(
          from: messageContainer.name,
          message: message,
        );
        break;
      case 'announcement':
        return Announcement(
          message: message,
        );
        break;
      case 'gift_all_cheap':
        return GiftAll(
          message: message,
          //color: HexColor('#000000'),
        );
        break;
      case 'gift_all':
        return GiftAll(
          message: message,
          //color: HexColor(message.extrainfo['color'] ?? '#E6397F'),
        );
        break;
      case 'gift':
        return GiftSingle(
          message: message,
          //color: HexColor('#E6397F'),
        );
        break;
      case 'normal_quote':
        return QuoteMessage(
          message: message,
        );
        break;
      case 'infomessage':
        return InfoMessage(
          from: messageContainer.name,
          message: message,
        );
        break;
      case 'info':
        return InfoMessage(
          from: messageContainer.name,
          message: message,
        );
        break;
      case 'error':
        return InfoMessage(
          from: "Error",
          message: message,
        );
        break;
      case 'game':
        return GameMessage(
          message: message,
        );
        break;
      case 'recordMessage':
        return RecordingMessage(
          message: message,
        );
        break;
      default:
        return Text("No Message NOW");
    }
  }
}

class GiftSingle extends StatelessWidget {
  GiftSingle({
    this.message,
    this.color,
  });
  final SwfTeaMessage message;
  final Color color;
  @override
  Widget build(BuildContext context) {
    String text = message.formattedtext.replaceAll("\\n", "\n").replaceAll(new RegExp(r'/((^")|("$))/'), "");
    var gift = jsonDecode(text);
    return Container(
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
        top: 5,
        bottom: 5,
      ),
      child: Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: '<< ' + gift['sender'] + '[' + gift['sender_level'] + '] gives a ' + gift['gift_name'] + ' ',
            style: TextStyle(
              //color: HexColor(gift['color'] ?? '#000000'),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            children: [
              WidgetSpan(
                child: Container(
                  child: CachedNetworkImage(
                    imageUrl: gift['gift_url'],
                    width: 32,
                    height: 32,
                  ),
                ),
              ),
              TextSpan(
                text: " to " + gift['receiver'] + ' [' + gift['receiver_level'] + '] >>',
                style: TextStyle(
                 // color: HexColor(gift['color'] ?? '#000000'),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GiftAll extends StatelessWidget {
  GiftAll({
    this.message,
    this.color,
  });
  final SwfTeaMessage message;
  final Color color;
  @override
  Widget build(BuildContext context) {
    String text = message.formattedtext.replaceAll("\\n", "\n").replaceAll(new RegExp(r'/((^")|("$))/'), "");
    var gift = jsonDecode(text);
    print(gift);
    return Container(
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
        top: 5,
        bottom: 5,
      ),
      child: Center(
        child: Column(
          children: <Widget>[
            Text(
              "💞🎉🎉 *GIFT SHOWER* 🎉🎉💞",
              style: TextStyle(
                // color: HexColor(gift['color'] ?? '#000000'),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: gift['sender'] + '[' + gift['sender_level'] + '] gives a ' + gift['gift_name'] + ' ',
                style: TextStyle(
                  // color: HexColor(gift['color'] ?? '#000000'),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  WidgetSpan(
                    child: Container(
                      child: CachedNetworkImage(
                        imageUrl: gift['gift_url'],
                        width: 32,
                        height: 32,
                      ),
                    ),
                  ),
                  TextSpan(
                    text: " to " + gift['receivers'],
                    style: TextStyle(
                      // color: HexColor(gift['color'] ?? '#000000'),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "**** Hurray ****",
              style: TextStyle(
                // color: HexColor(gift['color'] ?? '#000000'),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Announcement extends StatelessWidget {
  Announcement({this.message});
  final SwfTeaMessage message;
  @override
  Widget build(BuildContext context) {
    String text = message.formattedtext.replaceAll("\\n", "\n");
    return Container(
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
        top: 5,
        bottom: 5,
      ),
      child: Center(
        child: Column(
          children: <Widget>[
            Text(
              "<< *Announcement* >>",
              style: TextStyle(
                // color: HexColor("#623616"),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              text,
              style: TextStyle(
                // color: HexColor("#623616"),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              "**** 🔥🔥 🔥🔥 ****",
              style: TextStyle(
                // color: HexColor("#623616"),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuoteMessage extends StatelessWidget {
  QuoteMessage({this.message});
  final SwfTeaMessage message;
  @override
  Widget build(BuildContext context) {
    String text = message.formattedtext.replaceAll("\\n", "\n");
    return Container(
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
        top: 5,
        bottom: 5,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            // color: HexColor("#623616"),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class InfoMessage extends StatelessWidget {
  InfoMessage({this.message, this.from, this.color = "#000000"});
  final SwfTeaMessage message;
  final String from;
  final String color;
  @override
  Widget build(BuildContext context) {
    String text = message.formattedtext.replaceAll("\\n", "\n");
    return
        // Dismissible(
        //   child:
        Container(
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
        top: 6,
        bottom: 6,
      ),
      child:
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Text(
          //       from + ": ",
          //       style: TextStyle(
          //         color: HexColor('#E67E22'),
          //         fontSize: 16,
          //       ),
          //     ),
          //     Flexible(
          //       child: Text(
          //         text,
          //         style: TextStyle(
          //           color: HexColor(this.color ?? "#E67E22"),
          //           fontSize: 16,
          //         ),
          //         textAlign: TextAlign.justify,
          //       ),
          //     ),
          //   ],
          // ),

          RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: from,
              style: TextStyle(
                // color: HexColor('#E67E22'),
                fontSize: 16,
              ),
            ),
            TextSpan(
              text: ": ",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            TextSpan(
              text: text,
              style: TextStyle(
                // color: HexColor(this.color ?? "#E67E22"),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
    //   onDismissed: (direction) {
    //     print(direction);
    //   },
    // );
  }
}

class GameMessage extends StatelessWidget {
  GameMessage({
    this.message,
  });
  final SwfTeaMessage message;
  @override
  Widget build(BuildContext context) {
    var splitter = new RegExp(
      r'(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})',
    );
    String text = message.formattedtext.replaceAll("\\n", "\n");
    Iterable<Match> allMatches = splitter.allMatches(text);
    int lastIndex = 0;
    List additionalRolls = [];
    if ((message.extrainfo['roll'] ?? []).length > 0 && message.extrainfo['game'] == 'dice') {
      additionalRolls.add(
        WidgetSpan(
          child: Text(
            'Matching guesses...',
            style: TextStyle(
              // color: HexColor('#4A99DB'),
              fontSize: 16,
            ),
          ),
        ),
      );
      additionalRolls.add(
        TextSpan(text: "\n"),
      );
      for (var roll in message.extrainfo['roll']) {
        additionalRolls.add(
          WidgetSpan(
            child: Container(
              child: CachedNetworkImage(
                imageUrl: ICON_URL + '/games/dice/' + roll + '.png',
                height: 40.0,
                width: 40.0,
              ),
            ),
          ),
        );
      }
      additionalRolls.add(
        TextSpan(text: "\n"),
      );
    }
    if ((message.extrainfo['roll'] ?? []).length > 0 && message.extrainfo['game'] == 'lucky7') {
      additionalRolls.add(
        WidgetSpan(
          child: Text(
            'Spinning...',
            style: TextStyle(
              // color: HexColor('#4A99DB'),
              fontSize: 16,
            ),
          ),
        ),
      );
      additionalRolls.add(
        TextSpan(text: "\n"),
      );
      int i = 0;
      for (var roll in message.extrainfo['roll']) {
        additionalRolls.add(
          WidgetSpan(
            child: Container(
              child: CachedNetworkImage(
                imageUrl: ICON_URL + '/games/lucky7/' + roll.toString() + '.png',
                height: 40.0,
                width: 40.0,
              ),
            ),
          ),
        );
        if (i == 0) {
          additionalRolls.add(
            TextSpan(
              text: " + ",
              style: TextStyle(
                // color: HexColor('#4A99DB'),
                fontSize: 16,
              ),
            ),
          );
        }
        if (i == 1) {
          additionalRolls.add(
            TextSpan(
              text: " = ",
              style: TextStyle(
                // color: HexColor('#4A99DB'),
                fontSize: 16,
              ),
            ),
          );
        }
        i++;
      }
      additionalRolls.add(
        WidgetSpan(
          child: Container(
            child: CachedNetworkImage(
              imageUrl: ICON_URL + '/games/lucky7/' + message.extrainfo['total'].toString() + '.png',
              height: 40.0,
              width: 40.0,
            ),
          ),
        ),
      );

      additionalRolls.add(
        TextSpan(text: "\n"),
      );
    }
    List matches = allMatches.map((e) {
      var list;
      list = TextSpan(
        text: text.substring(lastIndex, e.start),
        children: [
          WidgetSpan(
            child: Container(
              child: CachedNetworkImage(
                imageUrl: text.substring(e.start, e.end),
                height: double.parse((message.extrainfo['img_height'] ?? '18.0').toString()),
                width: double.parse((message.extrainfo['img_width'] ?? '18.0').toString()),
              ),
            ),
          ),
        ],
        style: TextStyle(
          // color: HexColor('#4A99DB'),
          fontSize: 16,
        ),
      );
      lastIndex = e.end;
      return list;
    }).toList();
    if (lastIndex < text.length) {
      matches.add(
        TextSpan(
          text: text.substring(lastIndex, text.length),
          style: TextStyle(
            // color: HexColor('#4A99DB'),
            fontSize: 16,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
        top: 5,
        bottom: 5,
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: message.bot,
              style: TextStyle(
                // color: HexColor('#97C664'),
                fontSize: 16,
              ),
            ),
            TextSpan(
              text: ": ",
              style: TextStyle(
                // color: HexColor('#97C664'),
                fontSize: 16,
              ),
            ),
            ...additionalRolls,
            ...matches,
          ],
        ),
      ),
    );
  }
}

class RecordingMessage extends StatefulWidget {
  RecordingMessage({this.message});
  final SwfTeaMessage message;
  final Controller controller = Get.find();
  @override
  _RecordingMessageState createState() => _RecordingMessageState();
}

class _RecordingMessageState extends State<RecordingMessage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
        top: 5,
        bottom: 5,
      ),
      child: Row(
        children: [
          GestureDetector(
            child: Text(
              widget.message.sender.username,
              style: TextStyle(
                // color: HexColor(widget.message.sender.color),
                fontSize: 16.0,
              ),
            ),
            onTap: () {
              var m = widget.controller.tabs[widget.controller.tabController.page.round()].textBox.text + widget.message.sender.username;
              widget.controller.tabs[widget.controller.tabController.page.round()].textBox.value = TextEditingValue(
                text: m,
                selection: TextSelection.collapsed(offset: m.length),
              );
            },
          ),
          Text(': '),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: SizedBox(
              height: 20,
              child: Row(
                children: [
                  GestureDetector(
                    child: Icon(
                      widget.message.hashCode == widget.controller.audioPlayingHash
                          ? widget.controller.isAudioPlaying
                              ? Icons.pause_circle_outline
                              : Icons.play_circle_outline
                          : Icons.play_circle_outline,
                      color: Theme.of(context).primaryColor,
                    ),
                    onTap: () {
                      widget.controller.getAudio(widget.message);
                    },
                  ),
                  Expanded(
                    child: widget.controller.audioPlayingHash == widget.message.hashCode
                        ? Slider.adaptive(
                            min: 0.0,
                            value: widget.controller.position.inMilliseconds.toDouble(),
                            max: widget.controller.duration.inMilliseconds.toDouble(),
                            activeColor: Theme.of(context).primaryColor,
                            inactiveColor: Theme.of(context).secondaryHeaderColor,
                            onChanged: (double value) {
                              widget.controller.audioPlayer.seek(
                                new Duration(
                                  milliseconds: value.toInt(),
                                ),
                              );
                            },
                          )
                        : Slider.adaptive(
                            min: 0.0,
                            value: 0,
                            max: 10,
                            activeColor: Theme.of(context).primaryColor,
                            inactiveColor: Theme.of(context).secondaryHeaderColor,
                            onChanged: (double value) {},
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NormalMessage extends StatelessWidget {
  NormalMessage({this.message});
  final SwfTeaMessage message;
  final Controller controller = Get.find();
  @override
  Widget build(BuildContext context) {
    var splitter = new RegExp(
      r'\(([a-z_\-]+?)\)',
    );
    String text = message.formattedtext.replaceAll("\\n", "\n");
    Iterable<Match> allMatches = splitter.allMatches(text);
    List<Emoji> emojies = [];
    if (message.extrainfo['emojies'] is List) {
    } else {
      for (var emoji in message.extrainfo['emojies'].keys) {
        emojies.add(
          new Emoji(
            name: message.extrainfo['emojies'][emoji]['name'],
            url: message.extrainfo['emojies'][emoji]['img'],
          ),
        );
      }
    }
    int lastIndex = 0;
    List texts = allMatches.map((e) {
      var list = TextSpan(
        text: text.substring(lastIndex, e.start),
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        children: <WidgetSpan>[
          WidgetSpan(
            child: Replacer().emojiRenderer(
              text.substring(e.start, e.end),
              emojies,
            ),
          ),
        ],
      );
      lastIndex = e.end;
      return list;
    }).toList();
    if (lastIndex > 0) {
      if (lastIndex < (text.length - 1)) {
        texts.add(
          TextSpan(
            text: text.substring(lastIndex, text.length),
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        );
      }
    } else {
      texts.add(
        TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      );
    }
    List<Widget> images = [];
    for (var element in message.extrainfo['images'] ?? []) {
      images.add(
        GestureDetector(
          onTap: () => Get.toNamed(
            VIEW_IMAGE,
            arguments: {
              "images": message.extrainfo['images'],
              "type": "network",
              "focus": element,
            },
          ),
          child: Container(
            color: Theme.of(context).primaryColor,
            margin: EdgeInsets.only(
              right: 5,
              bottom: 5,
              top: 5,
            ),
            child: Image.network(
              element['path'],
              height: 100,
              width: 100,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onLongPress: () {
        Get.dialog(
          CustomDialog(
            image: CustomNetworkImage(url: message.sender.picture, height: Const().avatarRadius * 2, width: Const().avatarRadius * 2),
            title: message.sender.name,
            child: SizedBox(
              height: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        message.sender.username,
                        style: TextStyle(
                          // color: HexColor(message.sender.color),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            constraints: BoxConstraints(
                              maxWidth: 50,
                            ),
                            icon: Icon(
                              Icons.supervised_user_circle,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              Get.toNamed(PROFILE_SCREEN, arguments: {
                                "id": message.sender.username,
                              });
                            },
                          ),
                          IconButton(
                            constraints: BoxConstraints(
                              maxWidth: 50,
                            ),
                            icon: Icon(
                              Icons.attach_money,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              Get.toNamed(
                                TRANSFER_SCREEN,
                                arguments: message.sender.username,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(message.sender.status),
                  Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.content_copy,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: Text("Copy username"),
                    onTap: () {
                      Clipboard.setData(
                        new ClipboardData(
                          text: message.sender.username,
                        ),
                      ).then((_) {
                        print("Copied");
                        Get.snackbar("Success", "Username copied to clipboard.");
                      });
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.content_copy,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: Text("Copy message"),
                    onTap: () {
                      Clipboard.setData(
                        new ClipboardData(
                          text: message.formattedtext,
                        ),
                      ).then((_) {
                        Get.snackbar("Success", "Message copied to clipboard.");
                      });
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.content_copy,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: Text("Copy username and message"),
                    onTap: () {
                      Clipboard.setData(
                        new ClipboardData(
                          text: message.sender.username + ": " + message.formattedtext,
                        ),
                      ).then((_) {
                        Get.snackbar("Success", "Username and text copied to clipboard.");
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
          top: 5,
          bottom: 5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                      text: message.sender.username,
                      style: TextStyle(
                        // color: HexColor(message.sender.color ?? '#000000'),
                        fontSize: 16,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          var m = controller.tabs[controller.tabController.page.round()].textBox.text + ' ' + message.sender.username + ' ';
                          controller.tabs[controller.tabController.page.round()].textBox.value = TextEditingValue(
                            text: m,
                            selection: TextSelection.collapsed(offset: m.length),
                          );
                        }
                      // ..onLongPress=(){}

                      // onLongPress = (){},
                      ),
                  TextSpan(
                    text: ": ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    children: texts,
                  ),
                ],
              ),
            ),
            // Row(
            //   children: [
            //     Text(
            //       message.sender.username + ":",
            //       style: TextStyle(
            //         color: HexColor(message.sender.color ?? '#000000'),
            //         fontSize: 10,
            //       ),
            //     ),
            //     RichText(
            //       text: TextSpan(
            //         text: ": ",
            //         style: TextStyle(
            //           color: Colors.black,
            //           fontSize: 16,
            //         ),
            //         children: texts,
            //       ),
            //     ),
            //   ],
            // ),
            Wrap(children: images),
          ],
        ),
      ),
    );
  }
}

class NormalInstantMessage extends StatelessWidget {
  NormalInstantMessage({this.message});
  final SwfTeaMessage message;
  final Controller controller = Get.find();
  @override
  Widget build(BuildContext context) {
    var splitter = new RegExp(
      r'\(([a-z_\-]+?)\)',
    );
    String text = message.formattedtext.replaceAll("\\n", "\n");
    Iterable<Match> allMatches = splitter.allMatches(text);
    List<Emoji> emojies = message.extrainfo['emojies'];
    int lastIndex = 0;
    List texts = allMatches.map((e) {
      var list = TextSpan(
        text: text.substring(lastIndex, e.start),
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        children: <WidgetSpan>[
          WidgetSpan(
            child: Replacer().emojiRenderer(
              text.substring(e.start, e.end),
              emojies,
            ),
          ),
        ],
      );
      lastIndex = e.end;
      return list;
    }).toList();
    if (lastIndex > 0) {
      if (lastIndex < (text.length - 1)) {
        texts.add(
          TextSpan(
            text: text.substring(lastIndex, text.length),
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        );
      }
    } else {
      texts.add(
        TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      );
    }
    List<Widget> images = [];
    for (var element in message.extrainfo['images'] ?? []) {
      images.add(
        GestureDetector(
          onTap: () => Get.toNamed(
            VIEW_IMAGE,
            arguments: {
              "images": message.extrainfo['images'],
              "type": "asset",
              "focus": element,
            },
          ),
          child: Container(
            color: Theme.of(context).primaryColor,
            margin: EdgeInsets.only(
              right: 5,
              bottom: 5,
              top: 5,
            ),
            child: Image.file(
              File(element),
              height: 100,
              width: 100,
            ),
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
        top: 5,
        bottom: 5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: message.sender.username,
                  style: TextStyle(
                    // color: HexColor(message.sender.color ?? '#000000'),
                    fontSize: 16,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      var m = controller.tabs[controller.tabController.page.round()].textBox.text + ' ' + message.sender.username + ' ';
                      controller.tabs[controller.tabController.page.round()].textBox.value = TextEditingValue(
                        text: m,
                        selection: TextSelection.collapsed(offset: m.length),
                      );
                    },
                ),
                TextSpan(
                  text: ": ",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  children: texts,
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 0.0,
            children: images,
          )
        ],
      ),
    );
  }
}

class UserWithColor extends StatelessWidget {
  UserWithColor({this.user, this.onPressed});
  final User user;
  final Function onPressed;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          this.user.username,
          textAlign: TextAlign.left,
          style: TextStyle(
            // color: HexColor(
            //   this.user.color.toString(),
            // ),
          ),
        ),
      ),
      onPressed: () => this.onPressed(),
    );
  }
}

class UserWithColorRaw extends StatelessWidget {
  UserWithColorRaw({this.user, this.onPressed});
  final dynamic user;
  final Function onPressed;
  @override
  Widget build(BuildContext context) {
    print(user['profile_picture']);
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              InkWell(
                child: CachedNetworkImage(
                  imageUrl: user['profile_picture'],
                  height: 40,
                  width: 40,
                  placeholder: (context, url) => CircularProgressIndicator(
                    strokeWidth: 2.0,
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                splashColor: Colors.blue,
                onTap: () {
                  print("Tapping");
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      this.user['name'],
                    ),
                    Text(
                      this.user['username'],
                      textAlign: TextAlign.left,
                      // style: TextStyle(
                      //   color: HexColor(
                      //     this.user['color'].toString(),
                      //   ),
                      // ),
                    ),
                    Row(
                      children: <Widget>[
                        Text('L: '),
                        Text(
                          this.user['level']['value'].toString(),
                        ),
                        Text(' | '),
                        Text(this.user['country']),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () => this.onPressed(),
    );
  }
}
