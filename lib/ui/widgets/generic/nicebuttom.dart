import 'package:flutter/material.dart';

class NiceButton extends StatelessWidget {
  NiceButton({
    this.onPressed,
    this.child,
    this.bgColor = Colors.white,
    this.textColor = Colors.black,
    this.radius = 30.0,
  });

  final onPressed;
  final child;
  final bgColor;
  final textColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => this.onPressed(),
      style: ElevatedButton.styleFrom(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(radius),
        ),
        textStyle: TextStyle(
          color: this.textColor,
        ),
        padding: EdgeInsets.all(0.0),
        backgroundColor: this.bgColor,
      ),
      child: this.child,
    );
  }
}
