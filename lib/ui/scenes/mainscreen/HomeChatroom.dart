import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:get/get.dart';
// import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:swfteaproject/constants/constants.dart';
import 'package:swfteaproject/model/AppTab.dart';
import 'package:swfteaproject/model/Level.dart';
import 'package:swfteaproject/model/User.dart';
import 'package:swfteaproject/providers/SwfTeaController.dart';
import 'package:swfteaproject/ui/widgets/generic/dialougeBox.dart';
import 'package:swfteaproject/utlis/ApiProvider.dart';
import 'package:swfteaproject/utlis/Replacer.dart';

class Chatroom extends StatelessWidget {
  Chatroom({this.appTab});
  final AppTab appTab;
  final Controller controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: ListView.builder(
              reverse: true,
              controller: appTab.scrollController,
              itemBuilder: (context, index) => MessageBuilder(
                message: appTab.messages[index],
                messageContainer: appTab.messageContainer,
              ),
              shrinkWrap: true,
              itemCount: appTab.messages.length,
            ),
          ),
        ),
        Divider(
          height: 1,
        ),
        KeyboardMenu(
          appTab: this.appTab,
        ),
      ],
    );
  }
}

class KeyboardMenu extends StatefulWidget {
  final AppTab appTab;
  KeyboardMenu({this.appTab}) {}

  @override
  _KeyboardMenuState createState() => _KeyboardMenuState();
}

class _KeyboardMenuState extends State<KeyboardMenu> {
  final Controller controller = Get.find();

  final picker = ImagePicker();

  Future<void> retrieveLostData() async {
    final LostData response = await picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        if (response.type == RetrieveType.video) {
        } else {
          int index = controller.tabController.page.round();
          controller.tabs[index].selectedimages.add(response.file.path);
          controller.update();
        }
      });
    } else {}
  }

  Future getGalleryImage() async {
    try {
      final pickedFile = await picker.getImage(source: ImageSource.gallery);

      int index = controller.tabController.page.round();
      print(index);
      if (controller.tabs[index].selectedimages.length > 5) {
        Get.dialog(
          CustomDialog(
            title: "Error",
            child: Center(
              child: Text("Maximum 5 images can be selected"),
            ),
          ),
        );
      } else {
        controller.tabs[index].selectedimages.add(pickedFile.path);
        controller.update();
      }
    } catch (error) {}
  }

  Future getImageFromPicker(path) async {
    try {
      int index = controller.tabController.page.round();
      if (controller.tabs[index].selectedimages.length > 5) {
        Get.dialog(
          CustomDialog(
            title: "Error",
            child: Center(
              child: Text("Maximum 5 images can be selected"),
            ),
          ),
        );
      } else {
        controller.tabs[index].selectedimages.add(path);
        controller.update();
      }
    } catch (error) {}
  }

  Future getCameraImage() async {
    try {
      final pickedFile = await picker.getImage(source: ImageSource.camera);
      int index = controller.tabController.page.round();
      if (controller.tabs[index].selectedimages.length > 5) {
        Get.dialog(
          CustomDialog(
            title: "Error",
            child: Center(
              child: Text("Maximum 5 images can be selected"),
            ),
          ),
        );
      } else {
        controller.tabs[index].selectedimages.add(pickedFile.path);
        controller.update();
      }
    } catch (error) {}
  }

  final imagesList = [];

  List<Map<String, dynamic>> imagesLists;

  FocusNode _focus = new FocusNode();
  bool focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
    // KeyboardVisibilityNotification().addNewListener(
    //   onChange: (bool visible) {
    //     print(visible);
    //     setState(() {
    //       focused = visible;
    //     });
    //   },
    // );
  }

  void _onFocusChange() {
    setState(() {
      focused = _focus.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    int appTabIndex = controller.tabController.page.round();
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          controller.tabs[appTabIndex].selectedimages.length > 0
              ? Container(
                  color: Theme.of(context).primaryColor,
                  padding: EdgeInsets.all(5),
                  child: SingleChildScrollView(
                    child: Row(
                      children: controller.tabs[appTabIndex].selectedimages
                          .map((element) {
                        return Stack(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Image.file(
                                File(element),
                                width: 80,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                                top: -10,
                                right: 0,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    controller.tabs[appTabIndex].selectedimages
                                        .removeWhere((e) => e == element);
                                    controller.update();
                                  },
                                ))
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                )
              : SizedBox(
                  height: 1,
                ),
          widget.appTab.isRecording
              ? LinearProgressIndicator()
              : SizedBox(
                  height: 0.01,
                ),
          Container(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                PopupMenuButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Theme.of(context).primaryColor,
                  ),
                  onSelected: (value) async {
                    switch (value) {
                      case 'room_info':
                        var res = await CallApi(context).getDataFuture(
                            'chatroom/' +
                                widget.appTab.messageContainer.id.toString() +
                                '/info/room_info');
                        dynamic response = jsonDecode(res.body);
                        List<Widget> details = [];
                        for (var i = 0; i < response['messages'].length; i++) {
                          details.add(
                            Text(
                              response['messages'][i]['title'].toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                          details.add(
                            Text(
                              response['messages'][i]['description'].toString(),
                            ),
                          );
                          details.add(
                            SizedBox(
                              height: 15,
                            ),
                          );
                        }
                        Get.dialog(
                          CustomDialog(
                            title: response['header'],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: details,
                            ),
                          ),
                        );
                        break;
                      case 'check_balance':
                        var res = await CallApi(context).getDataFuture(
                            'chatroom/' +
                                widget.appTab.messageContainer.id.toString() +
                                '/info/balance');
                        dynamic response = jsonDecode(res.body);
                        List<Widget> details = [];
                        for (var i = 0; i < response['messages'].length; i++) {
                          details.add(
                            Text(
                              response['messages'][i]['title'].toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                          details.add(
                            Text(
                              response['messages'][i]['description'].toString(),
                            ),
                          );
                          details.add(
                            SizedBox(
                              height: 15,
                            ),
                          );
                        }
                        Get.dialog(
                          CustomDialog(
                            title: response['header'],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: details,
                            ),
                          ),
                        );
                        break;
                      case 'participants':
                        var res = await CallApi(context).getDataFuture(
                            'chatroom/' +
                                widget.appTab.messageContainer.id.toString() +
                                '/info/participants');
                        dynamic response = jsonDecode(res.body);
                        List<Widget> details = [];
                        for (var j = 0;
                            j < response['messages'][0]['users'].length;
                            j++) {
                          details.add(
                            UserWithColor(
                              onPressed: () {
                                Get.back();
                                Get.toNamed(
                                  PROFILE_SCREEN,
                                  arguments: {
                                    'id': response['messages'][0]['users'][j]
                                            ['username']
                                        .toString()
                                  },
                                );
                              },
                              user: new User(
                                0,
                                response['messages'][0]['users'][j]['username']
                                    .toString(),
                                '',
                                '',
                                '',
                                '',
                                new Level('name', 1),
                                '',
                                color: response['messages'][0]['users'][j]
                                    ['color'],
                              ),
                            ),
                          );
                        }
                        Get.dialog(
                          CustomDialog(
                            title: response['header'],
                            child: Flexible(
                              child: ListView(
                                children: details,
                              ),
                            ),
                          ),
                        );
                        break;
                      case 'leave':
                        controller.closeTab(
                            id: widget.appTab.messageContainer.id,
                            type: widget.appTab.type);
                        break;
                    }
                  },
                  itemBuilder: (context) {
                    return widget.appTab.type == "chatroom"
                        ? <PopupMenuEntry<String>>[
                            PopupMenuItem(
                              value: 'room_info',
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.info_outline),
                                  Container(
                                    width: 20,
                                  ),
                                  Text('Room info'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'check_balance',
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.attach_money),
                                  Container(
                                    width: 20,
                                  ),
                                  Text('Check balance'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'participants',
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.group),
                                  Container(
                                    width: 20,
                                  ),
                                  Text('Participants'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'leave',
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.exit_to_app),
                                  Container(
                                    width: 20,
                                  ),
                                  Text('Leave chatroom'),
                                ],
                              ),
                            ),
                          ]
                        : <PopupMenuEntry<String>>[
                            PopupMenuItem(
                              value: 'leave',
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.exit_to_app),
                                  Container(
                                    width: 20,
                                  ),
                                  widget.appTab.messageContainer.members
                                              .length ==
                                          1
                                      ? Text('Close chat')
                                      : Text('Leave group'),
                                ],
                              ),
                            ),
                          ];
                  },
                ),
                (!focused
                    ? Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.insert_photo),
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              this.getGalleryImage();

                              // Below code is for gallery picker like messanger but not ready because of lots of data to handle , must use pagination to avoid crash
                              // appTab.galleryShown
                              //     ? appTab.closeGalleryBoard()
                              //     : appTab.openGalleryBoard();
                              // controller.update();
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.camera_alt),
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              this.getCameraImage();
                            },
                          ),
                          GestureDetector(
                            onLongPress: (){},
                            //todo async {
                            //   bool hasPermission =
                            //       await FlutterAudioRecorder.hasPermissions;
                            //   if (hasPermission) {
                            //     await widget.appTab.initRecording();
                            //     widget.appTab.isRecording = true;
                            //     await widget.appTab.recorder.start();
                            //     controller.update();
                            //   } else {
                            //     Get.dialog(
                            //       CustomDialog(
                            //         title: "Error",
                            //         child: Text(
                            //             "You haven't given permissions for recording to this app."),
                            //       ),
                            //     );
                            //   }
                            // },
                            // onLongPressEnd: (details) async {
                            //   if (widget.appTab.isRecording) {
                            //     widget.appTab.isRecording = false;
                            //     var result =
                            //         await widget.appTab.recorder.stop();
                            //     controller.sendRecording(
                            //         appTab: widget.appTab, path: result.path);
                            //   }
                            // },
                            child: IconButton(
                              icon: Icon(Icons.mic),
                              color: Theme.of(context).primaryColor,
                              onPressed: () {
                                // controller.sendMessage(appTab: appTab);
                                // this.appTab.textBox.clear();
                              },
                            ),
                          ),
                        ],
                      )
                    : IconButton(
                        icon: Icon(Icons.arrow_forward_ios_rounded),
                        color: Theme.of(context).primaryColor,
                        onPressed: () {
                          setState(() {
                            focused = false;
                          });
                          widget.appTab.textBox.clear();
                          FocusScope.of(context).requestFocus(new FocusNode());
                        },
                      )),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 2,
                      bottom: 2,
                    ),
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: <Widget>[
                        TextField(
                          onTap: () {
                            setState(() {
                              focused = true;
                            });
                            widget.appTab.closeEmojiBoard();
                            controller.update();
                          },
                          cursorColor: Theme.of(context).primaryColor,
                          // focusNode: appTab.textFocusNode,
                          focusNode: _focus,
                          controller: widget.appTab.textBox,
                          showCursor: true,
                          readOnly: widget.appTab.emojiShown,
                          onChanged: (value) {
                            controller.update();
                          },
                          decoration: new InputDecoration(
                            filled: true,
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            //fillColor: HexColor('#EFF7FD'),
                            contentPadding: EdgeInsets.only(
                              left: 10,
                              right: 40,
                            ),
                            hintText: "Aa",
                          ),
                          onSubmitted: (value) {
                            controller.sendMessage(appTab: widget.appTab);
                            this.widget.appTab.textBox.clear();
                            if (widget.appTab.textFocusNode.canRequestFocus) {
                              widget.appTab.textFocusNode.requestFocus();
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.insert_emoticon,
                            color: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            if (widget.appTab.emojiShown) {
                              widget.appTab.textFocusNode.requestFocus();
                              widget.appTab.closeEmojiBoard();
                            } else {
                              // // appTab.textFocusNode.unfocus();
                              // SystemChannels.textInput
                              //     .invokeMethod('TextInput.hide');
                              widget.appTab.openEmojiBoard();
                            }
                            controller.update();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    setState(() {
                      focused = false;
                    });
                    this.widget.appTab.closeEmojiBoard();
                    this.widget.appTab.closeGalleryBoard();
                    controller.sendMessage(appTab: widget.appTab);
                    this.widget.appTab.textBox.clear();
                    controller.update();
                  },
                ),
              ],
            ),
          ),
          // appTab.galleryShown
          //     ? ImageLibrary(getImageFromPicker, appTab.images)
          //     : SizedBox(),
          widget.appTab.emojiShown
              ? EmojiBoard(
                  appTab: widget.appTab,
                )
              : SizedBox(
                  height: 0,
                ),
        ],
      ),
    );
  }
}

class ImageLibrary extends StatefulWidget {
  List<Map<String, dynamic>> data = [];

  Function setImage;

  ImageLibrary(this.setImage, this.data);

  @override
  _ImageLibraryState createState() => _ImageLibraryState();
}

class _ImageLibraryState extends State<ImageLibrary> {
  ScrollController _gridController = ScrollController();
  List<String> myGridList = List();

  int length = 0;

  int currentMax = 0;

  int max_List = 20;
  @override
  void initState() {
    super.initState();
    print(widget.data);
    if (widget.data != null) {
      length = widget.data.length;
      print("Length" + length.toString());
      myGridList = List.generate(length < max_List ? length : max_List,
          (index) => widget.data[index]['path']);
      currentMax = length < max_List ? length - 1 : max_List;
      _gridController.addListener(() {
        if (_gridController.position.pixels ==
            _gridController.position.maxScrollExtent) {
          loadMoreData();
        }
      });
    }
  }

  void loadMoreData() {
    print(currentMax);
    print(widget.data.length);
    if (currentMax < widget.data.length) {
      for (int i = currentMax; i < widget.data.length; i++) {
        myGridList.add(widget.data[i]['path']);
      }
      currentMax += max_List;
      setState(() {
        myGridList = myGridList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      child: GridView.builder(
        controller: _gridController,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              this.widget.setImage(myGridList[index]);
            },
            child: GridTile(
              child: Image.file(File(myGridList[index]), fit: BoxFit.cover),
            ),
          );
        },
        itemCount: myGridList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
      ),

      // GridView.count(
      //     crossAxisCount: 4,
      //     childAspectRatio: 1.0,
      //     padding: const EdgeInsets.all(4.0),
      //     mainAxisSpacing: 4.0,
      //     crossAxisSpacing: 4.0,
      //     children: widget.data.map((Map<String, dynamic> image) {
      //       return InkWell(
      //         onTap: () {
      //           this.widget.setImage(image['path']);
      //         },
      //         child: GridTile(
      //           child: Image.file(File(image['path']), fit: BoxFit.cover),
      //         ),
      //       );
      //     }).toList()),
    );
  }
}

class EmojiBoard extends StatelessWidget {
  EmojiBoard({this.appTab});
  final AppTab appTab;
  final Controller controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: PageView.builder(
              itemCount: controller.user.emojicategories.length,
              controller: appTab.emojiTab,
              itemBuilder: (context, index) {
                List<Widget> emojies = controller.user.emojies
                    .where((element) =>
                        element.category ==
                        controller.user.emojicategories[index].name)
                    .map((e) {
                  return GestureDetector(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: CachedNetworkImage(
                        imageUrl: e.url,
                        height: 24,
                        width: 24,
                      ),
                    ),
                    onTap: () {
                      String emoji = e.name;
                      TextEditingController textEditingController = controller
                          .tabs[controller.tabController.page.round()].textBox;
                      String text = textEditingController.text;
                      TextSelection textSelection =
                          textEditingController.selection;
                      if (textSelection.start == -1 &&
                          textSelection.end == -1) {
                        String newText = emoji;
                        final emojiLength = emoji.length;
                        textEditingController.text = newText;
                        textEditingController.selection =
                            textSelection.copyWith(
                          baseOffset: 0 + emojiLength,
                          extentOffset: 0 + emojiLength,
                        );
                      } else {
                        String newText = text.replaceRange(
                          textSelection.start,
                          textSelection.end,
                          emoji,
                        );
                        final emojiLength = emoji.length;
                        textEditingController.text = newText;
                        textEditingController.selection =
                            textSelection.copyWith(
                          baseOffset: textSelection.start + emojiLength,
                          extentOffset: textSelection.start + emojiLength,
                        );
                      }

                      controller.tabs[controller.tabController.page.round()]
                          .textBox = textEditingController;
                      controller.update(); // update widget
                    },
                  );
                }).toList();
                return Container(
                  color: Colors.grey[100],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 10, top: 5, bottom: 5),
                        child: Text(
                          controller.user.emojicategories[index].name,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Wrap(
                            children: emojies,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 40,
            child: Center(
              child: SmoothPageIndicator(
                  controller: appTab.emojiTab,
                  count: controller.user.emojicategories.length,
                  effect: ScaleEffect(
                    dotColor: Theme.of(context).secondaryHeaderColor,
                    activeDotColor: Theme.of(context).primaryColor,
                  ),
                  onDotClicked: (index) {
                    appTab.emojiTab.animateToPage(index,
                        duration: Duration(milliseconds: 600),
                        curve: Curves.decelerate);
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
