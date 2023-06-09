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

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool checkBoxValue = false;
  double _height;
  double _width;
  double _pixelRatio;
  bool _large;
  bool _medium;
  bool registering = false;

  TextEditingController fullNameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  List gender = ["Male", "Female"];
  String select;

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
                form(),
                Container(
                  margin: EdgeInsets.only(
                    left: _width / 12.0,
                    right: _width / 12.0,
                    top: _height / 50.0,
                  ),
                  child: Row(
                    children: [
                      addRadioButton(0, 'Male'),
                      addRadioButton(1, 'Female'),
                    ],
                  ),
                ),
                acceptTermsTextRow(),
                button(),
                signInTextRow(),
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
              child: Image.asset(
                'assets/images/logo.png',
                height: _height / 2.8,
                width: _width / 2.8,
              )),
        ),
        // ),
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
            fullNameTextFormField(),
            SizedBox(height: _height / 60.0),
            userNameTextFormField(),
            SizedBox(height: _height / 60.0),
            emailTextFormField(),
            // SizedBox(height: _height / 60.0),
            // phoneTextFormField(),
            SizedBox(height: _height / 60.0),
            passwordTextFormField(),
          ],
        ),
      ),
    );
  }

  Row addRadioButton(int btnValue, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Radio(
          activeColor: Theme.of(context).primaryColor,
          value: gender[btnValue],
          groupValue: select,
          onChanged: (value) {
            setState(() {
              select = value;
            });
          },
        ),
        Text(title)
      ],
    );
  }

  Widget fullNameTextFormField() {
    return CustomTextField(
      textEditingController: fullNameController,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      onEditingComplete: () {
        FocusScope.of(context).nextFocus();
      },
      icon: Icons.person,
      hint: "Full Name",
    );
  }

  Widget userNameTextFormField() {
    return CustomTextField(
      textEditingController: usernameController,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      onEditingComplete: () {
        FocusScope.of(context).nextFocus();
      },
      icon: Icons.person,
      hint: "Username",
    );
  }

  Widget emailTextFormField() {
    return CustomTextField(
      textEditingController: emailController,
      textInputAction: TextInputAction.next,
      onEditingComplete: () {
        FocusScope.of(context).nextFocus();
      },
      keyboardType: TextInputType.emailAddress,
      icon: Icons.email,
      hint: "Email ID",
    );
  }

  Widget passwordTextFormField() {
    return CustomTextField(
      textEditingController: passwordController,
      keyboardType: TextInputType.text,
      obscureText: true,
      icon: Icons.lock,
      hint: "Password",
    );
  }

  Widget acceptTermsTextRow() {
    return Container(
      margin: EdgeInsets.only(top: _height / 100.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Checkbox(
            activeColor: Theme.of(context).primaryColor,
            value: checkBoxValue,
            onChanged: (bool newValue) {
              setState(() {
                checkBoxValue = newValue;
              });
            },
          ),
          Text(
            "I accept all terms and conditions",
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: _large ? 12 : (_medium ? 11 : 10)),
          ),
        ],
      ),
    );
  }

  Widget button() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        textStyle: TextStyle(color: Colors.white),
        padding: EdgeInsets.all(0.0),
      ),
      onPressed: registering
          ? () {}
          : () {
              registerUser(Get.context);
            },
      child: Container(
        alignment: Alignment.center,
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
        child: registering
            ? SizedBox(
                height: 12,
                width: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'SIGN UP',
                style: TextStyle(fontSize: _large ? 14 : (_medium ? 12 : 10)),
              ),
      ),
    );
  }

  Widget infoTextRow() {
    return Container(
      margin: EdgeInsets.only(top: _height / 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Or create using social media",
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: _large ? 12 : (_medium ? 11 : 10)),
          ),
        ],
      ),
    );
  }

  Widget socialIconsRow() {
    return Container(
      margin: EdgeInsets.only(top: _height / 80.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircleAvatar(
            radius: 15,
            backgroundImage: AssetImage("assets/images/googlelogo.png"),
          ),
          SizedBox(
            width: 20,
          ),
          CircleAvatar(
            radius: 15,
            backgroundImage: AssetImage("assets/images/fblogo.jpg"),
          ),
          SizedBox(
            width: 20,
          ),
          CircleAvatar(
            radius: 15,
            backgroundImage: AssetImage("assets/images/twitterlogo.jpg"),
          ),
        ],
      ),
    );
  }

  Widget signInTextRow() {
    return Container(
      margin: EdgeInsets.only(top: _height / 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Already have an account?",
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
          SizedBox(
            width: 5,
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop(SIGN_IN);
              print("Routing to Sign up screen");
            },
            child: Text(
              "Sign in",
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).primaryColor,
                  fontSize: 19),
            ),
          )
        ],
      ),
    );
  }

  void registerUser(BuildContext context) async {
    if (!checkBoxValue) {
      Get.dialog(
        CustomDialog(
          title: "Error",
          child: Text('You must accept our terms and condition.'),
        ),
      );
      return;
    }
    setState(() {
      registering = true;
    });
    print(select);

    var registerData = {
      'username': usernameController.text,
      'email': emailController.text,
      'password': passwordController.text,
      'password_confirmation': passwordController.text,
      'gender': select,
      'name': fullNameController.text,
      "cover_picture": ""
    };
    print(registerData);
    var res = await CallApi(context).postData(registerData, 'auth/register');
    print(res);
    var body = json.decode(res.body);
    print("api response is here ");
    print(body);
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
        ),
      );
    }
    setState(() {
      registering = false;
    });
  }
}
