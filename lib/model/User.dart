import 'package:swfteaproject/model/Emoji.dart';
import 'package:swfteaproject/model/EmojiCategory.dart';
import 'package:swfteaproject/model/Level.dart';

class User {
  final int id;
  final String username;
  final String email;
  final String name;
  final String picture;
  String token;
  String status;
  Level level;
  String color;
  List<Emoji> emojies;
  List<EmojiCategory> emojicategories = [];
  List<Emoji> defaultemojies;
  dynamic extrainfo = {};

  User(
    this.id,
    this.username,
    this.email,
    this.name,
    this.picture,
    this.status,
    this.level,
    this.token, {
    this.color = '#000000',
    this.extrainfo,
    this.emojies,
  });

  setEmojies(List<Emoji> emojies) {
    this.emojies = emojies;
  }

  setDefaultEmojies(List<Emoji> emojies) {
    this.defaultemojies = emojies;
  }

  setEmojiesCategories(List<EmojiCategory> categories) {
    this.emojicategories = categories;
  }
}
