import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swfteaproject/constants/constants.dart';
import 'package:swfteaproject/providers/SwfTeaController.dart';

class Explorer extends StatefulWidget {
  final Controller controller = Get.find();
  @override
  _ExplorerState createState() => _ExplorerState();
}

class _ExplorerState extends State<Explorer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Explorer"),
      ),
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            ListTile(
              leading: Icon(
                Icons.public,
                color: Theme.of(context).primaryColor,
              ),
              title: Text("Announcements"),
              onTap: () {
                Get.toNamed(ANNOUNCEMENT_SCREEN);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.card_giftcard,
                color: Theme.of(context).primaryColor,
              ),
              title: Text("Gift store"),
              onTap: () {
                Get.toNamed(GIFTS_SCREEN);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.games,
                color: Theme.of(context).primaryColor,
              ),
              title: Text("Swftea contests"),
              onTap: () {
                Get.toNamed(CONTEST_PAGE);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.poll,
                color: Theme.of(context).primaryColor,
              ),
              title: Text("Leaderboards"),
              onTap: () {
                Get.toNamed(LEADERBOARDS_SCREEN);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.group,
                color: Theme.of(context).primaryColor,
              ),
              title: Text("People"),
              onTap: () {
                Get.toNamed(PEOPLE_LIST_SCREEN);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.account_balance,
                color: Theme.of(context).primaryColor,
              ),
              title: Text("Mentor arena"),
              onTap: () {
                Get.toNamed(MENTOR_PANEL);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.local_convenience_store,
                color: Theme.of(context).primaryColor,
              ),
              title: Text("Merchant arena"),
              onTap: () {
                Get.toNamed(MERCHANT_PANEL);
              },
            ),
          ],
        ).toList(),
      ),
    );
  }
}
