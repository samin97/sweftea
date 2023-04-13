import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:localstorage/localstorage.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:swfteaproject/constants/constants.dart';
import 'package:swfteaproject/model/Level.dart';
import 'package:swfteaproject/model/User.dart';
import 'package:swfteaproject/providers/UserProvider.dart';
import 'package:swfteaproject/ui/widgets/custom_shape.dart';
import 'package:swfteaproject/ui/widgets/responsive_ui.dart';
import 'package:swfteaproject/ui/widgets/textformfield.dart';
import 'package:swfteaproject/utlis/ApiProvider.dart';

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SignInScreen(),
    );
  }
}

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  double _height;
  double _width;
  double _pixelRatio;
  bool _large;
  bool _medium;
  bool _loggingIn = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> _key = GlobalKey();
  bool _rememberMe = true;
  LocalStorage storage = new LocalStorage('swftea_app');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    _medium = ResponsiveWidget.isScreenMedium(_width, _pixelRatio);
    return FutureBuilder(
      future: storage.ready,
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return Material(
            child: WillPopScope(
                child: Container(
                  height: _height,
                  width: _width,
                  padding: EdgeInsets.only(bottom: 5),
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        clipShape(),
                        welcomeTextRow(),
                        signInTextRow(),
                        form(),
                        forgetPassTextRow(),
                        SizedBox(
                          height: _height / 100,
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: _width / 12.0,
                            right: _width / 12.0,
                          ),
                          child: Row(
                            children: <Widget>[
                              Checkbox(
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value;
                                  });
                                },
                                activeColor: Theme.of(context).primaryColor,
                                value: _rememberMe,
                              ),
                              Text('Auto login'),
                            ],
                          ),
                        ),
                        button(),
                        signUpTextRow(),
                      ],
                    ),
                  ),
                ),
                onWillPop: onWillPop),
          );
        } else {
          return Text("Loading");
        }
      },
    );
  }

  DateTime currentBackPressTime;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: "Press again to exit");
      return Future.value(false);
    }
    exit(0);
    return Future.value(true);
  }

  Widget clipShape() {
    //double height = MediaQuery.of(context).size.height;
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: 0.75,
          child: ClipPath(
            clipper: CustomShapeClipper(),
            child: Container(
              height: _large
                  ? _height / 4
                  : (_medium ? _height / 3.75 : _height / 3.5),
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
                  ? _height / 4.5
                  : (_medium ? _height / 4.25 : _height / 4),
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
          alignment: Alignment.bottomCenter,
          margin: EdgeInsets.only(
              top: _large
                  ? _height / 30
                  : (_medium ? _height / 25 : _height / 20)),
          child: Image.asset(
            'assets/images/logo.png',
            height: _height / 3.5,
            width: _width / 3.5,
          ),
        ),
      ],
    );
  }

  Widget welcomeTextRow() {
    return Container(
      margin: EdgeInsets.only(left: _width / 20, top: _height / 100),
      child: Row(
        children: <Widget>[
          Text(
            "Welcome",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: _large ? 60 : (_medium ? 50 : 40),
            ),
          ),
        ],
      ),
    );
  }

  Widget signInTextRow() {
    return Container(
      margin: EdgeInsets.only(left: _width / 15.0),
      child: Row(
        children: <Widget>[
          Text(
            "Sign in to your account",
            style: TextStyle(
              fontWeight: FontWeight.w200,
              fontSize: _large ? 20 : (_medium ? 17.5 : 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget form() {
    String username =
        storage.getItem('username') != null ? storage.getItem('username') : '';
    String password =
        storage.getItem('password') != null ? storage.getItem('password') : '';
    if (_rememberMe) {
      emailController.value = TextEditingValue(
        text: username,
        selection: TextSelection.collapsed(offset: username.length),
      );
      passwordController.value = TextEditingValue(
        text: password,
        selection: TextSelection.collapsed(offset: password.length),
      );
    }

    return Container(
      margin: EdgeInsets.only(
          left: _width / 12.0, right: _width / 12.0, top: _height / 15.0),
      child: Form(
        key: _key,
        child: Column(
          children: <Widget>[
            emailTextFormField(),
            SizedBox(height: _height / 40.0),
            passwordTextFormField(),
          ],
        ),
      ),
    );
  }

  Widget emailTextFormField() {
    return CustomTextField(
      keyboardType: TextInputType.emailAddress,
      textEditingController: emailController,
      icon: Icons.verified_user,
      hint: "Username",
      textInputAction: TextInputAction.next,
      onEditingComplete: () {
        FocusScope.of(context).nextFocus();
      },
    );
  }

  Widget passwordTextFormField() {
    return CustomTextField(
      keyboardType: TextInputType.emailAddress,
      textEditingController: passwordController,
      icon: Icons.lock,
      obscureText: true,
      hint: "Password",
    );
  }

  Widget forgetPassTextRow() {
    return Container(
      margin: EdgeInsets.only(top: _height / 40.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Forgot your password?",
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: _large ? 14 : (_medium ? 12 : 10)),
              ),
              SizedBox(
                width: 5,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(RESET_PASSWORD);
                },
                child: Text(
                  "Recover",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Already have token?",
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: _large ? 14 : (_medium ? 12 : 10)),
              ),
              SizedBox(
                width: 5,
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(VERIFY_EMAIL, arguments: {
                    "username": emailController.text,
                  });
                },
                child: Text(
                  "Activate your account",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor),
                ),
              )
            ],
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
      onPressed: _loggingIn
          ? () {}
          : () {
              loginUser(context);
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
        child: _loggingIn
            ? SizedBox(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
                width: 14,
                height: 14,
              )
            : Text('SIGN IN',
                style: TextStyle(fontSize: _large ? 14 : (_medium ? 12 : 10))),
      ),
    );
  }

  Widget signUpTextRow() {
    return Container(
      margin: EdgeInsets.only(top: _height / 120.0, bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Don't have an account?",
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: _large ? 14 : (_medium ? 12 : 10)),
          ),
          SizedBox(
            width: 5,
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(SIGN_UP);
            },
            child: Text(
              "Sign up",
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).primaryColor,
                  fontSize: _large ? 19 : (_medium ? 17 : 15)),
            ),
          )
        ],
      ),
    );
  }

  Future<void> loginUser(BuildContext context) async {
    setState(() {
      _loggingIn = true;
    });
    var loginData = {
      'username': emailController.text,
      'password': passwordController.text
    };
    var res = await CallApi(context).postData(loginData, 'auth/login');
    print(res);
    var body = json.decode(res.body);
    print(body);
    if (body["error"] == true) {
      if (body['open_verify_email'] ?? false) {
        Get.toNamed(VERIFY_EMAIL, arguments: {
          'username': emailController.text,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          new SnackBar(
            content: Text(body["message"]),
          ),
        );
      }
    } else {
      if (_rememberMe) {
        storage.setItem('@body', body);
      } else
        storage.setItem('@body', null);
      UserProvider userProvider = Provider.of<UserProvider>(context);
      print(userProvider);
      userProvider.setUser(
        new User(
          body["user"]["id"],
          body["user"]["username"],
          body["user"]["email"],
          body["user"]["name"],
          body["user"]["profile_picture"],
          body["user"]["main_status"],
          new Level(
            body["user"]["level"]["name"],
            body["user"]["level"]["value"],
          ),
          body["access_token"],
          color: body["user"]["color"],
        ),
      );
      Get.offAllNamed(MAIN_SCREEN);
      // Navigator.of(context).pushReplacementNamed(SIGN_IN);
    }
    setState(() {
      _loggingIn = false;
    });
  }
}
