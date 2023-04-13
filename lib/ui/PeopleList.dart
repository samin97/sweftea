import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:hexcolor/hexcolor.dart';
import 'package:swfteaproject/constants/constants.dart';
import 'package:swfteaproject/ui/widgets/generic/dialougeBox.dart';
import 'package:swfteaproject/utlis/ApiProvider.dart';

class PeopleList extends StatefulWidget {
  @override
  _PeopleListState createState() => _PeopleListState();
}

class _PeopleListState extends State<PeopleList> {
  List users = [];
  fetchUser({String type}) async {
    var res = await CallApi(context).getDataFuture(
      'user/findUsers/' + type.toString(),
    );
    var data = json.decode(res.body);
    setState(() {
      users = data;
    });
    Get.dialog(
      CustomDialog(
        title: "Users",
        child: Flexible(
          child: ListView(
            children: users.map((e) {
              return InkWell(
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
                  if (Get.isDialogOpen) {
                    Get.back();
                  }
                  Get.toNamed(PROFILE_SCREEN, arguments: {"id": e['username']});
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Peoples"),
      ),
      body: ListView(
        children: <Widget>[
          InkWell(
            onTap: () {
              fetchUser(type: 'staff');
            },
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 10, right: 10, top: 10, bottom: 10),
              child: Row(
                children: <Widget>[
                  Image.asset(
                    'assets/images/badges/Admin.png',
                    height: 50,
                    width: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'Official',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(),
          InkWell(
            onTap: () {
              fetchUser(type: 'gadmin');
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  Image.asset(
                    'assets/images/badges/Global_Admin.png',
                    height: 50,
                    width: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'Global Admin',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(),
          InkWell(
            onTap: () {
              fetchUser(type: 'mhead');
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  Image.asset(
                    'assets/images/badges/Mentor_Head.png',
                    height: 50,
                    width: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'Mentor Head',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(),
          InkWell(
            onTap: () {
              fetchUser(type: 'mentor');
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  Image.asset(
                    'assets/images/badges/Mentor.png',
                    height: 50,
                    width: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'Mentor',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(),
          InkWell(
            onTap: () {
              fetchUser(type: 'merchant');
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  Image.asset(
                    'assets/images/badges/Merchant.png',
                    height: 50,
                    width: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'Merchant',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(),
          InkWell(
            onTap: () {
              fetchUser(type: 'legends');
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  Image.asset(
                    'assets/images/badges/Legends.png',
                    height: 50,
                    width: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'Legend',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(),
          InkWell(
            onTap: () {
              fetchUser(type: 'seniorprofiles');
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  Image.asset(
                    'assets/images/badges/SeniorProfile.png',
                    height: 50,
                    width: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'Senior Profiles',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
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
