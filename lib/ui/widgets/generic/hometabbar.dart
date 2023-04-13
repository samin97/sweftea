import 'package:flutter/material.dart';
import 'package:swfteaproject/model/AppTab.dart';
import 'package:swfteaproject/utlis/Replacer.dart';

class HomeTabBar extends StatelessWidget {
  HomeTabBar(this.appTab, this.activeTab, this.index);
  final int index;
  final int activeTab;
  final AppTab appTab;
  @override
  Widget build(BuildContext context) {
    if (true) {
      return Tab(
        text: appTab.label,
      );
    } else {
      return Tab(
        icon: Replacer().getHomeTabIcon(appTab.type),
      );
    }
  }
}
