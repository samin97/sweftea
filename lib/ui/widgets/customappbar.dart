import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Material(
      color: Theme.of(context).primaryColor,
      child: Container(
        height: height / 10,
        width: width,
        padding: EdgeInsets.only(left: 15, top: 25),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor
            ],
          ),
        ),
        child: Row(
          children: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                splashColor: Colors.amber,
                highlightColor: Colors.amber,
                onPressed: () {
                  print("pop");
                  Navigator.of(context).pop();
                })
          ],
        ),
      ),
    );
  }
}
