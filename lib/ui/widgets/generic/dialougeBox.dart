import 'package:flutter/material.dart';
import 'package:swfteaproject/constants/Const.dart';

class CustomDialog extends StatelessWidget {
  CustomDialog({
    @required this.title,
    @required this.child,
    this.buttonText = "Ok",
    this.onSubmit,
    this.image,
  });
  final String title, buttonText;
  final Widget child;
  final Widget image;
  final Function onSubmit;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Const().padding)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
                top: Const().avatarRadius + Const().padding,
                bottom: Const().padding,
                left: Const().padding,
                right: Const().padding),
            margin: EdgeInsets.only(top: Const().avatarRadius),
            decoration: new BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(Const().padding),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: const Offset(0.0, 10.0))
                ]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 5.0,
                ),
                child,
                SizedBox(
                  height: 5.0,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (this.onSubmit != null) {
                        this.onSubmit();
                      }
                    },
                    child: Text(buttonText),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: Const().padding,
            right: Const().padding,
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: Const().avatarRadius,
              child: this.image ??
                  Image.asset(
                    'assets/images/logo.png',
                    height: Const().avatarRadius,
                    width: Const().avatarRadius,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingDialog extends Dialog {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          padding: EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Color.fromRGBO(0, 0, 0, 0.7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 3,
            ),
          ),
        ),
      ),
    );
  }
}
