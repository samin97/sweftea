import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swfteaproject/providers/SwfTeaController.dart';
import 'package:swfteaproject/ui/widgets/generic/dialougeBox.dart';
import 'package:swfteaproject/ui/widgets/generic/nicebuttom.dart';
import 'package:swfteaproject/ui/widgets/textformfield.dart';
import 'package:swfteaproject/utlis/ApiProvider.dart';
import 'package:swfteaproject/utlis/Replacer.dart';

class ChangePassword extends StatefulWidget {
  final Controller controller = Get.find();
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController oldpass = TextEditingController();
  TextEditingController newpass = TextEditingController();
  TextEditingController newpassconfirm = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Change password"),
      ),
      body: Card(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: ListView(
            children: <Widget>[
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SecondaryTitle(
                      title: "Change password",
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    AppTextInputField(
                      elevation: false,
                      hint: "Old password",
                      textEditingController: oldpass,
                      icon: Icons.vpn_key,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    AppTextInputField(
                      elevation: false,
                      hint: "New password",
                      textEditingController: newpass,
                      icon: Icons.vpn_lock,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    AppTextInputField(
                      elevation: false,
                      hint: "New password (Repeat)",
                      textEditingController: newpassconfirm,
                      icon: Icons.vpn_lock,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    NiceButton(
                      bgColor: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      child: Text("Change password"),
                      onPressed: () async {
                        var res = await CallApi(context).postDataFuture(
                          {
                            "password": oldpass.text,
                            "new_password": newpass.text,
                            "new_password_confirmation": newpassconfirm.text,
                          },
                          'user/updatePassword',
                        );
                        dynamic details = json.decode(res.body);
                        if (details['error'] ?? true) {
                          Get.dialog(
                            CustomDialog(
                              title: "Error",
                              child: Text(details['message']),
                            ),
                          );
                        } else {
                          oldpass.clear();
                          newpass.clear();
                          newpassconfirm.clear();
                          Get.dialog(
                            CustomDialog(
                              title: "Success",
                              child: Text(details['message']),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
