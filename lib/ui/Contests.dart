import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slide_countdown_clock/slide_countdown_clock.dart';
import 'package:swfteaproject/constants/constants.dart';
import 'package:swfteaproject/ui/widgets/generic/CountdownTimer.dart';
import 'package:swfteaproject/ui/widgets/generic/nicebuttom.dart';
import 'package:swfteaproject/utlis/ApiProvider.dart';
import 'package:swfteaproject/utlis/Replacer.dart';

class Contests extends StatefulWidget {
  @override
  _ContestsState createState() => _ContestsState();
}

class _ContestsState extends State<Contests> {
  ScrollController scrollController = ScrollController();
  List<dynamic> allDatas;
  int nextpage;
  int allpages;
  bool discount = false;
  GlobalKey _scaffoldKey;
  bool isGridView = true;
  @override
  void initState() {
    setState(() {
      allDatas = [];
      nextpage = 1;
      allpages = 1;
      _scaffoldKey = GlobalKey<ScaffoldState>();
    });
    scrollController.addListener(() {});
    super.initState();
    new Future.delayed(Duration.zero, () async {
      fetchDatas();
    });

    scrollController
      ..addListener(() {
        if (scrollController.position.pixels ==
                scrollController.position.maxScrollExtent &&
            nextpage < allpages) {
          fetchDatas();
        }
      });
  }

  fetchDatas({append: false}) async {
    var res = await CallApi(context).getData(
      'swfteacontest?page=' + nextpage.toString(),
    );
    var data = json.decode(res.body);
    List<dynamic> newdata = data['data'].toList();
    setState(() {
      allDatas = [...allDatas, ...newdata];
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
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("All Contests"),
        actions: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                icon: !isGridView ? Icon(Icons.grid_on) : Icon(Icons.list),
                onPressed: () {
                  setState(() {
                    isGridView = !isGridView;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: isGridView
                ? GridView.builder(
                    itemCount: allDatas.length,
                    controller: scrollController,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 252.0,
                      crossAxisSpacing: 5.0,
                      mainAxisSpacing: 5.0,
                      childAspectRatio: 0.9,
                    ),
                    itemBuilder: (context, index) => _buildDataGrid(
                      allDatas[index],
                    ),
                  )
                : ListView.separated(
                    separatorBuilder: (context, index) {
                      return Divider(
                        color: Colors.grey,
                      );
                    },
                    itemBuilder: (context, index) => _buildDataList(
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

  _buildDataGrid(data) {
    return InkWell(
      onTap: () {
        Get.toNamed(CONTEST_SINGLE_PAGE, arguments: data);
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: Colors.grey.withAlpha(50)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Theme.of(context).primaryColor.withAlpha(150),
              child: SizedBox(
                child: CachedNetworkImage(
                  imageUrl: Replacer().getPublicImagePath(data['image']),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
                height: 100,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: PrimaryTitle(
                title: data['title'],
              ),
            ),
            data['phase'] == 'NOT_STARTED'
                ? Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'STARTS IN',
                        ),
                        SlideCountdownClock(
                          duration: Duration(
                            seconds: data['start_time'],
                          ),
                          separatorTextStyle: TextStyle(
                            color: Theme.of(context).secondaryHeaderColor,
                            fontWeight: FontWeight.bold,
                          ),
                          padding: EdgeInsets.all(5),
                          shouldShowDays: false,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.rectangle,
                          ),
                          textStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(
                    height: 0.001,
                  ),
            data['phase'] == 'RUNNING'
                ? Center(
                    child: Container(
                      width: 128,
                      height: 64,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.green[800],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          LinearProgressIndicator(
                            backgroundColor:
                                Theme.of(context).secondaryHeaderColor,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SizedBox(
                    height: 0.001,
                  ),
            data['phase'] == 'ENDED'
                ? Center(
                    child: NiceButton(
                    radius: 0,
                    child: Text("ENDED"),
                  ))
                : SizedBox(
                    height: 0.001,
                  ),
          ],
        ),
      ),
    );
  }

  _buildDataList(data) {
    return Container(
      color:
          data['id'] % 2 == 1 ? Colors.grey.withAlpha(100) : Colors.transparent,
      child: InkWell(
        onTap: () {
          Get.toNamed(CONTEST_SINGLE_PAGE, arguments: data);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CachedNetworkImage(
                imageUrl: Replacer().getPublicImagePath(data['image']),
                height: 48,
                width: 48,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PrimaryTitle(
                        title: data['title'],
                      ),
                      data['phase'] == 'NOT_STARTED'
                          ? Center(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    'STARTS IN',
                                  ),
                                  SlideCountdownClock(
                                    duration: Duration(
                                      seconds: data['start_time'],
                                    ),
                                    separatorTextStyle: TextStyle(
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    padding: EdgeInsets.all(5),
                                    shouldShowDays: false,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      shape: BoxShape.rectangle,
                                    ),
                                    textStyle: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(
                              height: 0.001,
                            )
                    ],
                  ),
                ),
              ),
              data['phase'] == 'RUNNING'
                  ? Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.timer,
                              size: 10,
                              color: Theme.of(context).primaryColor,
                            ),
                            CountDownTimer(
                              secondsRemaining: data['end_time'],
                              countDownTimerStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        Center(
                          child: Container(
                            width: 100,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(0),
                              color: Colors.green[800],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                LinearProgressIndicator(
                                  backgroundColor:
                                      Theme.of(context).secondaryHeaderColor,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(
                      height: 0.001,
                    ),
              data['phase'] == 'ENDED'
                  ? NiceButton(
                      radius: 0,
                      child: Text("ENDED"),
                    )
                  : SizedBox(
                      height: 0.001,
                    )
            ],
          ),
        ),
      ),
    );
  }
}
