import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
// import 'package:image_picker_saver/image_picker_saver.dart';
import 'package:swfteaproject/providers/SwfTeaController.dart';

class ViewImage extends StatefulWidget {
  final Controller controller = Get.find();
  final dynamic arguments = Get.arguments;
  @override
  _ViewImageState createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  int currentIndex = 0;
  int downloadprogress = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _actions = [];
    if (currentIndex >= 0) {
      if ((widget.arguments['type'] ?? 'network') == 'network') {
        _actions.add(IconButton(
          icon: Icon(Icons.cloud_download),
          onPressed: () async {
            _saveNetworkImage(widget.arguments['images'][currentIndex]['path']);
          },
        ));
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo View'),
        actions: _actions,
      ),
      body: PageView.builder(
        itemBuilder: (context, index) {
          return widget.arguments['type'] == 'asset'
              ? getLocalImage(widget.arguments['images'][index])
              : getNetworkImage(widget.arguments['images'][index]['path']);
        },
        itemCount: widget.arguments["images"].length,
        onPageChanged: (value) {
          setState(() {
            currentIndex = value;
          });
        },
      ),
    );
  }

  void _saveNetworkImage(String url) async {
    Fluttertoast.showToast(
      msg: "Saving",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    // GallerySaver.saveImage(url, albumName: "Swftea").then((bool success) {
    //   if (success) {
    //     Fluttertoast.showToast(
    //       msg: "Image Saved",
    //       toastLength: Toast.LENGTH_SHORT,
    //       gravity: ToastGravity.BOTTOM,
    //       timeInSecForIosWeb: 1,
    //       backgroundColor: Colors.black,
    //       textColor: Colors.white,
    //       fontSize: 16.0,
    //     );
    //   } else {
    //     Fluttertoast.showToast(
    //       msg: "Error on Image Saving",
    //       toastLength: Toast.LENGTH_SHORT,
    //       gravity: ToastGravity.BOTTOM,
    //       timeInSecForIosWeb: 1,
    //       backgroundColor: Colors.red[900],
    //       textColor: Colors.white,
    //       fontSize: 16.0,
    //     );
    //   }
    // });
  }

  Widget getNetworkImage(url) {
    return InteractiveViewer(
      panEnabled: false, // Set it to false to prevent panning.
      boundaryMargin: EdgeInsets.all(80),
      minScale: 0.5,
      maxScale: 4,
      // child: Image.network(url),
      child: CachedNetworkImage(
        imageUrl: url,
        placeholder: (context, url) => new CircularProgressIndicator(),
        errorWidget: (context, url, error) => new Icon(Icons.error),
      ),
    );
  }

  Widget getLocalImage(String url) {
    return InteractiveViewer(
      panEnabled: false, // Set it to false to prevent panning.
      boundaryMargin: EdgeInsets.all(80),
      minScale: 0.5,
      maxScale: 4,
      child: Image.file(
        File(url),
      ),
    );
  }
}
