import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swfteaproject/constants/constants.dart';
import 'package:swfteaproject/ui/widgets/generic/nicebuttom.dart';
import 'package:swfteaproject/ui/widgets/generic/rippleanimation.dart';
import 'package:swfteaproject/utlis/ApiProvider.dart';
import 'package:swfteaproject/utlis/Replacer.dart';
import 'package:video_player/video_player.dart';

class MissionInit extends StatefulWidget {
  @override
  _MissionInitState createState() => _MissionInitState();
}

class _MissionInitState extends State<MissionInit> {
  dynamic seasons = [];
  VideoPlayerController _controller;
  bool _visible = false;
  @override
  void initState() {
    // _controller = VideoPlayerController.asset('assets/videos/missionbg1.mp4');
    // _controller.initialize().then((_) {
    //   _controller.setLooping(true);
    //   Timer(Duration(milliseconds: 100), () {
    //     setState(() {
    //       _controller.play();
    //       _visible = true;
    //     });
    //   });
    // });

    new Future.delayed(Duration.zero, () async {
      var res = await CallApi(context).getDataFuture("swfteamission");
      dynamic ses = json.decode(res.body);
      setState(() {
        seasons = ses;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    // if (_controller != null) {
    //   _controller.dispose();
    //   _controller = null;
    // }
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  setLandscapeOrientation() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation != null) {
      setLandscapeOrientation();
    }
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _getBackgroundColor(),
            Positioned(
              bottom: 0,
              right: 0,
              child: this.seasons.length > 0
                  ? MissionTile(
                      season: this.seasons[0],
                    )
                  : NiceButton(
                      child: MissionText(
                        text: "LOADING...",
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  _getBackgroundColor() {
    return CachedNetworkImage(
      imageUrl: Replacer().getPublicImagePath(this.seasons.length > 0
          ? this.seasons[0]['banner']
          : 'storage/images/ffae944ba2679616678de647cea56e40.png'),
      fit: BoxFit.cover,
      width: double.infinity,
    );
  }
}

class MissionTile extends StatefulWidget {
  MissionTile({this.season});
  final dynamic season;
  @override
  _MissionTileState createState() => _MissionTileState();
}

class _MissionTileState extends State<MissionTile> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        widget.season['is_active']
            ? widget.season['is_already_in']
                ? GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, MISSION_HOME,
                          arguments: widget.season['id']);
                    },
                    child: Image.asset(
                      'assets/images/icons/start.png',
                      height: 40,
                      width: 120,
                    ),
                  )
                : NiceButton(
                    radius: 0,
                    onPressed: () async {
                      var res = await CallApi(context).getDataFuture(
                        "swfteamission/join/" + widget.season['id'].toString(),
                      );
                      dynamic data = json.decode(res.body);
                      if (data['error']) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(data["message"]),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(data["message"]),
                          ),
                        );
                      }
                      Navigator.pushReplacementNamed(context, MISSION_HOME,
                          arguments: widget.season['id']);
                    },
                    child: MissionText(
                      text: "JOIN",
                    ),
                  )
            : NiceButton(
                radius: 0,
                child: MissionText(
                  text: "MISSION COMPLETED",
                ),
              )
      ],
    );
  }
}
