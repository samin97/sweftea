import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:swfteaproject/utlis/Replacer.dart';

class Contest extends StatefulWidget {
  dynamic data = Get.arguments;
  @override
  _ContestState createState() => _ContestState();
}

class _ContestState extends State<Contest> with SingleTickerProviderStateMixin {
  TabController _tabController;
  PageController _slidercontroller = PageController();
  Timer _timer;
  @override
  void initState() {
    super.initState();
    setState(() {
      _tabController = new TabController(
        vsync: this,
        length: 2,
        initialIndex: 0,
      );
    });

    setState(() {
      _timer = new Timer.periodic(Duration(seconds: 5), (timer) {
        int page;
        if (_slidercontroller.page.round() ==
            widget.data['banners'].length - 1) {
          page = 0;
        } else {
          page = _slidercontroller.page.round() + 1;
        }
        _slidercontroller.animateToPage(
          page,
          curve: Curves.easeIn,
          duration: Duration(
            milliseconds: 500,
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_tabController != null) {
      _tabController.dispose();
    }
    if (_slidercontroller != null) {
      _slidercontroller.dispose();
    }
    if (_timer != null) {
      _timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _imagebanners = [];
    for (var banner in widget.data['banners']) {
      _imagebanners.add(
        CachedNetworkImage(
          imageUrl: Replacer().getPublicImagePath(banner),
          fit: BoxFit.contain,
        ),
      );
    }
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400.0,
            floating: true,
            elevation: 50,
            backgroundColor: Theme.of(context).primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  widget.data['title'],
                  overflow: TextOverflow.clip,
                ),
              ),
              background: Stack(
                children: [
                  PageView(
                    controller: _slidercontroller,
                    children: _imagebanners,
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 380,
                    child: SizedBox(
                      height: 40,
                      child: Center(
                        child: SmoothPageIndicator(
                          controller: _slidercontroller,
                          count: _imagebanners.length,
                          effect: WormEffect(
                              dotColor: Theme.of(context).secondaryHeaderColor,
                              activeDotColor: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          new SliverList(
            delegate: new SliverChildListDelegate(
              _buildData(),
            ),
          ),
        ],
      ),
    );
  }

  _buildData() {
    List<Widget> _items = [];
    _items.add(
      Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PrimaryTitle(
                title: "Description",
              ),
              Divider(),
              Text(widget.data['description']),
            ],
          ),
        ),
      ),
    );
    List<Widget> _terms = [];
    for (var term in widget.data['terms']) {
      _terms.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Text(term['text']),
        ),
      );
    }

    _items.add(
      Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PrimaryTitle(
                title: 'TOC',
              ),
              Divider(),
              ..._terms
            ],
          ),
        ),
      ),
    );

    return _items;
  }
}
