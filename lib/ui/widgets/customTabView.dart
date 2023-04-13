import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swfteaproject/providers/SwfTeaController.dart';
import 'package:swfteaproject/utlis/Replacer.dart';

class CustomTabView extends StatelessWidget {
  final Controller controller = Get.find();
  final Function drawerControl;
  CustomTabView(this.drawerControl);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AppTabBar(this.drawerControl),
        Expanded(
          child: PageView.builder(
            controller: controller.tabController,
            itemBuilder: (context, position) {
              return Replacer().getTabContent(controller.tabs[position]);
            },
            allowImplicitScrolling: false,
            onPageChanged: (value) {
              controller.focusTab(value);

              FocusScope.of(context).unfocus();
            },
            itemCount: controller.tabs.length,
          ),
        ),
      ],
    );
  }
}
