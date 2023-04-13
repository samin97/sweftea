import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swfteaproject/constants/constants.dart';
import 'package:swfteaproject/ui/widgets/custom_shape.dart';
import 'package:swfteaproject/ui/widgets/customappbar.dart';
import 'package:swfteaproject/ui/widgets/generic/dialougeBox.dart';
import 'package:swfteaproject/ui/widgets/responsive_ui.dart';
import 'package:swfteaproject/ui/widgets/textformfield.dart';
import 'package:swfteaproject/utlis/ApiProvider.dart';

class VerifyEmailScreen extends StatefulWidget {
  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool checkBoxValue = false;
  double _height;
  double _width;
  double _pixelRatio;
  bool _large;
  bool _medium;
  bool loading = false;

  TextEditingController token = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  dynamic arguments = Get.arguments;

  @override
  void initState() {
    String username = arguments['username'] ?? '';
    String email = arguments['email'] ?? '';
    usernameController.value = TextEditingValue(
      text: username,
    );
    emailController.value = TextEditingValue(
      text: email,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    _medium = ResponsiveWidget.isScreenMedium(_width, _pixelRatio);

    return Material(
      child: Scaffold(
        body: Container(
          height: _height,
          width: _width,
          margin: EdgeInsets.only(bottom: 5),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Opacity(opacity: 0.88, child: CustomAppBar()),
                clipShape(),
                Container(
                  margin: EdgeInsets.only(
                    left: _width / 12.0,
                    right: _width / 12.0,
                    top: _height / 20.0,
                  ),
                  child: Text(
                      'Please verify you email in order to complete the registration process. Code has been sent to your email address.'),
                ),
                form(),
                SizedBox(height: 20),
                button(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget clipShape() {
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: 0.75,
          child: ClipPath(
            clipper: CustomShapeClipper(),
            child: Container(
              height: _large
                  ? _height / 8
                  : (_medium ? _height / 7 : _height / 6.5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor
                  ],
                ),
              ),
            ),
          ),
        ),
        Opacity(
          opacity: 0.5,
          child: ClipPath(
            clipper: CustomShapeClipper2(),
            child: Container(
              height: _large
                  ? _height / 12
                  : (_medium ? _height / 11 : _height / 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          height: _height / 5.5,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  spreadRadius: 0.0,
                  color: Colors.black26,
                  offset: Offset(1.0, 10.0),
                  blurRadius: 20.0),
            ],
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: GestureDetector(
              onTap: () {
                print('Adding photo');
              },
              // child: Icon(
              //   Icons.add_a_photo,
              //   size: _large ? 40 : (_medium ? 33 : 31),
              //   color: Colors.orange[200],
              // )),
              child: Image.asset(
                'assets/images/logo.png',
                height: _height / 2.8,
                width: _width / 2.8,
              )),
        ),
      ],
    );
  }

  Widget form() {
    return Container(
      margin: EdgeInsets.only(
          left: _width / 12.0, right: _width / 12.0, top: _height / 20.0),
      child: Form(
        child: Column(
          children: <Widget>[
            userNameTextFormField(),
            SizedBox(height: _height / 60.0),
            emailTextFormField(),
            SizedBox(height: _height / 60.0),
            tokenFormField(),
          ],
        ),
      ),
    );
  }

  Widget tokenFormField() {
    return CustomTextField(
      textEditingController: token,
      keyboardType: TextInputType.text,
      icon: Icons.code,
      hint: "Token ",
    );
  }

  Widget userNameTextFormField() {
    return CustomTextField(
      textEditingController: usernameController,
      keyboardType: TextInputType.text,
      icon: Icons.person,
      hint: "Username",
      textInputAction: TextInputAction.next,
      onEditingComplete: () {
        FocusScope.of(context).nextFocus();
      },
    );
  }

  Widget emailTextFormField() {
    return CustomTextField(
      textEditingController: emailController,
      keyboardType: TextInputType.emailAddress,
      icon: Icons.email,
      hint: "Email ID",
      textInputAction: TextInputAction.next,
      onEditingComplete: () {
        FocusScope.of(context).nextFocus();
      },
    );
  }

  Widget button() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          elevation: 0,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          textStyle: TextStyle(color: Colors.white),
          padding: EdgeInsets.all(0)),
      onPressed: loading
          ? () {}
          : () {
              verifyToken(Get.context);
            },
      child: Container(
        alignment: Alignment.center,
//        height: _height / 20,
        width: _large ? _width / 4 : (_medium ? _width / 3.75 : _width / 3.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          gradient: LinearGradient(
            colors: <Color>[
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor
            ],
          ),
        ),
        padding: const EdgeInsets.all(12.0),
        child: loading
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Verify',
                style: TextStyle(fontSize: _large ? 14 : (_medium ? 12 : 10)),
              ),
      ),
    );
  }

  void verifyToken(BuildContext context) async {
    setState(() {
      loading = true;
    });

    var tokenData = {
      'username': usernameController.text,
      'email': emailController.text,
      'token': token.text,
    };
    var res = await CallApi(context).postData(tokenData, 'auth/verifyEmail');
    var body = json.decode(res.body);
    if (body["error"] == true) {
      Get.dialog(
        CustomDialog(
          title: "Error",
          child: Text(body["message"]),
        ),
      );
    } else {
      Get.dialog(
        CustomDialog(
          title: "Success",
          child: Text(body["message"]),
          onSubmit: () {
            Get.offAllNamed(SIGN_IN);
          },
        ),
      );
    }
    setState(() {
      loading = false;
    });
  }
}
