import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swfteaproject/constants/constants.dart';
import 'package:swfteaproject/ui/widgets/textformfield.dart';
import 'package:swfteaproject/utlis/ApiProvider.dart';
import 'package:swfteaproject/utlis/Replacer.dart';

class SearchUsers extends StatefulWidget {
  @override
  _SearchUsersState createState() => _SearchUsersState();
}

class _SearchUsersState extends State<SearchUsers> {
  ScrollController scrollController = ScrollController();
  TextEditingController textBox = TextEditingController();
  List<dynamic> allDatas;
  int nextpage;
  int allpages;
  bool discount = false;
  @override
  void initState() {
    setState(() {
      allDatas = [];
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
    var res = await CallApi(context).postData(
      {
        'search': textBox.text.trim(),
      },
      'user/search?page=' + nextpage.toString(),
    );
    var data = json.decode(res.body);
    List<dynamic> newdata = data['data'].toList();
    if (mounted) {
      setState(() {
        allDatas = [...allDatas, ...newdata];
        nextpage = (data['current_page'] < data['last_page'])
            ? data['current_page'] + 1
            : data['current_page'];
        allpages = data['last_page'];
      });
    }
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
        title: Text("Search users"),
      ),
      body: Column(
        children: <Widget>[
          AppTextInputField(
            hint: "Search Friends",
            textEditingController: textBox,
            keyboardType: TextInputType.text,
            icon: Icons.people,
            onTextChange: (value) {
              setState(() {
                allDatas = [];
                nextpage = 1;
                allpages = 1;
              });
              fetchData();
            },
          ),
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: 0.1,
                  child: Divider(),
                );
              },
              itemBuilder: (context, index) => _buildRow(
                allDatas[index],
              ),
              itemCount: allDatas.length,
              controller: scrollController,
            ),
          ),
        ],
      ),
    );
  }

  _buildRow(user) {
    return UserWithColorRaw(
      onPressed: () {
        Get.toNamed(PROFILE_SCREEN, arguments: {
          "id": user['username'],
        });
      },
      user: user,
    );
  }
}
