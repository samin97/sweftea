import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swfteaproject/constants/constants.dart';
import 'package:swfteaproject/utlis/ApiProvider.dart';
import 'package:swfteaproject/utlis/Replacer.dart';

class MyAccount extends StatefulWidget {
  @override
  _MyAccountState createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  dynamic userAccount;
  @override
  void initState() {
    setState(() {
      userAccount = {
        'credit': 0.0,
        'spentToday': 0.0,
        'levelbar': 100,
        'nextUpdateTime': 'Loading...',
        'currentLevelData': {
          'name': '',
        },
        'level': 0,
      };
    });
    super.initState();
    new Future.delayed(Duration.zero, () async {
      fetchAccountInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Account"),
      ),
      floatingActionButton: new FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          Get.toNamed(TRANSFER_SCREEN);
        },
        child: Icon(Icons.swap_horizontal_circle),
      ),
      body: Column(
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Balance'),
                      Text(userAccount['credit'].toString() + ' credits'),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Spent today'),
                      Text(userAccount['spentToday'].toString() + ' credits'),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Current level'),
                      Text(userAccount['currentLevelData']['name'].toString() +
                          ' (' +
                          userAccount['level'].toString() +
                          ')'),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: <Widget>[
                  //     Text('Time required for next level'),
                  //     Text(userAccount['nextUpdateTime'].toString()),
                  //   ],
                  // ),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  SizedBox(
                    height: 30,
                    child: SecondaryTitle(
                      title: "Level progress (" +
                          double.parse(
                                  (userAccount['levelbar'] * 100).toString())
                              .toStringAsFixed(2) +
                          "%)",
                    ),
                  ),
                  SizedBox(
                    height: 20,
                    child: LinearProgressIndicator(
                      value: double.parse(userAccount['levelbar'].toString()),
                      backgroundColor: Theme.of(context).secondaryHeaderColor,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SecondaryTitle(
            title: "Account histories",
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: AccountHistory(),
            ),
          ),
        ],
      ),
    );
  }

  fetchAccountInfo() async {
    var res = await CallApi(context).getDataFuture('user/getAccountInfo');
    print(json.decode(res.body));
    setState(() {
      userAccount = json.decode(res.body);
      userAccount['levelbar'] = userAccount['levelbar'] > userAccount['maxBar']
          ? 1
          : (userAccount['levelbar'] / userAccount['maxBar']);
    });
  }
}

class AccountHistory extends StatefulWidget {
  @override
  _AccountHistoryState createState() => _AccountHistoryState();
}

class _AccountHistoryState extends State<AccountHistory> {
  ScrollController scrollController = ScrollController();
  List<dynamic> allAccountHistories;
  int nextpage;
  int allpages;
  @override
  void initState() {
    setState(() {
      allAccountHistories = [];
      nextpage = 1;
      allpages = 1;
    });
    scrollController.addListener(() {});
    super.initState();
    new Future.delayed(Duration.zero, () async {
      fetchAccountHistories();
    });

    scrollController
      ..addListener(() {
        if (scrollController.position.pixels ==
                scrollController.position.maxScrollExtent &&
            nextpage < allpages) {
          fetchAccountHistories();
        }
      });
  }

  fetchAccountHistories({append: false}) async {
    var res = await CallApi(context).postData(
      {
        'type': 'All',
        'from': '01-01-1997',
        'to': '01-01-2222',
      },
      'accounthistory/search?page=' + nextpage.toString(),
    );
    var data = json.decode(res.body);
    List<dynamic> newdata = data['data'].toList();
    setState(() {
      allAccountHistories = [...allAccountHistories, ...newdata];
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
    return RefreshIndicator(
      child: ListView.builder(
        // separatorBuilder: (context, index) {
        //   return Divider(
        //     color: Colors.grey,
        //   );
        // },
        itemBuilder: (context, index) => _buildHistory(
          allAccountHistories[index],
        ),
        itemCount: allAccountHistories.length,
        controller: scrollController,
      ),
      onRefresh: () async {
        setState(() {
          allAccountHistories = [];
          nextpage = 1;
          allpages = 1;
        });
        fetchAccountHistories();
      },
    );
  }

  _buildHistory(history) {
    bool isAdded =
        double.parse(history['old_value']) < double.parse(history['new_value']);

    return Container(
      color: isAdded ? Colors.transparent : Colors.red[50],
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    history['message'],
                    style: TextStyle(fontSize: 15),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        '[',
                      ),
                      Text(
                        'O: ',
                      ),
                      Text(
                        history['old_value'].toString(),
                      ),
                      Text(
                        " | ",
                      ),
                      Text(
                        "N: ",
                      ),
                      Text(
                        history['new_value'].toString(),
                      ),
                      Text("]"),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "A: ",
                      ),
                      Text(
                        isAdded
                            ? "+" +
                                (double.parse(history['new_value']) -
                                        double.parse(history['old_value']))
                                    .toStringAsFixed(2)
                            : "-" +
                                (double.parse(history['old_value']) -
                                        double.parse(history['new_value']))
                                    .toStringAsFixed(2),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    Replacer().timeAgo(history['created_at']) ?? "NOT NOW",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            isAdded
                ? Icon(
                    Icons.trending_up,
                    color: Colors.green,
                    size: 25,
                  )
                : Icon(
                    Icons.trending_down,
                    color: Colors.red,
                    size: 25,
                  ),
          ],
        ),
      ),
    );
  }
}
