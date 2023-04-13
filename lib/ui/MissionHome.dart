import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
// import 'package:hexcolor/hexcolor.dart';
import 'package:slide_countdown_clock/slide_countdown_clock.dart';
import 'package:swfteaproject/constants/constants.dart';
import 'package:swfteaproject/ui/widgets/generic/dialougeBox.dart';
import 'package:swfteaproject/ui/widgets/generic/nicebuttom.dart';
import 'package:swfteaproject/utlis/ApiProvider.dart';
import 'package:swfteaproject/utlis/Replacer.dart';

class MissionHome extends StatefulWidget {
  @override
  _MissionHomeState createState() => _MissionHomeState();
}

class _MissionHomeState extends State<MissionHome>
    with SingleTickerProviderStateMixin {
  dynamic data;
  bool isLoading = true;
  int seasonid = 0;
  int activeweek = 0;
  setLandscapeOrientation() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  }

  TabController _tabController;
  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    setState(() {
      seasonid = Get.arguments;
    });
    new Future.delayed(Duration.zero, () async {
      var res = await CallApi(context)
          .getDataFuture("swfteamission/getseason/" + seasonid.toString());
      dynamic ses = json.decode(res.body);
      setState(() {
        data = ses;
        isLoading = false;
        activeweek = ses['season']['weeks'].length - 1;
      });
      if (!ses['week_over']) {
        for (var week in ses['season']['weeks']) {
          if (week['id'] == ses['season']['active_week']['id']) {
            activeweek = ses['season']['weeks'].indexOf(week);
          }
        }
      }
      setState(() {
        _tabController = new TabController(
          vsync: this,
          length: data['season']['weeks'].length,
          initialIndex: activeweek,
        );
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Tab> _tabs = [];
    List<TabContent> _tabcontents = [];
    List<Widget> _milestones = [];
    if (!isLoading) {
      for (var week in data['season']['weeks']) {
        _tabs.add(
          Tab(
            child: Align(
              alignment: Alignment.center,
              child: Text(week['name']),
            ),
          ),
        );
        _tabcontents.add(
          TabContent(
            tasks: week['tasks'],
            seasonid: seasonid,
          ),
        );
      }
      for (var milestone in data['season']['milestones_details']) {
        switch (milestone['type']) {
          case 'start':
            _milestones.add(
              Container(
                height: 20,
                color: Colors.green,
                // width: 20,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 5,
                    right: 5,
                  ),
                  child: Center(
                    child: MissionText(
                      color: Colors.white,
                      text: milestone['label'],
                      size: 14,
                    ),
                  ),
                ),
              ),
            );
            break;
          case 'completed':
            _milestones.add(
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(40.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 5,
                    right: 5,
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/icons/check.png',
                      height: 14,
                    ),
                  ),
                ),
              ),
            );
            break;
          case 'readytoopen':
            _milestones.add(
              GestureDetector(
                child: Container(
                  height: 20,
                  // color: HexColor("#111111"),
                  // width: 20,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 5,
                      right: 5,
                    ),
                    child: Center(
                      child: MissionText(
                        color: Colors.white,
                        text: milestone['label'],
                        size: 14,
                      ),
                    ),
                  ),
                ),
                onTap: () async {
                  var res = await CallApi(context).getDataFuture(
                      'swfteamission/grab/' + milestone['id'].toString());
                  dynamic data = json.decode(res.body);
                  print(data);
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
                        title: "Success",
                        child: Text(data['message']),
                        buttonText: "Reload",
                        onSubmit: () {
                          Navigator.pushReplacementNamed(context, MISSION_HOME,
                              arguments: seasonid);
                        },
                      ),
                    );
                  }
                },
              ),
            );
            break;
          case '100':
            _milestones.add(
              GestureDetector(
                onTap: () {
                  Get.dialog(
                    CustomDialog(
                      title: "100 SRP Rewards",
                      child: Center(
                        child: Text(milestone['abstract']),
                      ),
                    ),
                  );
                },
                child: Container(
                  color: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  child: MissionText(
                    color: Colors.white,
                    text: '100',
                  ),
                ),
              ),
            );
            break;
          case 'notcompleted':
            _milestones.add(
              GestureDetector(
                onTap: () {
                  Get.dialog(
                    CustomDialog(
                      title: milestone['label'],
                      child: Center(
                        child: Text(milestone['abstract']),
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 20,
                  // width: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 5,
                      right: 5,
                    ),
                    child: Center(
                      child: MissionText(
                        color: Colors.white,
                        text: milestone['label'],
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ),
            );
            break;
          default:
        }
      }
    }

    if (MediaQuery.of(context).orientation != null) {
      setLandscapeOrientation();
    }

    return SafeArea(
      child: Scaffold(
        body: isLoading
            ? SizedBox(
                height: 5,
              )
            : Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      Replacer()
                          .getPublicImagePath(data['season']['background']),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      // color: Colors.white60,
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Color.fromRGBO(84, 4, 6, 0.7),
                                      ),
                                      child: data['week_over']
                                          ? Column(
                                              children: [
                                                MissionText(
                                                  text: "SEASON ENDED",
                                                  size: 21,
                                                  isBold: true,
                                                  // color: HexColor('#F5AE37'),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                MissionText(
                                                  text: "This season is over.",
                                                  color: Theme.of(context)
                                                      .secondaryHeaderColor,
                                                ),
                                              ],
                                            )
                                          : Column(
                                              children: [
                                                MissionText(
                                                  text: data['season']
                                                      ['active_week']['name'],
                                                  size: 21,
                                                  isBold: true,
                                                  // color: HexColor('#F5AE37'),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                SlideCountdownClock(
                                                  duration: Duration(
                                                      seconds: data['season']
                                                              ['active_week']
                                                          ['expire_time']),
                                                  padding: EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                    // color: HexColor('#F5AE37'),
                                                    shape: BoxShape.rectangle,
                                                  ),
                                                  shouldShowDays: false,
                                                  textStyle: TextStyle(
                                                    fontSize: 8,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'MissionText',
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                MissionText(
                                                  text: data['season']
                                                          ['active_week']
                                                      ['abstract'],
                                                  color: Theme.of(context)
                                                      .secondaryHeaderColor,
                                                ),
                                              ],
                                            ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Flexible(
                                      child: Stack(
                                        children: [
                                          data['week_over']
                                              ? CachedNetworkImage(
                                                  height: 200,
                                                  width: 250,
                                                  imageUrl:
                                                      'https://scontent.fktm10-1.fna.fbcdn.net/v/t1.15752-9/119292138_630153744337101_9142473029625308099_n.png?_nc_cat=111&_nc_sid=b96e70&_nc_ohc=e0DfOfdj5FgAX8aNTtP&_nc_ht=scontent.fktm10-1.fna&oh=de0f42e9628b91090239baa7c104a902&oe=5F8AA4B8',
                                                )
                                              : CachedNetworkImage(
                                                  height: 200,
                                                  width: 250,
                                                  imageUrl: Replacer()
                                                      .getPublicImagePath(data[
                                                                  'season']
                                                              ['active_week']
                                                          ['banner']),
                                                ),
                                          Positioned(
                                            top: 10,
                                            right: 70,
                                            child: WeekSRPBubble(
                                                points: data['season']
                                                    ['week_point']),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 60,
                                        color: Color.fromRGBO(84, 4, 6, 0.7),
                                        child: Center(
                                          child: MissionText(
                                            // color: HexColor('#F5B839'),
                                            text: "TOTAL COLLECTED SRP: " +
                                                data['season']['me']['points']
                                                    .toString(),
                                            size: 32,
                                            isBold: true,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 30,
                                        child: Stack(
                                          children: [
                                            Center(
                                              child: Container(
                                                height: 5,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: _milestones,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          color: Color.fromRGBO(84, 4, 6, 0.7),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: DefaultTabController(
                                              length: _tabcontents.length,
                                              child: Column(
                                                children: [
                                                  TabBar(
                                                    controller: _tabController,
                                                    unselectedLabelColor:
                                                        Colors.grey[350],
                                                    indicatorSize:
                                                        TabBarIndicatorSize.tab,
                                                    labelStyle: TextStyle(
                                                      fontFamily: "MissionFont",
                                                      letterSpacing: 1.2,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    labelColor:Colors.white,
                                                        // HexColor('#FFB539')Colors.white,,
                                                    indicatorColor:
                                                    Colors.white,
                                                    // HexColor('#FFB539'),
                                                    indicatorWeight: 0.0001,
                                                    tabs: _tabs,
                                                  ),
                                                  Expanded(
                                                    child: TabBarView(
                                                      controller:
                                                          _tabController,
                                                      children: _tabcontents,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 4,
                        left: 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            NiceButton(
                              radius: 1.0,
                              // bgColor: HexColor('#222222'),
                              onPressed: () {
                                Get.back();
                              },
                              // textColor: Colors.white,
                              child: MissionText(
                                text: "BACK",
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class TabContent extends StatelessWidget {
  TabContent({this.tasks, this.seasonid});
  final dynamic tasks;
  final int seasonid;
  @override
  Widget build(BuildContext context) {
    if (tasks.length > 0) {
      return Container(
        height: double.infinity,
        width: double.infinity,
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            separatorBuilder: (context, index) => SizedBox(
              height: 1,
            ),
            itemCount: tasks.length,
            itemBuilder: (context, index) => TabContentItem(
              task: tasks[index],
              seasonid: seasonid,
            ),
          ),
        ),
      );
    } else {
      return Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.black26,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock,
                color: Colors.white,
                size: 20,
              ),
              MissionText(
                text: "LOCKED",
                // color: HexColor("#ffffff"),
                size: 25,
              ),
              MissionText(
                text: "Tasks for this week is not available.",
                // color: HexColor("#F5B839"),
                size: 18,
              ),
            ],
          ),
        ),
      );
    }
  }
}

class TabContentItem extends StatefulWidget {
  TabContentItem({this.task, this.seasonid});
  final dynamic task;
  final int seasonid;
  @override
  _TabContentItemState createState() => _TabContentItemState();
}

class _TabContentItemState extends State<TabContentItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.dialog(
          CustomDialog(
            image: Image.network(
                Replacer().getPublicImagePath(widget.task['banner'])),
            title: widget.task['name'],
            child: Center(
              child: MissionText(
                text: widget.task['abstract'],
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.only(
          right: 10,
          left: 10,
        ),
        decoration: BoxDecoration(
          // color: HexColor('#222222'),
          borderRadius: BorderRadius.circular(0),
        ),
        child: Row(
          children: [
            CachedNetworkImage(
                height: 40,
                imageUrl: Replacer().getPublicImagePath(widget.task['banner'])),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(
                  left: 20,
                  right: 10,
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.task['name'],
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "MissionFont",
                          letterSpacing: 1.2,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: 8,
                            // color: HexColor('#F5B839'),
                          ),
                          MissionText(
                            size: 8,
                            color: Colors.white,
                            text: widget.task['reward'].toString() + " credits",
                          )
                        ],
                      )
                    ]),
              ),
            ),
            MissionCompleted(
              value: double.parse(widget.task['progress'].toString()),
              outof: double.parse(widget.task['amount'].toString()),
              isCollected: widget.task['is_completed'],
              weekid: widget.task['pivot']['week_id'],
              taskid: widget.task['pivot']['task_id'],
              seasonid: widget.seasonid,
            ),
          ],
        ),
      ),
    );
  }
}

class MissionCompleted extends StatelessWidget {
  MissionCompleted({
    this.value = 10,
    this.outof = 100,
    this.isCollected = false,
    this.weekid,
    this.seasonid,
    this.taskid,
  });
  final double value;
  final double outof;
  final int weekid;
  final int taskid;
  final int seasonid;
  final bool isCollected;
  @override
  Widget build(BuildContext context) {
    return this.isCollected
        ? MissionText(
            // color: HexColor('#F5AE37'),
            text: "COLLECTED",
            size: 10,
          )
        : this.value >= this.outof
            ? NiceButton(
                // bgColor: HexColor('#111111'),
                // textColor: HexColor('#111111'),
                onPressed: () async {
                  var res = await CallApi(context).getDataFuture(
                      'swfteamission/collect/' +
                          weekid.toString() +
                          '/' +
                          taskid.toString());
                  dynamic data = json.decode(res.body);
                  if (!data['error']) {
                    Get.dialog(
                      CustomDialog(
                        title: "Success",
                        child: Center(
                          child: Text(data['message']),
                        ),
                        buttonText: "Reload",
                        onSubmit: () {
                          Navigator.pushReplacementNamed(context, MISSION_HOME,
                              arguments: seasonid);
                        },
                      ),
                    );
                  } else {
                    Get.dialog(
                      CustomDialog(
                        title: "Error",
                        child: Text(data['message']),
                      ),
                    );
                  }
                },
                child: MissionText(
                  text: "COLLECT",
                  // color: HexColor('#F5AE37'),
                ),
                radius: 0,
              )
            : Column(
                children: [
                  MissionText(
                    color: Colors.white,
                    text: this.value.toString() + "/" + this.outof.toString(),
                  ),
                  MissionText(
                    color: Colors.white,
                    text: 'COLLECTED',
                    size: 8,
                  ),
                ],
              );
  }
}

class WeekSRPBubble extends StatefulWidget {
  final dynamic points;
  WeekSRPBubble({this.points});
  @override
  _WeekSRPBubbleState createState() => _WeekSRPBubbleState();
}

class _WeekSRPBubbleState extends State<WeekSRPBubble> {
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
        });
      },
      child: RotationTransition(
        turns: AlwaysStoppedAnimation(45 / 360),
        child: Container(
          child: RotationTransition(
            turns: AlwaysStoppedAnimation(-45 / 360),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MissionText(
                  text: widget.points.toString(),
                  size: 30,
                  // color: HexColor('#7a0724'),
                  isBold: true,
                ),
                MissionText(
                  text: "SRP",
                  size: 10,
                )
              ],
            ),
          ),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white60 : Colors.white70,
            borderRadius: BorderRadius.only(
              bottomLeft:
                  isSelected ? Radius.circular(10.0) : Radius.circular(0),
              topRight: isSelected ? Radius.circular(10.0) : Radius.circular(0),
              topLeft:
                  isSelected ? Radius.circular(0.0) : Radius.circular(10.0),
              bottomRight:
                  isSelected ? Radius.circular(0.0) : Radius.circular(10.0),
            ),
          ),
          height: 75,
          width: 75,
        ),
      ),
    );
  }
}
