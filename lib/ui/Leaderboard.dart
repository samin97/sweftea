import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swfteaproject/constants/constants.dart';
import 'package:swfteaproject/ui/widgets/textformfield.dart';
import 'package:swfteaproject/utlis/ApiProvider.dart';
import 'package:swfteaproject/utlis/Replacer.dart';

class Leaderboard extends StatefulWidget {
  @override
  _LeaderboardState createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  List datas;
  dynamic arguments = Get.arguments;
  @override
  void initState() {
    setState(() {
      datas = [];
    });
    super.initState();
    new Future.delayed(Duration.zero, () async {
      fetchDatas();
    });
  }

  fetchDatas({append: false}) async {
    var res = await CallApi(context).getDataFuture(
      'leaderboard/' + arguments['key'],
    );
    var data = json.decode(res.body);
    setState(() {
      datas = data;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(arguments['title']),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return Divider();
              },
              itemBuilder: (context, index) => _buildRow(datas[index], index),
              itemCount: datas.length,
            ),
          ),
        ],
      ),
    );
  }

  _buildRow(item, index) {
    return InkWell(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              child: Text((index + 1).toString()),
              backgroundColor: (index + 1) > 3
                  ? Colors.grey
                  : Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Text(
                  item['username'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: Text(
                item['total'].toString(),
              ),
            )
          ],
        ),
      ),
      onTap: () {},
    );
  }
}
