import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_pusher/pusher.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:swfteaproject/constants/constants.dart';
import 'package:swfteaproject/model/AppTab.dart';
import 'package:swfteaproject/model/Emoji.dart';
import 'package:swfteaproject/model/EmojiCategory.dart';
import 'package:swfteaproject/model/Level.dart';
import 'package:swfteaproject/model/User.dart';
import 'package:swfteaproject/model/Message.dart';
import 'package:swfteaproject/model/MessageContainer.dart';
import 'package:swfteaproject/ui/widgets/generic/dialougeBox.dart';
import 'package:swfteaproject/utlis/ApiProvider.dart';

class Controller extends GetxController {
  // Init pusher on init
  Controller({User user}) {
    this.setUser(user: user);
    try {
      _initPusher();
      _fetchBackground();
    } catch (e) {
      print(e);
    }
  }
  // For current user
  User user;
  // For unread notifications
  int unreadnotification = 0;
  // for unread account histories
  int unreadhistories = 0;
  // For tab
  List<AppTab> tabs = [
    new AppTab('home', 'Home', 'home', active: true),
    new AppTab('chatrooms', 'Chatrooms', 'chatrooms', active: false),
  ];
  // Audio player
  AudioPlayer audioPlayer = new AudioPlayer();
  bool isAudioPlaying = false;
  int audioPlayingHash = 0;
  Duration position = new Duration();
  Duration duration = new Duration();
  // For all friends
  List<User> friends = [];
  int focusedFriend = -1;

  // Storage
  final LocalStorage storage = new LocalStorage('swftea_app');
  // For all tabs
  PageController tabController = PageController(
    initialPage: 0,
    keepPage: false,
  );
  ItemScrollController tabBarController = ItemScrollController();

  var favouriteChatrooms = List<dynamic>();
  var officialChatrooms = List<dynamic>();
  var recentChatrooms = List<dynamic>();
  var gameChatrooms = List<dynamic>();
  var tredingChatrooms = List<dynamic>();

  // Chatrooms Page
  bool favouriteRoomExpanded = false;
  bool officialRoomExpanded = true;
  bool recentRoomExpanded = false;
  bool gameRoomExpanded = true;
  bool trendingRoomExpanded = false;

  // Keyboard open
  bool keyboardOpen = false;

  // Audio action
  getAudio(SwfTeaMessage message) async {
    var url = message.extrainfo['recording'];
    bool isLocal = ((message.extrainfo['type'] ?? "URL") == "LOCAL");
    // If is Playing..
    if (message.hashCode == this.audioPlayingHash) {
      if (this.isAudioPlaying) {
        var res = await this.audioPlayer.pause();
        if (res == 1) {
          this.isAudioPlaying = false;
        }
      } else {
        var res = await this.audioPlayer.resume();
        if (res == 1) {
          this.isAudioPlaying = true;
        }
      }
    } else {
      this.audioPlayingHash = message.hashCode; // current playing hash
      if (this.isAudioPlaying) {
        audioPlayer.release();
        this.audioPlayer = AudioPlayer();
        this.duration = Duration();
        this.position = Duration();
      }
      var res = await this.audioPlayer.play(url, isLocal: isLocal);
      if (res == 1) {
        this.isAudioPlaying = true;
      }
    }
    update();
    this.audioPlayer.onDurationChanged.listen((Duration dd) {
      duration = dd;
      this.update();
    });
    audioPlayer.onAudioPositionChanged.listen((Duration dd) {
      position = dd;
      this.update();
    });
    audioPlayer.onPlayerCompletion.listen((event) {
      isAudioPlaying = false;
      position = duration;
      update();
    });
  }

  setKeyboardStatus(bool status) {
    this.keyboardOpen = status;
  }

  // Set user
  setUser({User user}) {
    this.user = user;
  }

  // send message
  sendMessage({@required AppTab appTab}) async {
    String text = appTab.textBox.text.trim();
    if (text.length < 1) {
      return;
    }
    if (text.startsWith("!")) {
    } else if (text.startsWith("/")) {
    } else {
      appTab.messages.insert(
        0,
        new SwfTeaMessage(
          formattedtext: text,
          type: "instantmessage",
          sender: this.user,
          extrainfo: {
            "emojies": this.user.emojies,
            "type": "asset",
            "images": appTab.selectedimages
          },
        ),
      );
    }

    if (appTab.messageContainer.type == 'chatroom') {
      if (appTab.selectedimages.length > 0) {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(BASE_URL + 'chatroom/sendMessage'),
        );
        for (var img in appTab.selectedimages) {
          request.files.add(
            await http.MultipartFile.fromPath('images[]', img),
          );
        }
        request.fields['type'] = 'send message';
        request.fields['message'] = text;
        request.fields['chatroom_id'] = appTab.messageContainer.id.toString();
        request.headers.addAll({
          "Content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer " + user.token
        });
        request.send();
      } else {
        CallApi(Get.context).postData(
          {
            "type": "send message",
            "message": text,
            "chatroom_id": appTab.messageContainer.id,
          },
          "chatroom/sendMessage",
        );
      }
    }
    // For thread
    if (appTab.messageContainer.type == 'thread') {
      if (appTab.selectedimages.length > 0) {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(BASE_URL + 'groupchat/sendMessage'),
        );
        for (var img in appTab.selectedimages) {
          request.files.add(
            await http.MultipartFile.fromPath('images[]', img),
          );
        }
        request.fields['slug'] = appTab.messageContainer.id;
        request.fields['message'] = text;
        if (appTab.messageContainer.members.length > 0) {
          request.fields['recipients'] =
              appTab.messageContainer.members[0].toString();
        }
        request.headers.addAll({
          "Content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer " + user.token
        });
        request.send();
      } else {
        var postData = {};
        if (appTab.messageContainer.members.length > 0) {
          postData = {
            "slug": appTab.messageContainer.id,
            "message": text,
            "recipients": appTab.messageContainer.members[0],
          };
        } else {
          postData = {
            "slug": appTab.messageContainer.id,
            "message": text,
          };
        }
        CallApi(Get.context).postData(
          postData,
          "groupchat/sendMessage",
        );
      }
    }
    appTab.selectedimages = [];
    update();
  }

  // send recording
  sendRecording({@required AppTab appTab, @required String path}) async {
    if (appTab.messageContainer.type == 'chatroom') {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(BASE_URL + 'chatroom/sendMessage'),
      );
      request.files.add(
        await http.MultipartFile.fromPath('recording', path),
      );
      request.fields['chatroom_id'] = appTab.messageContainer.id.toString();
      request.headers.addAll({
        "Content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + user.token
      });
      request.send();
      // Add to my tab
      appTab.messages.insert(
        0,
        SwfTeaMessage(
          type: 'recordMessage',
          formattedtext: "A",
          extrainfo: {"recording": path, "type": "LOCAL"},
          sender: this.user,
        ),
      );
      update();
    }
  }

  void fetchFriends({bool showLoading = false}) async {
    if (showLoading) {
      Get.dialog(LoadingDialog());
    }
    http.get(
      BASE_URL + 'user/friends',
      headers: {
        "Content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + this.user.token,
      },
    ).then(
      (value) {
        this.friends.clear();
        print(value.body + "ya data k aayo ta fetch friends ma");
        List<dynamic> body = json.decode(value.body)['data'].toList();
        body.forEach(
          (friend) {
            this.friends.add(
                  new User(
                    friend['id'],
                    friend['username'],
                    '',
                    friend['name'],
                    friend['profile_picture'],
                    friend['main_status'],
                    new Level(
                      friend['level']['name'],
                      friend['level']['value'],
                    ),
                    '',
                    color: friend['color'],
                    extrainfo: {
                      "presence": friend['presence'],
                      "commonid": friend['friendship']['id']
                    },
                  ),
                );
          },
        );
        this.friends.sort((a, b) =>
            a.extrainfo['presence'].compareTo(b.extrainfo['presence']));
        if (showLoading) {
          Get.back();
        }
        update();
      },
    );
  }

  // Background action
  Future<void> _fetchBackground() async {
    print(this.user.token);
    http.get(
      SYNC_URL,
      headers: {
        "Content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + this.user.token,
      },
    ).then((value) {
      var details = json.decode(value.body);

      List<Emoji> emojies = [];
      List<EmojiCategory> emojiescategory = [];
      if (details["emoticons"].length != 0) {
        for (var emoji in details['emoticons'].keys) {
          emojies.add(
            new Emoji(
              name: details['emoticons'][emoji]['name'],
              url: details['emoticons'][emoji]['img'],
              category: details['emoticons'][emoji]['category'],
            ),
          );
        }
        user.setEmojies(emojies);
      }
      if (details["emojies_categories"].length != 0) {
        for (var emojicategory in details['emojies_categories']) {
          emojiescategory.add(
            new EmojiCategory(
              name: emojicategory['name'],
              icon: emojicategory['icon'],
              iconType: emojicategory['iconType'],
            ),
          );
        }
        user.setEmojiesCategories(emojiescategory);
      }
    });

    this.fetchFriends();

    http.get(
      BASE_URL + 'chatrooms/favourites',
      headers: {
        "Content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + this.user.token,
      },
    ).then((value) {
      print("value print " + value.body);
      List body = json.decode(value.body);
      // List<dynamic> body = json.decode(value.body).toList();
      body.forEach((element) {
        this.setFavouriteChatrooms(element);
      });
    });

    http.get(
      BASE_URL + 'chatrooms/official',
      headers: {
        "Content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + this.user.token,
      },
    ).then((value) {
      List<dynamic> body = json.decode(value.body);
      body.forEach((element) {
        this.setOfficialChatrooms(element);
      });
    });

    http.get(
      BASE_URL + 'chatrooms/recent',
      headers: {
        "Content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + this.user.token,
      },
    ).then((value) {
      // List<dynamic> body = json.decode(value.body).toList();
      print(value.body);
      List<dynamic> body = json.decode(value.body);
print(body);
print("ye recent ka he");
      body.forEach((element) {
        this.setRecentChatrooms(element);
      });
    });

    http.get(
      BASE_URL + 'chatrooms/gaming',
      headers: {
        "Content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + this.user.token,
      },
    ).then((value) {
      List<dynamic> body = json.decode(value.body).toList();
     print(body);
     print("ye gaming ka he");
      body.forEach((element) {
        this.setGameChatrooms(element);
      });
    });

    http.get(
      BASE_URL + 'chatrooms/trending',
      headers: {
        "Content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + this.user.token,
      },
    ).then((value) {
      print("chatrooms trending");
      print(value.body);
      List<dynamic> body = json.decode(value.body);
      body.forEach((element) {
        this.setTrendingChatrooms(element);
      });
    });
  }

  // Add tab
  joinChatroom(
      {@required String chatroomid, String chatroomname = "test"}) async {
    String chatroom = 'private-chatroom-' + chatroomid.toString();
    String chatroomnotification = 'private-notification-chatroom-' +
        chatroomid.toString() +
        '-' +
        this.user.id.toString();
    List<AppTab> appTabs =
        tabs.where((element) => element.key == chatroom).toList();
    if (appTabs.isEmpty) {
      // Join chatroom REQUEST API
      var res = await CallApi(Get.context)
          .getDataFuture('chatroom/' + chatroomid.toString() + '/join');
      var roominfo = jsonDecode(res.body);
      if (roominfo['error'] ?? false) {
        Get.dialog(
          CustomDialog(
            title: "Error",
            child: Center(
              child: Text(
                roominfo['message'],
              ),
            ),
          ),
        );
      } else {
        Channel _channel = await Pusher.subscribe(chatroom); // subscribe pusher
        Channel _notificationchannel =
            await Pusher.subscribe(chatroomnotification); // notification
        /* Bind to event */
        _channel.bind(
          'newMessage',
          (event) {
            String _channelName = event.channel;
            // Get actual tab of channel
            List<AppTab> _channelAppTabs =
                tabs.where((element) => element.key == _channelName).toList();
            int _chatroomIndex =
                _channelAppTabs.isEmpty ? -1 : tabs.indexOf(_channelAppTabs[0]);
            if (_chatroomIndex > 0) {
              // tab exists
              // All good?
              dynamic details = json.decode(event.data);
              details['message']['sender'] = details['sender'];
              // message
              dynamic message = details['message'];
              SwfTeaMessage swfTeaMessage = new SwfTeaMessage(
                formattedtext: message['formatted_text'],
                type: message['type'],
                bot: message['bot'] ?? '',
                extrainfo: message['extra_info'] ?? {},
              ); // compose swftea mesasge
              if (message['type'] == 'message' ||
                  message['type'] == 'recordMessage') {
                User sender = new User(
                  message['sender']['id'],
                  message['sender']['username'],
                  message['sender']['email'],
                  message['sender']['name'],
                  message['sender']['profile_picture'],
                  message['sender']['main_status'],
                  new Level(
                    message['sender']['level']['name'],
                    message['sender']['level']['value'],
                  ),
                  '',
                  color: message['sender']['color'],
                );
                swfTeaMessage.setSender(sender);
              } // For normal message
              bool appendmessage = true;
              if (message['type'] == 'message' ||
                  message['type'] == 'roomjoin' ||
                  message['type'] == 'recordMessage' ||
                  message['type'] == 'roomleave') {
                // for specifit types
                if ((message['sender']['id'] ?? -1) == this.user.id) {
                  appendmessage = false;
                }
              }
              if (appendmessage) {
                if (tabs[_chatroomIndex].messages.length > 50) {
                  tabs[_chatroomIndex].messages.removeAt(50);
                }
                tabs[_chatroomIndex]
                    .messages
                    .insert(0, swfTeaMessage); // Append message
                if (this.tabController.page.round() != _chatroomIndex) {
                  // if is not focused
                  tabs[_chatroomIndex].blinking = true;
                }
                update(); // Finally update
              }
            }
            // Is focused to same tab??
          },
        );
        /* End bind to event */
        /* Bind notification event */
        _notificationchannel.bind('message', (event) {
          var notification = json.decode(event.data);
          int chatroomId = int.parse(event.channel
              .split("private-notification-chatroom-")[1]
              .split("-")[0]
              .split('-')[0]);
          AppTab appTab = this.tabs.firstWhere((element) =>
              element.key == "private-chatroom-" + chatroomId.toString());
          int tabindex = this.tabs.indexOf(appTab);
          if (notification['type'] == "kicked") {
            this.closeTab(id: chatroomId.toString());
          } else {
            if (tabindex != -1) {
              SwfTeaMessage swfTeaMessage = new SwfTeaMessage(
                formattedtext: notification['message'] ?? "Error",
                type: notification['type'],
                extrainfo: notification['extra_info'] ?? {},
              ); // compose swftea mesasge
              this.tabs[tabindex].messages.insert(0, swfTeaMessage);
            }
            update();
          }
        });
        /* End notification event */
        AppTab appTab = new AppTab(
          'chatroom',
          chatroomname,
          chatroom,
          messageContainer: new MessageContainer(
            creator: 'username',
            description: 'description',
            name: chatroomname,
            type: 'chatroom',
            id: chatroomid,
            members: [
              'A',
              'B',
              'C',
              user.username,
            ],
          ),
        ); // app tab
        appTab.messages.insert(
            0,
            new SwfTeaMessage(
              type: "info",
              formattedtext: "Welcome to " + chatroomname,
            ));
        appTab.messages.insert(
            0,
            new SwfTeaMessage(
              type: "info",
              formattedtext: "This room is managed by " +
                  roominfo['chatroom']['user']['username'],
            ));
        List<String> members = [];
        for (var element in roominfo['chatroom']['members']) {
          members.add(element['username']);
        }
        appTab.messages.insert(
            0,
            new SwfTeaMessage(
              type: "info",
              formattedtext: "Currently in this room: " + members.join(", "),
            ));
        // For announcement
        if (roominfo['chatroom']['announcement'] != null) {
          appTab.messages.insert(
            0,
            new SwfTeaMessage(
              type: "announcement",
              formattedtext: roominfo['chatroom']['announcement'],
            ),
          );
        }
        // For game // LOWCARD
        if (roominfo['chatroom']['game'] != null) {
          if (roominfo['chatroom']['game']['game'] == 'lowcard') {
            switch (roominfo['chatroom']['game']['phase']) {
              case 0:
                appTab.messages.insert(
                  0,
                  new SwfTeaMessage(
                    type: "game",
                    bot: "Lowcard Bot",
                    extrainfo: {},
                    formattedtext:
                        'Play LowCard. Type !start to start a new game, !start < amount > for custom entry.',
                  ),
                );
                break;
              case 1:
                appTab.messages.insert(
                  0,
                  new SwfTeaMessage(
                    type: "game",
                    bot: "Lowcard Bot",
                    extrainfo: {},
                    formattedtext:
                        'LowCard game is running. !j to join. Cost credits ' +
                            roominfo['chatroom']['game']['amount'].toString() +
                            '. [30 sec]',
                  ),
                );
                break;
              case 2:
                appTab.messages.insert(
                  0,
                  new SwfTeaMessage(
                    type: "game",
                    bot: "Lowcard Bot",
                    extrainfo: {},
                    formattedtext:
                        'LowCard game is running. The last man standing wins all!',
                  ),
                );
                break;
              default:
                appTab.messages.insert(
                  0,
                  new SwfTeaMessage(
                    type: "game",
                    bot: "Lowcard Bot",
                    extrainfo: {},
                    formattedtext:
                        'LowCard game is running. The last man standing wins all!',
                  ),
                );
            }
          }
          // For game // Cricket
          if (roominfo['chatroom']['game']['game'] == 'cricket') {
            switch (roominfo['chatroom']['game']['phase']) {
              case 0:
                appTab.messages.insert(
                  0,
                  new SwfTeaMessage(
                    type: "game",
                    bot: "Cricket Bot",
                    extrainfo: {},
                    formattedtext:
                        'Play Cricket. Type !start to start a new game, !start < amount > for custom entry.',
                  ),
                );
                break;
              case 1:
                appTab.messages.insert(
                  0,
                  new SwfTeaMessage(
                    type: "game",
                    bot: "Cricket Bot",
                    extrainfo: {},
                    formattedtext:
                        'Cricket game is running. !j to join. Cost credits ' +
                            roominfo['chatroom']['game']['amount'].toString() +
                            '. [30 sec]',
                  ),
                );
                break;
              case 2:
                appTab.messages.insert(
                  0,
                  new SwfTeaMessage(
                    type: "game",
                    bot: "Cricket Bot",
                    extrainfo: {},
                    formattedtext:
                        'LowCard game is running. The last man standing wins all!',
                  ),
                );
                break;
              default:
                appTab.messages.insert(
                  0,
                  new SwfTeaMessage(
                    type: "game",
                    bot: "Cricket Bot",
                    extrainfo: {},
                    formattedtext:
                        'LowCard game is running. The last man standing wins all!',
                  ),
                );
            }
          }
          // For game DICE
          if (roominfo['chatroom']['game']['game'] == 'dice-1') {
            switch (roominfo['chatroom']['game']['phase']) {
              case 0:
                appTab.messages.insert(
                  0,
                  new SwfTeaMessage(
                    type: "game",
                    bot: "Guess Bot",
                    extrainfo: {},
                    formattedtext:
                        'Play Guess. Type !start to start a new round.',
                  ),
                );
                break;
              case 1:
                appTab.messages.insert(
                  0,
                  new SwfTeaMessage(
                    type: "game",
                    bot: "Guess Bot",
                    extrainfo: {},
                    formattedtext: 'Guess game is running.',
                  ),
                );
                break;
              case 2:
                appTab.messages.insert(
                  0,
                  new SwfTeaMessage(
                    type: "game",
                    bot: "Guess Bot",
                    extrainfo: {},
                    formattedtext: 'Guess game is running.',
                  ),
                );
                break;
              case 3:
                appTab.messages.insert(
                  0,
                  new SwfTeaMessage(
                    type: "game",
                    bot: "Guess Bot",
                    extrainfo: {},
                    formattedtext: 'Guess game is running.',
                  ),
                );
                break;
            }
          }
          // For game LUCKY 7
          if (roominfo['chatroom']['game']['game'] == 'lucky7') {
            switch (roominfo['chatroom']['game']['phase']) {
              case 0:
                appTab.messages.insert(
                  0,
                  new SwfTeaMessage(
                    type: "game",
                    bot: "Lucky 7",
                    extrainfo: {},
                    formattedtext:
                        'Play Lucky 7. Type !start to start a new round.',
                  ),
                );
                break;
              case 1:
                appTab.messages.insert(
                  0,
                  new SwfTeaMessage(
                    type: "game",
                    bot: "Lucky 7",
                    extrainfo: {},
                    formattedtext: 'Lucky 7 game is running.',
                  ),
                );
                break;
              case 2:
                appTab.messages.insert(
                  0,
                  new SwfTeaMessage(
                    type: "game",
                    bot: "Lucky 7",
                    extrainfo: {},
                    formattedtext: 'Lucky 7 game is running.',
                  ),
                );
                break;
              case 3:
                appTab.messages.insert(
                  0,
                  new SwfTeaMessage(
                    type: "game",
                    bot: "Lucky 7",
                    extrainfo: {},
                    formattedtext: 'Lucky 7 game is running.',
                  ),
                );
                break;
            }
          }
        }

        appTab.setChannel(_channel); // set channel
        appTab.setNotificationChannel(
            _notificationchannel); // set notification channel
        this.tabs.add(appTab); // append tab
        int chatroomIndex = this.tabs.indexOf(appTab); // Index of tab
        // Focus chatroom textbox
        appTab.textFocusNode.requestFocus();
        update();

        this.tabController.animateToPage(
              chatroomIndex,
              curve: Curves.easeIn,
              duration: Duration(
                milliseconds: 500,
              ),
            );
      }
      // END JOIN REQUEST
    } else {
      int chatroomIndex = tabs.indexOf(appTabs[0]); // first tab
      this.tabController.animateToPage(
            chatroomIndex,
            duration: Duration(milliseconds: 300),
            curve: Curves.fastLinearToSlowEaseIn,
          );
      appTabs[0].textFocusNode.requestFocus();
    }
  }

  joinThread(
      {@required String threadid,
      String threadname = "test",
      String receiverid = '0',
      dynamic extrainfo,
      bool focus = true}) async {
    String thread = 'private-thread-' + threadid.toString();
    String threadnotification = 'private-notification-thread-' +
        threadid.toString() +
        '-' +
        this.user.id.toString();
    List<AppTab> appTabs =
        tabs.where((element) => element.key == thread).toList();
    if (appTabs.isEmpty) {
      Channel _channel = await Pusher.subscribe(thread); // subscribe pusher
      Channel _notificationchannel =
          await Pusher.subscribe(threadnotification); // notification
      /* Bind to event */
      _channel.bind(
        'newMessage',
        (event) {
          String _channelName = event.channel;
          // Get actual tab of channel
          List<AppTab> _channelAppTabs =
              tabs.where((element) => element.key == _channelName).toList();
          int _chatroomIndex =
              _channelAppTabs.isEmpty ? -1 : tabs.indexOf(_channelAppTabs[0]);
          if (_chatroomIndex > 0) {
            // tab exists
            // All good?
            dynamic details = json.decode(event.data);
            // details['message']['sender'] = details['sender'];
            // message
            SwfTeaMessage swfTeaMessage = new SwfTeaMessage(
              formattedtext: details['formatted_text'],
              type: details['type'],
              bot: '',
              extrainfo: details['extra_info'] ?? {},
            ); // compose swftea mesasge
            if (details['type'] == 'message' ||
                details['type'] == 'recordMessage') {
              User sender = new User(
                details['sender']['id'],
                details['sender']['username'],
                details['sender']['email'],
                details['sender']['name'],
                details['sender']['profile_picture'],
                details['sender']['main_status'],
                new Level(
                  details['sender']['level']['name'],
                  details['sender']['level']['value'],
                ),
                '',
                color: details['sender']['color'],
              );
              swfTeaMessage.setSender(sender);
            } // For normal message
            bool appendmessage = true;
            if (details['type'] == 'message' ||
                details['type'] == 'roomjoin' ||
                details['type'] == 'roomleave') {
              // for specifit types
              if ((details['sender']['id'] ?? -1) == this.user.id) {
                appendmessage = false;
              }
            }
            if (appendmessage) {
              tabs[_chatroomIndex]
                  .messages
                  .insert(0, swfTeaMessage); // Append message
              if ((this.tabController.page ?? 0).round() != _chatroomIndex) {
                // if is not focused
                tabs[_chatroomIndex].blinking = true;
              }
              update(); // Finally update
            }
          }
          // Is focused to same tab??
        },
      );
      /* End bind to event */
      /* Bind notification event */
      _notificationchannel.bind('message', (event) {
        var notification = json.decode(event.data);
        int threadiid = int.parse(event.channel
            .split("private-notification-thread-")[1]
            .split("-")[0]
            .split('-')[0]);
        AppTab appTab = this.tabs.firstWhere((element) =>
            element.key == "private-chatroom-" + threadiid.toString());
        int tabindex = this.tabs.indexOf(appTab);
        if (notification['type'] == "kicked") {
          this.closeTab(id: threadid.toString());
        } else {
          if (tabindex != -1) {
            SwfTeaMessage swfTeaMessage = new SwfTeaMessage(
              formattedtext: notification['message'] ?? "Error",
              type: notification['type'],
              extrainfo: notification['extra_info'] ?? {},
            ); // compose swftea mesasge
            this.tabs[tabindex].messages.insert(0, swfTeaMessage);
          }
          update();
        }
      });
      /* End notification event */
      List members = [];
      AppTab appTab = new AppTab(
        'thread',
        threadname,
        thread,
        blinking: true,
        active: false,
        messageContainer: new MessageContainer(
          creator: 'username',
          description: 'description',
          name: threadname,
          type: 'thread',
          id: threadid,
          members: members,
        ),
      ); // app tab
      if (int.parse(receiverid) > 0) {
        members.add(int.parse(receiverid));
        if (extrainfo != null) {
          if ((extrainfo['message'] ?? null) != null) {
            appTab.messages.insert(
              0,
              new SwfTeaMessage(
                type: "info",
                formattedtext: "This user sends you new message: '" +
                    extrainfo['message'] +
                    "'",
              ),
            );
          }
        }
      }
      if (int.parse(receiverid) == 0 && extrainfo != null) {
        // Group chat
        if (extrainfo['invited_by'] == this.user.username) {
          appTab.messages.insert(
            0,
            new SwfTeaMessage(
              type: "info",
              formattedtext:
                  "You have created a group chat. Current participants: " +
                      extrainfo['members'],
            ),
          );
        } else {
          appTab.messages.insert(
            0,
            new SwfTeaMessage(
              type: "info",
              formattedtext: "You have been invited to a group chat by " +
                  extrainfo['invited_by'] +
                  ". Current participants: " +
                  extrainfo['members'],
            ),
          );
        }
      }
      appTab.setChannel(_channel); // set channel
      appTab.setNotificationChannel(
          _notificationchannel); // set notification channel
      this.tabs.add(appTab); // append tab
      update();
      if (focus) {
        int chatroomIndex = this.tabs.indexOf(appTab); // Index of tab
        this.tabController.animateToPage(
              chatroomIndex,
              curve: Curves.easeIn,
              duration: Duration(
                milliseconds: 500,
              ),
            );
      }
      // END JOIN REQUEST
    } else {
      int chatroomIndex = tabs.indexOf(appTabs[0]); // first tab
      this.tabController.animateToPage(
            chatroomIndex,
            duration: Duration(milliseconds: 300),
            curve: Curves.fastLinearToSlowEaseIn,
          );
    }
  }

  // Close tab
  closeTab({String id, String type = 'chatroom', bool closeTab = true}) async {
    String key = 'private-' + type + '-' + id.toString();
    List<AppTab> _searchTabs =
        tabs.where((element) => element.key == key).toList();
    int index = _searchTabs.isEmpty ? -1 : tabs.indexOf(_searchTabs[0]);
    AppTab appTab = tabs[index];
    if (closeTab) {
      this.tabController.jumpToPage(index - 1);
      tabs.removeAt(index); // remove at index
      update();
    }
    if (appTab.type == 'chatroom' || appTab.type == 'thread') {
      if (appTab.type == 'chatroom') {
        await CallApi(Get.context)
            .getData('chatroom/' + id.toString() + '/leave');
        await Pusher.unsubscribe('private-notification-chatroom-' +
            id.toString() +
            '-' +
            this.user.id.toString()); // Unsubscribe
      }
      if (appTab.type == 'thread') {
        await CallApi(Get.context)
            .getData('groupchat/' + id.toString() + '/leave');
        await Pusher.unsubscribe('private-notification-thread-' +
            id.toString() +
            '-' +
            this.user.id.toString()); // Unsubscribe
      }
      // for messages
      appTab.channel.unbind('newMessage');
      await Pusher.unsubscribe(appTab.channel.name); // Unsubscribe
    }
  }

  //focus tab
  focusTab(int index) {
    if (this.tabController.page.round() != index) {
      this.tabBarController.scrollTo(
            index: index,
            duration: Duration(milliseconds: 1),
          );
    }
    var i = 0;
    for (AppTab appTab in this.tabs) {
      if (appTab.active) {
        this.tabs[i].active = false;
      }
      i++;
    }
    this.tabs[index].active = true;
    this.tabs[index].blinking = false;
    // Focus text field
    if (index > 1) {
      // if have focus on previous tab
      // bool hasFocusPrev = this.tabs[index - 1].textFocusNode.hasFocus;
      // // if have focus on previous tab
      // bool hasFocusNext = index < (this.tabs.length - 1)
      //     ? this.tabs[index + 1].textFocusNode.hasFocus
      //     : false;
      if (WidgetsBinding.instance.window.viewInsets.bottom > 0) {
        this.tabs[index].textFocusNode.requestFocus();
      }
    } else {
      if (this.tabs.length > 2) {
        this.tabs[2].textFocusNode.unfocus();
      }
    }
    update();
  }

  toogleFavouriteRoom() {
    this.favouriteRoomExpanded = !this.favouriteRoomExpanded;
    update();
  }

  toogleOfficialRoom() {
    this.officialRoomExpanded = !this.officialRoomExpanded;
    update();
  }

  toogleRecentRoom() {
    this.recentRoomExpanded = !this.recentRoomExpanded;
    update();
  }

  toogleGameRoom() {
    this.gameRoomExpanded = !this.gameRoomExpanded;
    update();
  }

  toogleTrendingRoom() {
    this.trendingRoomExpanded = !this.trendingRoomExpanded;
    update();
  }

  setFavouriteChatrooms(room) {
    this.favouriteChatrooms.add(room);
    update();
  }

  clearFavouritesRoom() {
    this.favouriteChatrooms.clear();
  }

  setOfficialChatrooms(room) {
    this.officialChatrooms.add(room);
    update();
  }

  clearOfficialRoom() {
    this.officialChatrooms.clear();
  }

  setRecentChatrooms(room) {
    this.recentChatrooms.add(room);
    update();
  }

  clearRecentRoom() {
    this.recentChatrooms.clear();
  }

  setGameChatrooms(room) {
    this.gameChatrooms.add(room);
    update();
  }

  clearGameRoom() {
    this.gameChatrooms.clear();
  }

  setTrendingChatrooms(room) {
    this.tredingChatrooms.add(room);
    update();
  }

  clearTrendingRoom() {
    this.tredingChatrooms.clear();
  }

  disconnectTab(AppTab appTab) {}

  Future<void> _initPusher() async {
    try {
      await Pusher.init(
        '5a55471f54de3cb06982',
        PusherOptions(
          cluster: 'ap2',
          encrypted: true,
          auth: PusherAuth(
            BROADCAST_AUTH,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer ' + this.user.token,
            },
          ),
        ),
        enableLogging: false,
      );
      // Subscribe some specific global params
      await Pusher.connect();
      // 1. Notifications
      Channel _notificationchannel = await Pusher.subscribe(
        'private-notifications-' + this.user.id.toString(),
      );
      // 2. Histories
      Channel _historieschannel = await Pusher.subscribe(
        'private-histories-' + this.user.id.toString(),
      );
      // 3. Group Chat
      Channel _chatchannel = await Pusher.subscribe(
        'private-group-chat-' + this.user.id.toString(),
      );
      // 4. Presence user
      await Pusher.subscribe('presence-users');


      // Bind notification
      _notificationchannel.bind('notifications', (event) {
        this.unreadnotification++;
        this.tabs[0].blinking = true;
        update();
        dynamic notification = json.decode(event.data)['notification'];
        if (notification['title'] == 'Account Suspended') {
          Get.offAllNamed(LOGOUT);
        }
      });

      // Bind histories
      _historieschannel.bind('histories', (event) {
        this.unreadhistories++;
        update();
      });

      // Bind incomming chats
      _chatchannel.bind('newGroup', (event) {
        var data = json.decode(event.data);
        this.joinThread(
          threadid: data['slug'],
          threadname: data['title'] ?? "Group Chat",
          extrainfo: data['extra_info'],
          focus: false,
        );
      });
    } catch (error) {}
  }
}
