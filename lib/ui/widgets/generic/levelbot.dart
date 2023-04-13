import 'package:flutter/material.dart';
import 'package:swfteaproject/utlis/Replacer.dart';

class LevelBot extends StatelessWidget {
  LevelBot(this.level);
  final int level;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Image.network(
          Replacer().getLevelBotImage(this.level),
          height: 17,
          width: 17,
        ),
        Text(
          ' ' + level.toString(),
          style: TextStyle(color: Colors.white),
        )
      ],
    );
  }
}

class Bot extends StatelessWidget {
  Bot(this.level);
  final int level;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Image.network(
          Replacer().getLevelBotImage(this.level),
          height: 20,
          width: 20,
        ),
      ],
    );
  }
}
