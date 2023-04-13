import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:hexcolor/hexcolor.dart';
import 'package:swfteaproject/constants/constants.dart';
import 'package:swfteaproject/ui/widgets/generic/dialougeBox.dart';
import 'package:swfteaproject/ui/widgets/generic/nicebuttom.dart';
import 'package:swfteaproject/ui/widgets/textformfield.dart';
import 'package:swfteaproject/utlis/ApiProvider.dart';
import 'package:swfteaproject/utlis/Replacer.dart';

class MerchantPanel extends StatefulWidget {
  @override
  _MerchantPanelState createState() => _MerchantPanelState();
}

class _MerchantPanelState extends State<MerchantPanel> {
  dynamic panel = {"merchantpanel": {}};
  List applications = [];
  bool haveAccess = false;
  @override
  void initState() {
    super.initState();
    new Future.delayed(Duration.zero, () async {
      var response = await CallApi(context).getDataFuture('merchant/panel');
      dynamic data = json.decode(response.body);
      setState(() {
        panel = data;
        haveAccess = data['isMerchant'];
      });
    });
  }

  _fetchApplications() async {
    var response = await CallApi(Get.context).postDataFuture({
      "type": "all",
    }, 'merchant/myApplicationList');
    var data = json.decode(response.body);
    setState(() {
      applications = data;
    });
    List<Widget> allapplications = [];
    for (var e in applications) {
      allapplications.add(
        InkWell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                e['title'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                e['status_message'],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    e['head_person']['username'],
                    style: TextStyle(color: Colors.blue),
                  ),
                  Text(
                    Replacer().getApplicationStatus(e['status'] ?? 5),
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
              Divider(),
            ],
          ),
        ),
      );
    }

    Get.dialog(
      CustomDialog(
        title: "Applications",
        child: Flexible(
          child: ListView(
            children: <Widget>[...allapplications],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget renewAsMerchant(String title) {
      String mentorusername;
      return Padding(
        padding: const EdgeInsets.all(5),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              children: <Widget>[
                Icon(
                  Icons.recent_actors,
                  color: Theme.of(context).primaryColor,
                  size: 100,
                ),
                Text(title),
                NiceButton(
                  bgColor: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  onPressed: () {
                    Get.dialog(
                      CustomDialog(
                        title: title,
                        child: Column(
                          children: <Widget>[
                            AppTextInputField(
                              elevation: false,
                              textEditingController:
                                  TextEditingController(text: mentorusername),
                              hint: "Menor username",
                              keyboardType: TextInputType.text,
                              icon: Icons.people,
                              onTextChange: (value) {
                                mentorusername = value;
                              },
                            ),
                          ],
                        ),
                        onSubmit: () async {
                          if (mentorusername.length > 1) {
                            var response =
                                await CallApi(context).postDataFuture(
                              {
                                "under_of": mentorusername,
                                "message": "Merchant renewal proposal.",
                              },
                              'merchant/requestForMerchantship',
                            );
                            dynamic res = json.decode(response.body);

                            if (res['error'] ?? true) {
                              Get.dialog(
                                CustomDialog(
                                  title: "Error",
                                  child: Text(res['message']['messages'][0]
                                      ['description']),
                                ),
                              );
                            } else {
                              Get.dialog(
                                CustomDialog(
                                  title: "Success",
                                  child: Text(res['message']['messages'][0]
                                      ['description']),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    );
                  },
                  child: Text((panel['merchantpanel']['merchant_cost'] ?? 0)
                          .toString() +
                      " credits"),
                )
              ],
            ),
          ),
        ),
      );
    }

    String mentorusername = '', headmentorusername = '';
    List<Widget> tags = [];
    for (var e in panel['tags'] ?? []) {
      tags.add(
        InkWell(
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          e['username'],
                          style: TextStyle(
                            // color: HexColor(e['color']),
                          ),
                        ),
                        Text(" "),
                        Text(
                          "(" + e['name'] + ")",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text('L: ' + e['level']['value'].toString()),
                        Text(' | '),
                        Text(e['country']),
                      ],
                    )
                  ],
                ),
              ),
              Divider(),
            ],
          ),
          onTap: () {
            Get.toNamed(PROFILE_SCREEN, arguments: {"id": e['username']});
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Merchant Panel"),
      ),
      body: !haveAccess
          ? Container(
              child: Center(
                child: SizedBox(
                  height: 250,
                  child: renewAsMerchant("Apply for merchantship"),
                ),
              ),
            )
          : ListView(
              children: <Widget>[
                Card(
                  child: Container(
                    color: Colors.deepPurple,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            panel['name'],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                "Merchant expiry: ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  panel['merchant_expiry'],
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                "Balance: ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  panel['credit'].toString() + ' credits',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                "Tagged by: ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  panel['tagged_by']['username'].toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SecondaryTitle(
                          title: "Mission status (" +
                              panel['barCompleted'].toString() +
                              "%)",
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          height: 20,
                          child: LinearProgressIndicator(
                            value: panel['barCompleted'] / 100,
                            backgroundColor: Colors.grey,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SecondaryTitle(
                          title: "Merchant menu",
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            renewAsMerchant("Renew as merchant"),
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Column(
                                    children: <Widget>[
                                      Icon(
                                        Icons.unarchive,
                                        color: Colors.green,
                                        size: 100,
                                      ),
                                      Text("Upgrade as mentor"),
                                      NiceButton(
                                        bgColor: Colors.green,
                                        textColor: Colors.white,
                                        onPressed: () {
                                          Get.dialog(
                                            CustomDialog(
                                              title: "Upgrade to mentor",
                                              child: Column(
                                                children: <Widget>[
                                                  AppTextInputField(
                                                    elevation: false,
                                                    textEditingController:
                                                        TextEditingController(
                                                            text:
                                                                headmentorusername),
                                                    hint: "Head Menor username",
                                                    keyboardType:
                                                        TextInputType.text,
                                                    icon: Icons.people,
                                                    onTextChange: (value) {
                                                      headmentorusername =
                                                          value;
                                                    },
                                                  ),
                                                ],
                                              ),
                                              onSubmit: () async {
                                                if (headmentorusername.length >
                                                    1) {
                                                  var response =
                                                      await CallApi(context)
                                                          .postDataFuture(
                                                    {
                                                      "under_of":
                                                          mentorusername,
                                                      "message":
                                                          "Mentor upgrade proposal.",
                                                    },
                                                    'mentor/requestForMentorship',
                                                  );
                                                  dynamic res = json
                                                      .decode(response.body);

                                                  if (res['error'] ?? true) {
                                                    Get.dialog(
                                                      CustomDialog(
                                                        title: "Error",
                                                        child: Text(res[
                                                                    'message']
                                                                ['messages'][0]
                                                            ['description']),
                                                      ),
                                                    );
                                                  } else {
                                                    Get.dialog(
                                                      CustomDialog(
                                                        title: "Success",
                                                        child: Text(res[
                                                                    'message']
                                                                ['messages'][0]
                                                            ['description']),
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                            ),
                                          );
                                        },
                                        child: Text(panel['mentorpanel']
                                                    ['mentor_cost']
                                                .toString() +
                                            " credits"),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                          ),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "My Applications",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  NiceButton(
                                    bgColor: Theme.of(context).primaryColor,
                                    textColor: Colors.white,
                                    child: Text("View"),
                                    onPressed: () {
                                      _fetchApplications();
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                          ),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "Tag lists",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  NiceButton(
                                    bgColor: Theme.of(context).primaryColor,
                                    textColor: Colors.white,
                                    child: Text("View"),
                                    onPressed: () {
                                      Get.dialog(
                                        CustomDialog(
                                          title: "My Tags",
                                          child: Flexible(
                                            child: ListView(
                                              children: tags,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
