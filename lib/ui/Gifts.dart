import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:swfteaproject/constants/constants.dart';
import 'package:swfteaproject/ui/widgets/generic/dialougeBox.dart';
import 'package:swfteaproject/ui/widgets/textformfield.dart';
import 'package:swfteaproject/utlis/ApiProvider.dart';
import 'package:swfteaproject/utlis/Replacer.dart';

class Gifts extends StatefulWidget {
  @override
  _GiftsState createState() => _GiftsState();
}

class _GiftsState extends State<Gifts> {
  ScrollController scrollController = ScrollController();
  TextEditingController textBox = TextEditingController();
  List<dynamic> allGifts;
  int nextpage;
  int allpages;
  bool discount = false;
  GlobalKey _scaffoldKey;
  bool isGridView = true;
  @override
  void initState() {
    setState(() {
      allGifts = [];
      nextpage = 1;
      allpages = 1;
      _scaffoldKey = GlobalKey<ScaffoldState>();
    });
    scrollController.addListener(() {});
    super.initState();
    new Future.delayed(Duration.zero, () async {
      fetchGifts();
    });

    scrollController
      ..addListener(() {
        if (scrollController.position.pixels ==
                scrollController.position.maxScrollExtent &&
            nextpage < allpages) {
          fetchGifts();
        }
      });
  }

  fetchGifts({append: false}) async {
    var res = await CallApi(context).postData(
      {
        'search': textBox.text.trim(),
        'discount': discount,
      },
      'gifts/all?page=' + nextpage.toString(),
    );
    var data = json.decode(res.body);
    List<dynamic> newdata = data['data'].toList();
    setState(() {
      allGifts = [...allGifts, ...newdata];
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
        title: Text("All Gifts"),
        actions: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.monetization_on),
              Switch(
                onChanged: (value) {
                  setState(() {
                    discount = value;
                    allGifts = [];
                    nextpage = 1;
                    allpages = 1;
                  });
                  fetchGifts();
                },
                value: discount,
                activeColor: Theme.of(context).secondaryHeaderColor,
              ),
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
          AppTextInputField(
            hint: "Search Gifts",
            textEditingController: textBox,
            keyboardType: TextInputType.text,
            icon: Icons.business_center,
            onTextChange: (value) {
              setState(() {
                allGifts = [];
                nextpage = 1;
                allpages = 1;
              });
              fetchGifts();
            },
          ),
          Expanded(
            child: isGridView
                ? GridView.builder(
                    itemCount: allGifts.length,
                    controller: scrollController,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 150.0,
                      crossAxisSpacing: 5.0,
                      mainAxisSpacing: 5.0,
                      childAspectRatio: 0.9,
                    ),
                    itemBuilder: (context, index) => _buildGiftGrid(
                      allGifts[index],
                    ),
                  )
                : ListView.separated(
                    separatorBuilder: (context, index) {
                      return Divider(
                        color: Colors.grey,
                      );
                    },
                    itemBuilder: (context, index) => _buildGift(
                      allGifts[index],
                    ),
                    itemCount: allGifts.length,
                    controller: scrollController,
                  ),
          ),
        ],
      ),
    );
  }

  _buildGiftGrid(gift) {
    return InkWell(
      child: Container(
        padding: const EdgeInsets.all(5),
        color: gift['isPremium'] == 1
            ? Theme.of(context).primaryColor
            : Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CachedNetworkImage(
                    imageUrl: Replacer().getPublicImagePath(gift['gift_image']),
                    height: double.parse(gift['discount']) > 0.0 ? 60 : 80,
                    width: double.parse(gift['discount']) > 0.0 ? 60 : 80,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.tag_faces,
                        size: 18,
                        color: gift['isPremium'] == 1
                            ? Theme.of(context).secondaryHeaderColor
                            : Theme.of(context).primaryColor,
                      ),
                      Expanded(
                        child: Text(
                          gift['name'],
                          style: TextStyle(
                            color: gift['isPremium'] == 1
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on,
                        size: 16,
                        color: gift['isPremium'] == 1
                            ? Theme.of(context).secondaryHeaderColor
                            : Theme.of(context).primaryColor,
                      ),
                      Expanded(
                        child: double.parse(gift['discount']) > 0.0
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    gift['price'].toString(),
                                    style: TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                    ),
                                  ),
                                  Text(
                                    Replacer()
                                        .calcumatePriceWithDiscount(
                                          gift['price'],
                                          gift['discount'],
                                        )
                                        .toString(),
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                gift['price'].toString(),
                                style: TextStyle(
                                  color: gift['isPremium'] == 1
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Positioned(
              right: 0,
              child: double.parse(gift['discount']) > 0.0
                  ? Container(
                      color: Theme.of(context).secondaryHeaderColor,
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        '-' + gift['discount'] + '%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 0.1,
                    ),
            ),
            Positioned(
              left: 0,
              child: gift['isPremium'] == 1
                  ? Container(
                      color: Theme.of(context).secondaryHeaderColor,
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        'PREMIUM',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 0.1,
                    ),
            ),
          ],
        ),
      ),
      onTap: () {
        Get.toNamed(
          VIEW_IMAGE,
          arguments: {
            "images": [
              {
                "path": Replacer().getPublicImagePath(gift['gift_image']),
              }
            ],
            "type": "network",
            "focus": Replacer().getPublicImagePath(gift['gift_image']),
          },
        );
      },
      onLongPress: () {
        Clipboard.setData(new ClipboardData(text: gift['name']));
        Get.dialog(
          CustomDialog(
            title: "Success",
            child: Text(gift['name'] + " is copied to clipboard"),
          ),
        );
      },
    );
  }

  _buildGift(gift) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          CachedNetworkImage(
            imageUrl: Replacer().getPublicImagePath(gift['gift_image']),
            height: 40,
            width: 40,
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    gift['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  double.parse(gift['discount']) > 0.0
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              gift['price'].toString() + " credits",
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Theme.of(context).secondaryHeaderColor,
                              ),
                            ),
                            Text(
                              Replacer()
                                  .calcumatePriceWithDiscount(
                                    gift['price'],
                                    gift['discount'],
                                  )
                                  .toString(),
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          gift['price'].toString() + ' credits',
                        ),
                ],
              ),
            ),
          ),
          double.parse(gift['discount']) > 0.0
              ? Container(
                  color: Theme.of(context).secondaryHeaderColor,
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    '-' + gift['discount'] + '%',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                )
              : SizedBox(
                  height: 0.1,
                ),
        ],
      ),
    );
  }
}
