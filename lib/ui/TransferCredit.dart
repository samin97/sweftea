import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swfteaproject/providers/SwfTeaController.dart';
import 'package:swfteaproject/ui/widgets/generic/dialougeBox.dart';
import 'package:swfteaproject/ui/widgets/generic/nicebuttom.dart';
import 'package:swfteaproject/ui/widgets/textformfield.dart';
import 'package:swfteaproject/utlis/ApiProvider.dart';
import 'package:swfteaproject/utlis/Replacer.dart';

class TransferCredit extends StatefulWidget {
  final Controller controller = Get.find();
  @override
  _TransferCreditState createState() => _TransferCreditState();
}

class _TransferCreditState extends State<TransferCredit> {
  dynamic info = {'currentCredit': 0, 'pincode': 0};

  TextEditingController usernameController = TextEditingController();
  TextEditingController repeatUsernameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController pinCodeController = TextEditingController();
  @override
  void initState() {
    super.initState();

    dynamic arguments = Get.arguments;
    String user = arguments ?? '';
    usernameController.value = TextEditingValue(
      text: user,
      selection: TextSelection.collapsed(offset: user.length),
    );
    repeatUsernameController.value = TextEditingValue(
      text: user,
      selection: TextSelection.collapsed(offset: user.length),
    );
    new Future.delayed(Duration.zero, () async {
      var response =
          await CallApi(Get.context).getDataFuture('user/creditInfo');
      dynamic data = json.decode(response.body);
      setState(() {
        info = {'currentCredit': data['credit'], 'pincode': data['pincode']};
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transfer credits"),
      ),
      body: Card(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: ListView(
            children: <Widget>[
              Container(
                child: Text(
                  "Your transferable credit balance is " +
                      info['currentCredit'].toString() +
                      ' credits.',
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
                      title: "Credit transfer",
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    AppTextInputField(
                      elevation: false,
                      hint: "Username",
                      textEditingController: usernameController,
                      icon: Icons.supervised_user_circle,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    AppTextInputField(
                      elevation: false,
                      hint: "Repeat username",
                      textEditingController: repeatUsernameController,
                      icon: Icons.supervised_user_circle,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    AppTextInputField(
                      elevation: false,
                      hint: "Amount",
                      textEditingController: amountController,
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    AppTextInputField(
                      elevation: false,
                      hint: "Pin code",
                      textEditingController: pinCodeController,
                      icon: Icons.code,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    info['pincode'] != 0
                        ? NiceButton(
                            bgColor: Theme.of(context).primaryColor,
                            textColor: Colors.white,
                            child: Row(
                              children: <Widget>[
                                Text("Transfer"),
                              ],
                            ),
                            onPressed: () async {
                              var response =
                                  await CallApi(context).postDataFuture(
                                {
                                  'username': usernameController.text.trim(),
                                  'username_confirmation':
                                      repeatUsernameController.text.trim(),
                                  'pin': pinCodeController.text.trim(),
                                  'amount': amountController.text,
                                },
                                'user/transfer',
                              );
                              dynamic data = json.decode(response.body);

                              if (data['error'] ?? true) {
                                Get.dialog(
                                  CustomDialog(
                                    title: "Error",
                                    child: Text(data['message']),
                                  ),
                                );
                              } else {
                                Get.dialog(
                                  CustomDialog(
                                    title: "Sucecss",
                                    child: Text(data['message']),
                                  ),
                                );
                                usernameController.clear();
                                repeatUsernameController.clear();
                                pinCodeController.clear();
                                amountController.clear();
                              }
                            },
                          )
                        : Text(
                            'Please change pincode from setting first to start transaction.',
                            style: TextStyle(
                              color: Colors.red,
                            ),
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
