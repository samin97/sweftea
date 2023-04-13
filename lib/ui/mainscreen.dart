import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:swfteaproject/constants/GlobalWidgets.dart';
import 'package:swfteaproject/providers/SwfTeaController.dart';
import 'package:swfteaproject/providers/UserProvider.dart';
import 'package:swfteaproject/ui/widgets/customTabView.dart';
import 'package:swfteaproject/ui/widgets/generic/drawer.dart';
import 'package:swfteaproject/ui/widgets/generic/rippleanimation.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Theme.of(context).primaryColor,
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Theme.of(context).primaryColor, // Note RED here
      ),
    );

    Future<bool> _onWillPop() async {
      return (await showDialog(
            context: context,
            builder: (context) => new AlertDialog(
              title: new Text('Are you sure?'),
              content: new Text('Do you want to exit SwfTea'),
              actions: <Widget>[
                new ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: new Text('No'),
                ),
                new ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: new Text('Yes'),
                ),
              ],
            ),
          )) ??
          false;
    }

    UserProvider userProvider = Provider.of<UserProvider>(context);
    GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

    return WillPopScope(
      onWillPop: () => _onWillPop(),
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          key: _scaffoldKey,
          drawer: MainDrawer(skey: _scaffoldKey),
          drawerEnableOpenDragGesture: true,
          body: GetBuilder<Controller>(
            init: Controller(user: userProvider.user),
            builder: (_) => CustomTabView(() {
              _scaffoldKey.currentState.openDrawer();
            }),
          ),
        ),
      ),
    );
  }
}

class GlobalAudio extends StatefulWidget {
  var audioPlayer = GlobalObject.audioPlayer;
  @override
  _GlobalAudioState createState() => _GlobalAudioState();
}

class _GlobalAudioState extends State<GlobalAudio>
    with SingleTickerProviderStateMixin {
  bool isPlaying = false;
  LocalStorage storage = new LocalStorage('swftea_app');

  String audioUrl = "http://stream.zeno.fm/zbnt8btkbd0uv";
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.audioPlayer.state == AudioPlayerState.PLAYING) {
      setState(() {
        isPlaying = true;
      });
    } else {
      setState(() {
        isPlaying = false;
      });
    }
    return FutureBuilder(
      future: storage.ready,
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          if (storage.getItem('radio_animation_show') ?? true && !isPlaying) {
            return RipplesAnimation(
              color: Colors.green,
              onPressed: () {
                storage.setItem('radio_animation_show', false);
                widget.audioPlayer.stop();
                setState(() {
                  isPlaying = false;
                });
              },
              child: Icon(
                Icons.wifi_tethering,
                color: Colors.white,
              ),
            );
          } else {
            return isPlaying
                ? RipplesAnimation(
                    color: Colors.green,
                    onPressed: () {
                      widget.audioPlayer.stop();
                      setState(() {
                        isPlaying = false;
                      });
                    },
                    child: Icon(
                      Icons.wifi_tethering,
                      color: Colors.white,
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      Icons.volume_off,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      if (true) {
                        widget.audioPlayer.play(audioUrl);
                        setState(() {
                          isPlaying = true;
                        });
                      }
                    });
          }
        } else {
          return Text("L");
        }
      },
    );
  }
}
