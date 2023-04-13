import 'package:swfteaproject/model/User.dart';

class SwfTeaMessage {
  String formattedtext;
  String type;
  String bot;
  dynamic extrainfo;
  User sender;

  SwfTeaMessage({
    this.formattedtext,
    this.type,
    this.bot = 'chatroom',
    this.extrainfo,
    this.sender,
  });

  setSender(User user) {
    this.sender = user;
  }
}
