import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swfteaproject/constants/constants.dart';
import 'package:swfteaproject/ui/widgets/generic/CountdownTimer.dart';
import 'package:swfteaproject/utlis/ApiProvider.dart';
import 'package:swfteaproject/utlis/Replacer.dart';

class BettingSystem extends StatefulWidget {
  @override
  _BettingSystemState createState() => _BettingSystemState();
}

class _BettingSystemState extends State<BettingSystem> {
  List matches = [];
  @override
  void initState() {
    super.initState();
    new Future.delayed(Duration.zero, () async {
      fetchBettings();
    });
  }

  fetchBettings() async {
    var response = await CallApi(context).getDataFuture('games/all');
    dynamic datas = json.decode(response.body);
    print(datas);
    matches.clear();
    setState(() {
      matches = datas;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> rendermatches = [];
    for (var data in matches) {
      rendermatches.add(
        InkWell(
          onTap: () =>
              Get.toNamed(BETTING_SYSTEM_SINGLE, arguments: data['id']),
          child: Container(
            margin: const EdgeInsets.only(
              bottom: 5,
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  Replacer().getPublicImagePath(
                    data['background_image'],
                  ),
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 25,
                    right: 25,
                    top: 10,
                    bottom: 10,
                  ),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          WhiteTitle(
                            title: data['title'],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          data['start_time_left'] > 0
                              ? Center(
                                  child: Container(
                                    width: 100,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(40),
                                      color: Colors.red,
                                    ),
                                    child: CountDownTimer(
                                      secondsRemaining: data['start_time_left'],
                                      whenTimeExpires: () {
                                        setState(() {
                                          data['start_time_left'] = 0;
                                        });
                                      },
                                      countDownTimerStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                )
                              : data['start_time_left'] == 0
                                  ? Center(
                                      child: Container(
                                        width: 100,
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
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
                                              backgroundColor: Theme.of(context)
                                                  .secondaryHeaderColor,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Theme.of(context).primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : data['start_time_left'] == -1
                                      ? Center(
                                          child: Container(
                                            width: 250,
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: Colors.green[800],
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  'MATCH COMPLETED',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : data['start_time_left'] == -2
                                          ? Center(
                                              child: Container(
                                                width: 250,
                                                padding:
                                                    const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: Colors.green[800],
                                                ),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      'NO RESULT',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : SizedBox(
                                              height: 0.01,
                                            ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  CustomNetworkImage(
                                    url: Replacer().getPublicImagePath(
                                      data['teams'][0]['details']['photo'],
                                    ),
                                    height: 80,
                                    width: 80,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    data['teams'][0]['details']['name'],
                                  ),
                                ],
                              ),
                              Text('VS'),
                              Column(
                                children: [
                                  CustomNetworkImage(
                                    url: Replacer().getPublicImagePath(
                                      data['teams'][1]['details']['photo'],
                                    ),
                                    height: 80,
                                    width: 80,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    data['teams'][1]['details']['name'],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('SwfTea Mania '),
      ),
      body: Container(
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SecondaryTitle(
                      title: 'Bet with swftea',
                    ),
                    Text(
                        'Welcome to swftea mania. Compete with your mates on your favourite teams of Sports.'),
                  ],
                ),
              ),
            ),
            ...rendermatches
          ],
        ),
      ),
    );
  }
}
