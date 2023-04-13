import 'package:flutter/material.dart';

class InfiniteListView extends StatefulWidget {
  final builder;
  final apiUrl;
  InfiniteListView({@required this.builder, @required this.apiUrl});
  @override
  _InfiniteListViewState createState() => _InfiniteListViewState();
}

class _InfiniteListViewState extends State<InfiniteListView> {
  _InfiniteListViewState({this.apiUrl, this.builder});
  var apiUrl;
  var builder;
  ScrollController scrollController = ScrollController();
  List<dynamic> allData;
  int currentpage;
  int lastpage;
  @override
  void initState() {
    setState(() {
      currentpage = 1;
      lastpage = 1;
      allData = [];
    });
    super.initState();
    new Future.delayed(Duration.zero, () async {
      fetchData();
    });
  }

  fetchData() async {}

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
