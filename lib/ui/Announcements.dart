import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swfteaproject/constants/constants.dart';
import 'package:swfteaproject/utlis/ApiProvider.dart';
import 'package:swfteaproject/utlis/Replacer.dart';

class Announcements extends StatefulWidget {
  @override
  _AnnouncementsState createState() => _AnnouncementsState();
}

class _AnnouncementsState extends State<Announcements> {
  ScrollController scrollController = ScrollController();
  TextEditingController textBox = TextEditingController();
  List<dynamic> allAnnouncements;
  int nextpage;
  int allpages;
  @override
  void initState() {
    setState(() {
      allAnnouncements = [];
      nextpage = 1;
      allpages = 1;
    });
    scrollController.addListener(() {});
    super.initState();
    new Future.delayed(Duration.zero, () async {
      fetchData();
    });

    scrollController
      ..addListener(() {
        if (scrollController.position.pixels ==
                scrollController.position.maxScrollExtent &&
            nextpage < allpages) {
          fetchData();
        }
      });
  }

  fetchData({append: false}) async {
    var res = await CallApi(context).getDataFuture(
      'announcements?page=' + nextpage.toString(),
    );
    var data = json.decode(res.body);
    List<dynamic> newdata = data['data'].toList();
    setState(() {
      allAnnouncements = [...allAnnouncements, ...newdata];
      nextpage = (data['current_page'] < data['last_page'])
          ? data['current_page'] + 1
          : data['current_page'];
      allpages = data['last_page'];
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Announcements"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return Divider(
                  color: Colors.grey,
                );
              },
              itemBuilder: (context, index) => _buildPage(
                allAnnouncements[index],
              ),
              itemCount: allAnnouncements.length,
              controller: scrollController,
            ),
          ),
        ],
      ),
    );
  }

  _buildPage(item) {
    return InkWell(
      child: Container(
        padding: const EdgeInsets.only(
          left: 15,
          right: 5,
          top: 5,
          bottom: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            item['image'] != null
                ? GestureDetector(
                    child: CachedNetworkImage(
                      imageUrl: Replacer().getPublicImagePath(item['image']),
                      width: 50,
                      height: 50,
                    ),
                    onTap: () {
                      Get.toNamed(VIEW_IMAGE, arguments: {
                        "images": [
                          {"path": Replacer().getPublicImagePath(item['image'])}
                        ],
                        "type": "network"
                      });
                    },
                  )
                : SizedBox(
                    height: 0.1,
                  ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Get.toNamed(VIEW_HTML, arguments: {
                    "title": item['title'],
                    "html": item['description'],
                  });
                },
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item['created_on'],
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Text(item['abstract']),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
