import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swfteaproject/providers/SwfTeaController.dart';
import 'package:swfteaproject/ui/widgets/generic/dialougeBox.dart';
import 'package:swfteaproject/ui/widgets/generic/nicebuttom.dart';
import 'package:swfteaproject/ui/widgets/textformfield.dart';
import 'package:swfteaproject/utlis/ApiProvider.dart';
import 'package:swfteaproject/utlis/Replacer.dart';

class ChangePinCode extends StatefulWidget {
  final Controller controller = Get.find();
  @override
  _ChangePinCodeState createState() => _ChangePinCodeState();
}

class _ChangePinCodeState extends State<ChangePinCode> {
  TextEditingController oldpin = TextEditingController();
  TextEditingController newpin = TextEditingController();
  TextEditingController newpinconfirm = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Change pin code"),
      ),
      body: Card(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: ListView(
            children: <Widget>[
              Container(
                child: Text(
                  "Your pin should be exactly 6 digits. If you are setting pin for the first time, use 000000 as default pin.",
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SecondaryTitle(
                      title: "Change pincode",
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    AppTextInputField(
                      elevation: false,
                      hint: "Old pin code",
                      textEditingController: oldpin,
                      icon: Icons.vpn_key,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    AppTextInputField(
                      elevation: false,
                      hint: "New pin code",
                      textEditingController: newpin,
                      icon: Icons.vpn_lock,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    AppTextInputField(
                      elevation: false,
                      hint: "New pin code (Repeat)",
                      textEditingController: newpinconfirm,
                      icon: Icons.vpn_lock,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    NiceButton(
                      bgColor: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      child: Text("Change pincode"),
                      onPressed: () async {
                        var res = await CallApi(context).postDataFuture(
                          {
                            "old_pin": oldpin.text,
                            "new_pin": newpin.text,
                            "new_pin_confirmation": newpinconfirm.text,
                          },
                          'user/updatePincode',
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
                          oldpin.clear();
                          newpin.clear();
                          newpinconfirm.clear();
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
