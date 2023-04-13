import 'package:flutter/cupertino.dart';

class MessageContainer {
  String name;
  String description;
  String creator;
  String type;
  String id;
  List members;

  MessageContainer({
    @required this.name,
    @required this.description,
    @required this.creator,
    @required this.members,
    this.type = 'chatroom',
    @required this.id,
  });
}
