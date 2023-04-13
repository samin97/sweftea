import 'package:avataaar_image/avataaar_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserAvatar extends StatefulWidget {
  UserAvatar({
    @required this.jsonAvatar,
  });
  final dynamic jsonAvatar;
  @override
  _UserAvatarState createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  Avataaar _avatar;
  @override
  void initState() {
    super.initState();
    _initAvatar();
  }

  void _initAvatar() => _avatar = Avataaar.fromJson(widget.jsonAvatar);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: AvataaarImage.builder(
        avatar: _avatar,
        key: Key("AVATAR"),
        builder: (context, url) {
          var newurl = 'https://avataaars.io?' +
              url.split("https://avataaars.io/png/128.0?")[1];
          return Container(
            child: SvgPicture.network(
              newurl,
              width: 128,
              height: 128,
            ),
          );
        },
        width: 128.0,
      ),
    );
  }
}
