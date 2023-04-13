import 'dart:ui';
import 'package:flutter/material.dart';

class BlurryDialog extends StatelessWidget {
  String title;
  String content;
  VoidCallback continueCallBack;

  BlurryDialog(this.title, this.content, this.continueCallBack);
  TextStyle textStyle = TextStyle(color: Colors.black);

  @override
  Widget build(BuildContext context) {
    if (title.length == 0) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: AlertDialog(
          content: new Text(
            content,
            style: textStyle,
          ),
          actions: <Widget>[
            new ElevatedButton(
              child: new Text("Continue"),
              onPressed: () {
                continueCallBack();
              },
            ),
            new ElevatedButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    } else {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: AlertDialog(
          title: new Text(
            title,
            style: textStyle,
          ),
          content: new Text(
            content,
            style: textStyle,
          ),
          actions: <Widget>[
            new ElevatedButton(
              child: new Text("Continue"),
              onPressed: () {
                continueCallBack();
              },
            ),
            new ElevatedButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }
}
