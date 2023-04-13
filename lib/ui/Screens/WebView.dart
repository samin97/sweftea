import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewApp extends StatelessWidget {
  String url;
  String title = "";
  WebviewApp(this.url, this.title);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.title),
      ),
      body: Builder(builder: (BuildContext context) {
        return WebView(initialUrl: this.url);
      }),
    );
  }
}
