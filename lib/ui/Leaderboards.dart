import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swfteaproject/constants/constants.dart';
import 'package:swfteaproject/ui/widgets/textformfield.dart';
import 'package:swfteaproject/utlis/ApiProvider.dart';
import 'package:swfteaproject/utlis/Replacer.dart';

class Leaderboards extends StatefulWidget {
  @override
  _LeaderboardsState createState() => _LeaderboardsState();
}

class _LeaderboardsState extends State<Leaderboards> {
  List datas;
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
      'leaderboards',
    );
    var data = json.decode(res.body);
    datas.clear();
    for (var item in data.keys) {
      data[item]['key'] = item;
      datas.add(data[item]);
    }
    setState(() {
      datas = datas;
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
        title: Text("Leaderboards"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) => _buildRow(
                datas[index],
              ),
              itemCount: datas.length,
            ),
          ),
        ],
      ),
    );
  }

  _buildRow(item) {
    return InkWell(
      onTap: () {
        Get.toNamed(
          VIEW_LEADERBOARD,
          arguments: {
            "key": item['key'],
            "title": item['title'],
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: ICON_URL + item['image'],
              height: 40,
              width: 40,
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      item['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item['description'],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
