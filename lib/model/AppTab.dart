import 'package:flutter/cupertino.dart';
// import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:flutter_pusher/pusher.dart';
import 'package:swfteaproject/model/Message.dart';
import 'package:swfteaproject/model/MessageContainer.dart';
import 'dart:io' as io;
import 'package:swfteaproject/ui/widgets/generic/nokeyboardFocusNode.dart';
import 'package:path_provider/path_provider.dart';

class AppTab {
  final String type;
  final String label;
  final String key;
  bool blinking = false;
  bool isRecording = false;
  bool active;
  bool emojiShown = false;
  bool galleryShown = false;
  PageController emojiTab = new PageController();
  Channel channel;
  Channel notificationchannel;
  List<SwfTeaMessage> messages = [];
  MessageContainer messageContainer;
  TextEditingController textBox = new TextEditingController();
  ScrollController scrollController = new ScrollController();
  FocusNode textFocusNode = new NoKeyboardEditableTextFocusNode();
  List<String> selectedimages = [];
  // FlutterAudioRecorder recorder;
  bool submenuOpened = false;

  List<Map<String, dynamic>> images;

  AppTab(
    this.type,
    this.label,
    this.key, {
    this.active = false,
    this.blinking = false,
    this.emojiShown = false,
    this.galleryShown = false,
    this.messageContainer,
  }) {}

  // initRecording() async {
  //   try {
  //     if (await FlutterAudioRecorder.hasPermissions) {
  //       String customPath = '/flutter_audio_recorder_';
  //       io.Directory appDocDirectory;
  //       if (io.Platform.isIOS) {
  //         appDocDirectory = await getApplicationDocumentsDirectory();
  //       } else {
  //         appDocDirectory = await getExternalStorageDirectory();
  //       }
  //
  //       // can add extension like ".mp4" ".wav" ".m4a" ".aac"
  //       customPath = appDocDirectory.path +
  //           customPath +
  //           DateTime.now().millisecondsSinceEpoch.toString();
  //
  //       // .wav <---> AudioFormat.WAV
  //       // .mp4 .m4a .aac <---> AudioFormat.AAC
  //       // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.
  //       recorder =
  //           FlutterAudioRecorder(customPath, audioFormat: AudioFormat.WAV);
  //
  //       await recorder.initialized;
  //       // after initialization
  //       var current = await recorder.current(channel: 0);
  //       print(current);
  //       // should be "Initialized", if all working fine
  //
  //     } else {}
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  openGalleryBoard() {
    this.emojiShown = false;
    this.galleryShown = true;
  }

  closeGalleryBoard() {
    this.emojiShown = false;
    this.galleryShown = false;
  }

  openEmojiBoard() {
    this.galleryShown = false;
    this.emojiShown = true;
  }

  closeEmojiBoard() {
    this.galleryShown = false;
    this.emojiShown = false;
  }

  setChannel(Channel channel) {
    this.channel = channel;
  }

  setNotificationChannel(Channel channel) {
    this.notificationchannel = channel;
  }

  addMessage(SwfTeaMessage message) {
    this.messages.add(message);
  }
}
