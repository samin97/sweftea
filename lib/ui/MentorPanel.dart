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

class MentorPanel extends StatefulWidget {
  @override
  _MentorPanelState createState() => _MentorPanelState();
}

class _MentorPanelState extends State<MentorPanel> {
  dynamic panel = {};
  List applications = [];
  bool haveAccess = false;
  @override
  void initState() {
    super.initState();
    new Future.delayed(Duration.zero, () async {
      var response = await CallApi(context).getDataFuture('mentor/panel');
      dynamic data = json.decode(response.body);
      setState(() {
        panel = data;
        haveAccess = data['isMentor'];
      });
    });
  }

  _fetchApplications() async {
    var response = await CallApi(Get.context).postDataFuture({
      "type": "all",
    }, 'mentor/myApplicationList');
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

  _fetchRequests() async {
    var response = await CallApi(Get.context).postDataFuture({
      "type": "all",
    }, 'mentor/myActionList');
    var data = json.decode(response.body);
    List<Widget> allrequests = [];
    for (var e in data) {
      allrequests.add(
        Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        e['sender']['username'],
                        style: TextStyle(
                          // color: HexColor(e['sender']['color']),
                        ),
                      ),
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
                            e['created_on'],
                            style: TextStyle(color: Colors.blue),
                          ),
                          Text(
                            Replacer().getApplicationStatus(e['status'] ?? 5),
                            style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                e['status'] == 1
                    ? Padding(
                        padding: const EdgeInsets.only(
                          left: 5,
                          right: 5,
                        ),
                        child: Column(
                          children: <Widget>[
                            NiceButton(
                              bgColor: Colors.deepPurple,
                              textColor: Colors.white,
                              child: Text('Accept'),
                              onPressed: () {
                                _processRequest(e['id'], 'accept');
                              },
                            ),
                            NiceButton(
                              bgColor: Colors.red,
                              textColor: Colors.white,
                              child: Text('Reject'),
                              onPressed: () {
                                _processRequest(e['id'], 'reject');
                              },
                            ),
                          ],
                        ),
                      )
                    : SizedBox(
                        height: 0.1,
                      ),
              ],
            ),
            Divider(),
          ],
        ),
      );
    }

    Get.dialog(
      CustomDialog(
        title: "Requests",
        child: Flexible(
          child: ListView(
            children: <Widget>[...allrequests],
          ),
        ),
      ),
    );
  }

  _processRequest(int id, String type) async {
    Get.back();
    var response = await CallApi(context).postDataFuture(
      {
        "type": type,
        "application_id": id,
      },
      'mentor/takeAction',
    );
    dynamic res = json.decode(response.body);
    if (res['error'] ?? true) {
      Get.dialog(
        CustomDialog(
          title: "Error",
          child: Center(
            child: Text(res['message']['messages'][0]['description']),
          ),
        ),
      );
    } else {
      Get.dialog(
        CustomDialog(
          title: res['message']['header'],
          child: Center(
            child: Text(res['message']['messages'][0]['description']),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text("Mentor Panel"),
      ),
      body: !haveAccess
          ? Container(
              child: Center(
                child: Text('This panel is not for you.'),
              ),
            )
          : ListView(
              children: <Widget>[
                Card(
                  child: Container(
                    color: Colors.redAccent,
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
                                "Mentor expiry: ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  panel['mentor_expiry'],
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
                          title: "Mentor menu",
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
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
                                      Text("Renew as mentor"),
                                      NiceButton(
                                        bgColor: Colors.green,
                                        textColor: Colors.white,
                                        onPressed: () {
                                          Get.dialog(
                                            CustomDialog(
                                              title: "Renew as mentor",
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
                                                          headmentorusername,
                                                      "message":
                                                          "Mentor renew proposal.",
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
                                    "Requests",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  NiceButton(
                                    bgColor: Theme.of(context).primaryColor,
                                    textColor: Colors.white,
                                    child: Text("View"),
                                    onPressed: () {
                                      _fetchRequests();
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
