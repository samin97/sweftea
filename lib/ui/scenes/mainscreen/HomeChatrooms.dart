import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swfteaproject/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:swfteaproject/providers/SwfTeaController.dart';
import 'package:swfteaproject/ui/widgets/generic/dialougeBox.dart';
import 'package:swfteaproject/ui/widgets/textformfield.dart';
import 'package:swfteaproject/utlis/ApiProvider.dart';
import 'package:swfteaproject/utlis/Replacer.dart';

class HomeChatrooms extends StatelessWidget {
  final Controller controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return ListView(
      key: PageStorageKey(context),
      children: <Widget>[
        createChatRoom(context),
        Divider(
          height: 1,
        ),
        searchRoom(context),
        Divider(
          height: 1,
        ),
        FavouriteRooms(),
        Divider(
          height: 1,
        ),
        OfficialRooms(),
        Divider(
          height: 1,
        ),
        RecentRooms(),
        Divider(
          height: 1,
        ),
        GameRooms(),
        Divider(
          height: 1,
        ),
        TrendingRooms(),
      ],
    );
  }

  Widget createChatRoom(BuildContext context) {
    String title = '', description = '';
    return InkWell(
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        color: Theme.of(context).primaryColor,
        height: 40,
        child: GestureDetector(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Create a chatroom',
                style: TextStyle(color: Colors.white),
              ),
              Icon(
                Icons.add,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        Get.dialog(
          CustomDialog(
            title: "Create chatroom",
            child: Flexible(
              child: ListView(
                children: <Widget>[
                  AppTextInputField(
                    hint: "Name",
                    textEditingController: TextEditingController(),
                    icon: Icons.create,
                    elevation: false,
                    onTextChange: (value) {
                      title = value;
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  AppTextInputField(
                    hint: "Description",
                    textEditingController: TextEditingController(),
                    elevation: false,
                    maxLine: 5,
                    onTextChange: (value) {
                      description = value;
                    },
                  ),
                ],
              ),
            ),
            onSubmit: () async {
              var response = await CallApi(context).postDataFuture(
                {
                  "name": title,
                  "description": description,
                },
                "chatroom/create",
              );
              dynamic data = json.decode(response.body);
              if (data['error'] ?? true) {
                Get.dialog(
                  CustomDialog(
                    title: "Error",
                    child: Center(
                      child: Text(data['message']),
                    ),
                  ),
                );
              } else {
                Get.dialog(
                  CustomDialog(
                    title: "Success",
                    child: Center(
                      child: Text(data['message']),
                    ),
                    onSubmit: () {
                      http.get(
                        BASE_URL + 'chatrooms/favourites',
                        headers: {
                          "Content-type": "application/json",
                          "Accept": "application/json",
                          "Authorization": "Bearer " + controller.user.token,
                        },
                      ).then((value) {
                        List<dynamic> body = json.decode(value.body).toList();
                        controller.clearFavouritesRoom();
                        body.forEach((element) {
                          controller.setFavouriteChatrooms(element);
                        });
                      });
                    },
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget searchRoom(BuildContext context) {
    String searchText = '';
    return InkWell(
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        color: Theme.of(context).primaryColor,
        height: 40,
        child: GestureDetector(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Search rooms',
                style: TextStyle(color: Colors.white),
              ),
              Icon(
                Icons.search,
                color: Colors.white,
              )
            ],
          ),
        ),
      ),
      onTap: () {
        Get.dialog(
          CustomDialog(
            title: "Search chatroom",
            buttonText: "Search",
            child: Column(
              children: <Widget>[
                AppTextInputField(
                  onTextChange: (value) {
                    searchText = value;
                  },
                  elevation: false,
                  hint: "Chatroom name",
                  textEditingController: TextEditingController(
                    text: searchText,
                  ),
                  icon: Icons.people,
                ),
              ],
            ),
            onSubmit: () async {
              // Get.back();
              var response = await CallApi(context).postDataFuture(
                {
                  "search": searchText,
                },
                "chatroom/search",
              );
              List<Widget> results = [];
              dynamic res = json.decode(response.body);
              for (var e in res['data']) {
                results.add(
                  Column(
                    children: <Widget>[
                      InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    e['name'],
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                e['members_count'].toString() +
                                    "/" +
                                    e['capacity'].toString(),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          Get.back();
                          controller.joinChatroom(
                              chatroomid: e['id'].toString(),
                              chatroomname: e['name']);
                        },
                      ),
                      Divider(),
                    ],
                  ),
                );
              }
              Get.dialog(
                CustomDialog(
                  title: "Results",
                  child: Flexible(
                    child: ListView(
                      children: <Widget>[...results],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class FavouriteRooms extends StatelessWidget {
  final Controller controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          color: Theme.of(context).primaryColor,
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    icon: controller.favouriteRoomExpanded
                        ? Icon(
                            Icons.clear,
                            color: Colors.white,
                          )
                        : Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                    onPressed: () {
                      controller.toogleFavouriteRoom();
                    },
                  ),
                  Text(
                    'Favourite rooms',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
                onPressed: () {
                  _refreshFavouritesChatrooms(context);
                },
              ),
            ],
          ),
        ),
        Column(
          children: controller.favouriteRoomExpanded
              ? controller.favouriteChatrooms.map((element) {
                  return ChatroomTile(
                    room: element,
                    removeFavourite: true,
                    addFavourite: false,
                  );
                }).toList()
              : <Widget>[],
        ),
      ],
    );
  }

  void _refreshFavouritesChatrooms(BuildContext context) async {
    controller.clearFavouritesRoom();
    final res = await CallApi(context).getDataFuture("chatrooms/favourites");
    List<dynamic> body = json.decode(res.body).toList();
    body.forEach((element) {
      controller.setFavouriteChatrooms(element);
    });
  }
}

class OfficialRooms extends StatelessWidget {
  final Controller controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          color: Theme.of(context).primaryColor,
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    icon: controller.officialRoomExpanded
                        ? Icon(
                            Icons.clear,
                            color: Colors.white,
                          )
                        : Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                    onPressed: () {
                      controller.toogleOfficialRoom();
                    },
                  ),
                  Text(
                    'Official rooms',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
                onPressed: () {
                  _refreshOfficialChatrooms(context);
                },
              ),
            ],
          ),
        ),
        Column(
          children: controller.officialRoomExpanded
              ? controller.officialChatrooms.map((element) {
                  return ChatroomTile(
                    room: element,
                  );
                }).toList()
              : <Widget>[],
        ),
      ],
    );
  }

  void _refreshOfficialChatrooms(BuildContext context) async {
    controller.clearOfficialRoom();
    final res = await CallApi(context).getDataFuture("chatrooms/official");
    List<dynamic> body = json.decode(res.body).toList();
    body.forEach((element) {
      controller.setOfficialChatrooms(element);
    });
  }
}

class RecentRooms extends StatelessWidget {
  final Controller controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          color: Theme.of(context).primaryColor,
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    icon: controller.recentRoomExpanded
                        ? Icon(
                            Icons.clear,
                            color: Colors.white,
                          )
                        : Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                    onPressed: () {
                      controller.toogleRecentRoom();
                    },
                  ),
                  Text(
                    'Recent rooms',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
                onPressed: () {
                  _refreshChatrooms(context);
                },
              ),
            ],
          ),
        ),
        Column(
          children: controller.recentRoomExpanded
              ? controller.recentChatrooms.map((element) {
                  return ChatroomTile(
                    room: element,
                  );
                }).toList()
              : <Widget>[],
        ),
      ],
    );
  }

  void _refreshChatrooms(BuildContext context) async {
    controller.clearRecentRoom();
    final res = await CallApi(context).getDataFuture("chatrooms/recent");
    List<dynamic> body = json.decode(res.body).toList();
    body.forEach((element) {
      controller.setRecentChatrooms(element);
    });
  }
}

class GameRooms extends StatelessWidget {
  final Controller controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          color: Theme.of(context).primaryColor,
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    icon: controller.gameRoomExpanded
                        ? Icon(
                            Icons.clear,
                            color: Colors.white,
                          )
                        : Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                    onPressed: () {
                      controller.toogleGameRoom();
                    },
                  ),
                  Text(
                    'Game rooms',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
                onPressed: () {
                  _refreshChatrooms(context);
                },
              ),
            ],
          ),
        ),
        Column(
          children: controller.gameRoomExpanded
              ? controller.gameChatrooms.map((element) {
                  return ChatroomTile(
                    room: element,
                  );
                }).toList()
              : <Widget>[],
        ),
      ],
    );
  }

  void _refreshChatrooms(BuildContext context) async {
    controller.clearGameRoom();
    final res = await CallApi(context).getDataFuture("chatrooms/gaming");
    List<dynamic> body = json.decode(res.body).toList();
    body.forEach((element) {
      controller.setGameChatrooms(element);
    });
  }
}

class TrendingRooms extends StatelessWidget {
  final Controller controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          color: Theme.of(context).primaryColor,
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    icon: controller.trendingRoomExpanded
                        ? Icon(
                            Icons.clear,
                            color: Colors.white,
                          )
                        : Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                    onPressed: () {
                      controller.toogleTrendingRoom();
                    },
                  ),
                  Text(
                    'Trending rooms',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
                onPressed: () {
                  _refreshChatrooms(context);
                },
              ),
            ],
          ),
        ),
        Column(
          children: controller.trendingRoomExpanded
              ? controller.tredingChatrooms.map((element) {
                  return ChatroomTile(
                    room: element,
                  );
                }).toList()
              : <Widget>[],
        ),
      ],
    );
  }

  void _refreshChatrooms(BuildContext context) async {
    controller.clearTrendingRoom();
    final res = await CallApi(context).getDataFuture("chatrooms/trending");
    List<dynamic> body = json.decode(res.body).toList();
    body.forEach((element) {
      controller.setTrendingChatrooms(element);
    });
  }
}
