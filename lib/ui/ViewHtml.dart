import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:get/get.dart';
import 'package:swfteaproject/constants/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewHtml extends StatefulWidget {
  @override
  _ViewHtmlState createState() => _ViewHtmlState();
}

class _ViewHtmlState extends State<ViewHtml> {
  String title = '';
  String html = 'Loading';
  dynamic arguments = Get.arguments;
  @override
  void initState() {
    super.initState();
    new Future.delayed(Duration.zero, () async {
      setState(() {
        title = arguments['title'];
        html = arguments['html'];
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail page"),
      ),
      body: SingleChildScrollView(
        child: Html(
          data: "<div>" + html + "</div>",
          style: {
            "strong": Style(fontWeight: FontWeight.bold),
            "b": Style(fontWeight: FontWeight.bold),
            "ul": Style(
              margin: const EdgeInsets.only(
                left: 15,
              ),
            ),
            "ol": Style(
              margin: const EdgeInsets.only(
                left: 15,
              ),
            ),
            "li": Style(
              padding: const EdgeInsets.only(
                left: 15,
              ),
            ),
            "h5": Style(
              fontSize: FontSize.large,
            ),
            "p": Style(
              fontSize: FontSize.medium,
            ),
            "div": Style(
              fontSize: FontSize.medium,
            ),
          },
          onLinkTap: (url) async {
            RegExp regExp = new RegExp('/^http:\/\/\@/');
            RegExp regExp1 = new RegExp('/^https:\/\/\@/');
            if (regExp.hasMatch(url)) {
              var username = url.split("http://@")[1];
              Get.toNamed(PROFILE_SCREEN, arguments: {"id": username});
            } else if (regExp1.hasMatch(url)) {
              var username = url.split("https://@")[1];
              Get.toNamed(PROFILE_SCREEN, arguments: {"id": username});
            } else {
              if (await canLaunch(url)) {
                await launch(url);
              } else {}
            }
          },
        ),
      ),
    );
  }
}
