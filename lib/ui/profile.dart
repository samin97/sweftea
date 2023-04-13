import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:swfteaproject/constants/constants.dart';
import 'package:swfteaproject/providers/SwfTeaController.dart';
import 'package:swfteaproject/providers/UserProvider.dart';
import 'package:swfteaproject/ui/widgets/generic/dialougeBox.dart';
import 'package:swfteaproject/ui/widgets/generic/levelbot.dart';
import 'package:swfteaproject/ui/widgets/generic/nicebuttom.dart';
import 'package:swfteaproject/utlis/ApiProvider.dart';
import 'package:swfteaproject/utlis/Replacer.dart';
import 'package:http/http.dart' as http;

class Profile extends StatefulWidget {
  final picker = ImagePicker();
  final Controller controller = Get.find();

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  dynamic args = Get.arguments;
  String username;
  dynamic user;

  @override
  void initState() {
    setState(
      () {
        username = args["id"];
        user = {
          "id": 1,
          "name": '',
          "email": '',
          "username": username,
          "profile_picture": 'https://via.placeholder.com/150',
          "cover_picture": 'https://via.placeholder.com/150',
          "gender": '',
          "country": '',
          "gifts_count": 0,
          "sentgifts_count": 0,
          "footprints_count": 0,
          "isFriendWithYou": false,
          "hasFriendRequestFromYou": false,
          "hasSentFriendRequestToYou": false,
          "likes_count": 0,
          "points": 0,
          "friends_count": 0,
          "member_since": '',
          "likedByYou": false,
          "badges": [],
          "level": {
            "name": "Novice",
            "value": 17,
          },
          "roles": [],
          "avatar": null,
        };
      },
    );
    super.initState();
    new Future.delayed(Duration.zero, () async {
      dynamic response =
          await CallApi(context).getDataFuture('user/profile/' + username);
      var userDetails = json.decode(response.body);
      setState(() {
        user = userDetails;
      });
    });
  }

  Future getUpdateProfileImage() async {
    try {
      final pickedFile =
          await widget.picker.getImage(source: ImageSource.gallery);
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(BASE_URL + 'user/updatePicture'),
      );
      request.files.add(
        await http.MultipartFile.fromPath('profile_picture', pickedFile.path),
      );
      request.headers.addAll({
        "Content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + widget.controller.user.token
      });
      http.Response response =
          await http.Response.fromStream(await request.send());
      dynamic details = json.decode(response.body);
      setState(() {
        user['profile_picture'] = details['message'];
      });
    } catch (error) {}
  }

  Future getUpdateCoverImage() async {
    try {
      final pickedFile =
          await widget.picker.getImage(source: ImageSource.gallery);
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(BASE_URL + 'user/updateCoverPicture'),
      );
      request.files.add(
        await http.MultipartFile.fromPath('cover_picture', pickedFile.path),
      );
      request.headers.addAll({
        "Content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + widget.controller.user.token
      });

      http.Response response =
          await http.Response.fromStream(await request.send());
      dynamic details = json.decode(response.body);
      setState(() {
        user['cover_picture'] = details['message'];
      });
    } catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    List<Widget> badges = [];
    List<Widget> roles = [];

    for (var role in user['roles']) {
      roles.insert(
        0,
        Text(role['name']),
      );
    }

    for (var badge in user['badges']) {
      badges.insert(
        0,
        GestureDetector(
          child: Container(
            margin: const EdgeInsets.all(5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: CachedNetworkImage(
                imageUrl: Replacer().getPublicImagePath(badge['image']),
                height: 50,
                width: 50,
              ),
            ),
          ),
          onTap: () {
            Get.dialog(
              CustomDialog(
                title: badge['name'],
                child: Column(
                  children: <Widget>[
                    CachedNetworkImage(
                      imageUrl: Replacer().getPublicImagePath(badge['image']),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(badge['description']),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("@" + username),
        // actions: <Widget>[
        //   IconButton(
        //     icon: Icon(Icons.edit),
        //     onPressed: () {},
        //   )
        // ],
      ),
      body: ListView(
        children: <Widget>[
          Card(
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Get.toNamed(
                      VIEW_IMAGE,
                      arguments: {
                        "images": [
                          {"path": user['cover_picture']}
                        ],
                        "type": "network",
                      },
                    );
                  },
                  child: Stack(
                    children: [
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              user['cover_picture'],
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      userProvider.user.username == username
                          ? Positioned(
                              child: Container(
                                color: Theme.of(context).primaryColor,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    getUpdateCoverImage();
                                  },
                                ),
                              ),
                              top: 10.0,
                              right: 10.0,
                            )
                          : SizedBox(
                              height: 0.1,
                            ),
                    ],
                  ),
                ),
                getUserPrimaryInfoBlock(userProvider.user.username == username),
              ],
            ),
          ),
          user['badges'].length > 0
              ? Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SecondaryTitle(
                          title: "Badges (" +
                              user['badges'].length.toString() +
                              ")",
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Wrap(
                          children: badges,
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  height: 0.1,
                ),
          getUserInfoBlock(userProvider.user.username == username, roles),
          getAdditionalOptions(userProvider.user.username == username),
        ],
      ),
    );
  }

  likeProfile() {
    CallApi(context).postData({'to': user['id']}, 'user/like');
    user['likedByYou'] = true;
    user['likes_count'] = user['likes_count'] + 1;
    setState(() {
      user = user;
    });
  }

  unfriend() {
    CallApi(context).postData({'to': user['id']}, 'user/unfriend');
    user['hasSentFriendRequestToYou'] = false;
    user['hasFriendRequestFromYou'] = false;
    user['isFriendWithYou'] = false;
    setState(() {
      user = user;
    });
  }

  cancelFriendRequest() {
    CallApi(context).postData({'to': user['id']}, 'user/cancelFriendRequest');
    user['isFriendWithYou'] = false;
    user['hasFriendRequestFromYou'] = false;
    setState(() {
      user = user;
    });
  }

  acceptFriendRequest() {
    CallApi(context).postData({'to': user['id']}, 'user/acceptFriendRequest');
    user['isFriendWithYou'] = true;
    user['hasSentFriendRequestToYou'] = false;
    user['hasFriendRequestFromYou'] = false;
    setState(() {
      user = user;
    });
  }

  sendFriendRequest() {
    CallApi(context).postData({'to': user['id']}, 'user/sendFriendRequest');
    user['hasFriendRequestFromYou'] = true;
    setState(() {
      user = user;
    });
  }

  unLikeProfile() {
    CallApi(context).postData({'to': user['id']}, 'user/unlike');
    user['likedByYou'] = false;
    user['likes_count'] = user['likes_count'] - 1;
    setState(() {
      user = user;
    });
  }

  Widget getUserPrimaryInfoBlock(bool isMe) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      transform: Matrix4.translationValues(0.0, -50.0, 0.0),
      child: Row(
        children: <Widget>[
          Stack(
            children: [
              GestureDetector(
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  radius: 50,
                  child: CustomNetworkImage(
                    url: user['profile_picture'],
                    height: 95.0,
                    width: 95.0,
                  ),
                ),
                onTap: () {
                  Get.toNamed(
                    VIEW_IMAGE,
                    arguments: {
                      "images": [
                        {"path": user['profile_picture']}
                      ],
                      "type": "network",
                    },
                  );
                },
              ),
              isMe
                  ? Positioned(
                      child: GestureDetector(
                        child: Container(
                          width: 30,
                          height: 30,
                          color: Theme.of(context).primaryColor,
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                        onTap: () {
                          getUpdateProfileImage();
                        },
                      ),
                      right: 20.0,
                      top: 20.0,
                    )
                  : SizedBox(
                      height: 0.1,
                    ),
            ],
          ),
          Flexible(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ProfileInfo(
                        title: "Gifts",
                        count: user['gifts_count'],
                      ),
                      ProfileInfo(
                        title: "Friends",
                        count: user['friends_count'],
                      ),
                      ProfileInfo(
                        title: "Points",
                        count: user['points'],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  !isMe
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            user['likedByYou']
                                ? NiceButton(
                                    bgColor: Colors.red,
                                    textColor: Colors.white,
                                    onPressed: () {
                                      unLikeProfile();
                                    },
                                    child: Text('Unlike'),
                                  )
                                : NiceButton(
                                    onPressed: () {
                                      likeProfile();
                                    },
                                    child: Icon(Icons.thumb_up),
                                  ),
                            user['isFriendWithYou']
                                ? NiceButton(
                                    onPressed: () {
                                      unfriend();
                                    },
                                    child: Text('Unfriend'),
                                  )
                                : SizedBox(
                                    height: 0,
                                  ),
                            user['hasFriendRequestFromYou']
                                ? NiceButton(
                                    onPressed: () {
                                      cancelFriendRequest();
                                    },
                                    child: Text('Cancel'),
                                  )
                                : SizedBox(
                                    height: 0,
                                  ),
                            user['hasSentFriendRequestToYou']
                                ? NiceButton(
                                    onPressed: () {
                                      acceptFriendRequest();
                                    },
                                    child: Text('Accept'),
                                  )
                                : SizedBox(
                                    height: 0,
                                  ),
                            !user['hasSentFriendRequestToYou'] &&
                                    !user['hasSentFriendRequestToYou'] &&
                                    !user['hasFriendRequestFromYou'] &&
                                    !user['isFriendWithYou']
                                ? NiceButton(
                                    onPressed: () {
                                      sendFriendRequest();
                                    },
                                    child: Text('Add friend'),
                                  )
                                : SizedBox(
                                    height: 0,
                                  ),
                          ],
                        )
                      : NiceButton(
                          bgColor: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          onPressed: () {
                            print("tapped");
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.share),
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text('Share profile'),
                              ),
                            ],
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

  Widget getUserInfoBlock(bool isMe, List roles) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(10),
        side: BorderSide(
          color: Colors.white70,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            BlackTitle(
              title: user['name'],
            ),
            ...roles,
            SizedBox(
              height: 10,
            ),
            Row(
              children: <Widget>[
                Text(
                  user['gender'] + ', ',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                Text(
                  user['country'],
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            Text(
              '(Member since ' + user['member_since'] + ')',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            isMe
                ? SizedBox(
                    height: 30,
                    child: Text(user['email']),
                  )
                : SizedBox(
                    height: 10,
                  ),
            Row(
              children: <Widget>[
                // Expanded(
                //   child: user['avatar'] == null
                //       ? Text('Loading')
                //       : UserAvatar(
                //           jsonAvatar: user['avatar'],
                //         ),
                // ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ProfileInfoRow(
                      image: Bot(user['level']['value']),
                      title: "Level",
                      value: user['level']['value'].toString() +
                          ' (' +
                          user['level']['name'] +
                          ')',
                    ),
                    ProfileInfoRow(
                      image: Icon(
                        Icons.thumb_up,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: "Likes",
                      value: user['likes_count'].toString(),
                    ),
                    // ProfileInfoRow(
                    //   image: Icon(
                    //     Icons.card_giftcard,
                    //     color: Theme.of(context).primaryColor,
                    //   ),
                    //   title: user['sentgifts_count'].toString(),
                    //   value: "Gifts sent",
                    // ),
                    ProfileInfoRow(
                      image: Icon(
                        Icons.remove_red_eye,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: user['footprints_count'].toString(),
                      value: "Footprints",
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getAdditionalOptions(bool isMe) {
    return isMe
        ? SizedBox(
            height: 0,
          )
        : Card(
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 10,
                bottom: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 25,
                    child: SecondaryTitle(
                      title: "Additional options",
                    ),
                  ),
                  SizedBox(
                    height: 35,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.only(left: 5, right: 5)),
                      onPressed: () {
                        Get.toNamed(TRANSFER_SCREEN, arguments: username);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Transfer credits'),
                          Icon(Icons.attach_money),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 35,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.only(left: 5, right: 5)),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Send Email'),
                          Icon(Icons.email),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

class ProfileInfo extends StatelessWidget {
  ProfileInfo({this.title, this.count});

  final int count;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          this.count.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          this.title,
        ),
      ],
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  final image;
  final title;
  final value;

  ProfileInfoRow({this.image, this.title, this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          this.image,
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(title),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
