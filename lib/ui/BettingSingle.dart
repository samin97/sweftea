import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slide_countdown_clock/slide_countdown_clock.dart';
import 'package:swfteaproject/ui/widgets/generic/dialougeBox.dart';
import 'package:swfteaproject/ui/widgets/generic/nicebuttom.dart';
import 'package:swfteaproject/ui/widgets/textformfield.dart';
import 'package:swfteaproject/utlis/ApiProvider.dart';
import 'package:swfteaproject/utlis/Replacer.dart';

class BettingSingle extends StatefulWidget {
  @override
  _BettingSingleState createState() => _BettingSingleState();
}

class _BettingSingleState extends State<BettingSingle> {
  int matchid;
  TextEditingController teamAtextEditingController = TextEditingController();
  TextEditingController teamBtextEditingController = TextEditingController();
  dynamic matchdetails = {
    'title': '',
    'description': '',
    'background_image': 'public/images/khukuri_64.png',
    'banner': 'public/images/khukuri_64.png',
    'start_time_left': 0,
    'winner_id': 0,
    'total_bet_amount': 0,
    'total_bets': 0,
    'bets_participants': [],
    'winner': {
      'total_bet_amount': 0,
      'bets_count': 0,
      'details': {'name': ''},
    }
  };
  @override
  void initState() {
    super.initState();
    new Future.delayed(Duration.zero, () async {
      setState(() {
        matchid = Get.arguments;
      });
      fetchBetting(matchid);
    });
  }

  fetchBetting(int id) async {
    var response =
        await CallApi(context).getDataFuture('games/' + id.toString());
    dynamic data = json.decode(response.body);
    print(data['bets']);
    setState(() {
      matchdetails = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220.0,
            floating: true,
            pinned: true,
            snap: true,
            elevation: 50,
            backgroundColor: Theme.of(context).primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              title: Text(
                matchdetails['title'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
              background: Image.network(
                Replacer().getPublicImagePath(matchdetails['banner']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          new SliverList(
            delegate: new SliverChildListDelegate(
              _buildMatch(),
            ),
          ),
        ],
      ),
    );
  }

  _buildMatch() {
    getWinningRate(name) {
      if (name == matchdetails['teams'][0]['details']['name']) {
        return matchdetails['teams'][0]['winning_rate'];
      } else {
        return matchdetails['teams'][1]['winning_rate'];
      }
    }

    List<Widget> items = [];
    List<Widget> bettingusers = [];
    List<Widget> mybets = [];

    if (matchdetails['title'] == '') {
      mybets.add(
        Text("Loading..."),
      );
      return mybets;
    }
    for (var bet in matchdetails['my_bets']) {
      mybets.add(
        Container(
          color: matchdetails['winner_id'] == 0
              ? Colors.transparent
              : bet['team']['details']['name'] ==
                      matchdetails['winner']['details']['name']
                  ? Colors.green
                  : Colors.red,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 5,
              left: 5,
              right: 5,
              bottom: 5,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(bet['team']['details']['name']),
                Text(
                  "B: " +
                      bet['amount'].toString() +
                      " | R: " +
                      getWinningRate(bet['team']['details']['name'])
                          .toString() +
                      "X | E.A: " +
                      (getWinningRate(bet['team']['details']['name']) *
                              double.parse(bet['amount']))
                          .toString(),
                ),
              ],
            ),
          ),
        ),
      );
    }
    for (var bet in matchdetails['bets_participants']) {
      bettingusers.add(
        Padding(
          padding: const EdgeInsets.only(
            right: 5,
            top: 5,
          ),
          child: Text(bet + ','),
        ),
      );
    }
    // Still time left
    if (matchdetails['start_time_left'] > 0) {
      items.add(
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SecondaryTitle(
                  title: 'Betting starts in',
                ),
                Center(
                  child: SlideCountdownClock(
                    duration: Duration(
                      seconds: matchdetails['start_time_left'],
                    ),
                    separatorTextStyle: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                      fontWeight: FontWeight.bold,
                    ),
                    separator: ":",
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    onDone: () {
                      setState(() {
                        matchdetails['start_time_left'] = 0;
                      });
                    },
                    shouldShowDays: false,
                    textStyle: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    // match is LIVE
    if (matchdetails['start_time_left'] == 0) {
      items.add(
        Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 100,
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
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(matchdetails['description']),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      items.add(
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                Replacer().getPublicImagePath(
                  matchdetails['background_image'],
                ),
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            CustomNetworkImage(
                              url: Replacer().getPublicImagePath(
                                matchdetails['teams'][0]['details']['photo'],
                              ),
                              height: 60,
                              width: 60,
                            ),
                            SizedBox(height: 10),
                            Text(
                              matchdetails['teams'][0]['details']['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 5),
                            SecondaryTitle(
                              title: matchdetails['teams'][0]['bets_count']
                                      .toString() +
                                  ' bets',
                            ),
                            NiceButton(
                              bgColor: Theme.of(context).primaryColor,
                              textColor: Colors.white,
                              onPressed: () {
                                Get.dialog(
                                  CustomDialog(
                                    title: matchdetails['teams'][0]['details']
                                        ['name'],
                                    child: Flexible(
                                      child: ListView(
                                        children: [
                                          SecondaryTitle(
                                            title: "Amount",
                                          ),
                                          AppTextInputField(
                                            hint: "Enter bid amount..",
                                            elevation: false,
                                            keyboardType: TextInputType.number,
                                            icon: Icons.attach_money,
                                            textEditingController:
                                                teamAtextEditingController,
                                          ),
                                        ],
                                      ),
                                    ),
                                    buttonText: "Bid now",
                                    onSubmit: () async {
                                      var res =
                                          await CallApi(context).postDataFuture(
                                        {
                                          'team_id': matchdetails['teams'][0]
                                              ['id'],
                                          'amount':
                                              teamAtextEditingController.text
                                        },
                                        'games/' +
                                            matchid.toString() +
                                            '/bidnow',
                                      );
                                      dynamic data = json.decode(res.body);
                                      if (data['error'] ?? true) {
                                        Get.dialog(
                                          CustomDialog(
                                            title: "Error",
                                            child: Text(
                                              data['message'],
                                            ),
                                          ),
                                        );
                                      } else {
                                        Get.dialog(
                                          CustomDialog(
                                            title: "Success",
                                            child: Text(
                                              data['message'],
                                            ),
                                            onSubmit: () {
                                              fetchBetting(matchid);
                                            },
                                            buttonText: "Refresh",
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                              child: Text('BET (X' +
                                  matchdetails['teams'][0]['winning_rate']
                                      .toString() +
                                  ')'),
                            ),
                          ],
                        ),
                        Text(
                          'VS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Column(
                          children: [
                            CustomNetworkImage(
                              url: Replacer().getPublicImagePath(
                                matchdetails['teams'][1]['details']['photo'],
                              ),
                              height: 60,
                              width: 60,
                            ),
                            SizedBox(height: 10),
                            Text(
                              matchdetails['teams'][1]['details']['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 5),
                            SecondaryTitle(
                              title: matchdetails['teams'][1]['bets_count']
                                      .toString() +
                                  ' bets',
                            ),
                            NiceButton(
                              bgColor: Theme.of(context).primaryColor,
                              textColor: Colors.white,
                              onPressed: () {
                                Get.dialog(
                                  CustomDialog(
                                    title: matchdetails['teams'][1]['details']
                                        ['name'],
                                    child: Flexible(
                                      child: ListView(
                                        children: [
                                          SecondaryTitle(
                                            title: "Amount",
                                          ),
                                          AppTextInputField(
                                            hint: "Enter bid amount..",
                                            elevation: false,
                                            keyboardType: TextInputType.number,
                                            icon: Icons.attach_money,
                                            textEditingController:
                                                teamBtextEditingController,
                                          ),
                                        ],
                                      ),
                                    ),
                                    buttonText: "Bid now",
                                    onSubmit: () async {
                                      var res =
                                          await CallApi(context).postDataFuture(
                                        {
                                          'team_id': matchdetails['teams'][1]
                                              ['id'],
                                          'amount':
                                              teamBtextEditingController.text
                                        },
                                        'games/' +
                                            matchid.toString() +
                                            '/bidnow',
                                      );
                                      dynamic data = json.decode(res.body);
                                      if (data['error'] ?? true) {
                                        Get.dialog(
                                          CustomDialog(
                                            title: "Error",
                                            child: Text(
                                              data['message'],
                                            ),
                                          ),
                                        );
                                      } else {
                                        Get.dialog(
                                          CustomDialog(
                                            title: "Success",
                                            child: Text(
                                              data['message'],
                                            ),
                                            onSubmit: () {
                                              fetchBetting(matchid);
                                            },
                                            buttonText: "Refresh",
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                              child: Text('BET (X' +
                                  matchdetails['teams'][1]['winning_rate']
                                      .toString() +
                                  ')'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: Colors.white54,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SecondaryTitle(
                                title: "Betting ends in",
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              SlideCountdownClock(
                                duration: Duration(
                                  seconds: matchdetails['end_time_left'],
                                ),
                                separatorTextStyle: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                padding: EdgeInsets.all(10),
                                shouldShowDays: false,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.rectangle,
                                ),
                                onDone: () {
                                  setState(() {
                                    matchdetails['start_time_left'] = -1;
                                  });
                                },
                                textStyle: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      color: Colors.white54,
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SecondaryTitle(
                            title: "My bets",
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ...mybets,
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      color: Colors.white54,
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SecondaryTitle(
                              title: "Participants (" +
                                  bettingusers.length.toString() +
                                  ")"),
                          Wrap(
                            children: [
                              ...bettingusers,
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    // Match is over
    if (matchdetails['winner_id'] == 0) {
      if (matchdetails['start_time_left'] < 0) {
        items.add(
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SecondaryTitle(
                    title: "Match completed!!",
                  ),
                  Text(matchdetails['winner_note']),
                ],
              ),
            ),
          ),
        );
      }
    } else {
      if (matchdetails['start_time_left'] < 0) {
        items.add(
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(matchdetails['winner_note']),
                  SizedBox(
                    height: 20,
                  ),
                  SecondaryTitle(
                    title: "Total bets",
                  ),
                  Text(matchdetails['total_bets'].toString()),
                  SizedBox(
                    height: 10,
                  ),
                  SecondaryTitle(
                    title: "Amount waggred",
                  ),
                  Text(
                      matchdetails['total_bet_amount'].toString() + ' credits'),
                  SizedBox(
                    height: 10,
                  ),
                  SecondaryTitle(
                    title: "Winner",
                  ),
                  Text(matchdetails['winner']['details']['name']),
                  SizedBox(
                    height: 10,
                  ),
                  SecondaryTitle(
                    title: "Winning rate",
                  ),
                  Text(matchdetails['winner']['winning_rate'].toString() +
                      ' (' +
                      matchdetails['winner']['bets_count'].toString() +
                      ')'),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    color: Colors.white54,
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SecondaryTitle(
                          title: "My bets",
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ...mybets,
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }
    }

    return items;
  }
}
