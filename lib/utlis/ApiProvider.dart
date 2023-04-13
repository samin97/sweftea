import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:swfteaproject/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:swfteaproject/providers/UserProvider.dart';
import 'package:swfteaproject/ui/widgets/generic/dialougeBox.dart';

class CallApi {
  CallApi(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    if (userProvider.getUser() == null) {
      this.token = '';
    } else {
      this.token = userProvider.getUser().token;
    }
  }
  String token;
  postData(data, apiUrl) async {
    var fullUrl = BASE_URL + apiUrl;
    print(fullUrl);
    return await http.post(fullUrl,
        body: jsonEncode(data), headers: _setHeaders(this.token));
  }

  postDataFuture(data, apiUrl) async {
    var fullUrl = BASE_URL + apiUrl;
    Get.dialog(LoadingDialog());
    var res = await http.post(fullUrl,
        body: jsonEncode(data), headers: _setHeaders(this.token));
    Get.back();
    return res;
  }

  getDataFuture(apiUrl) async {
    var fullUrl = BASE_URL + apiUrl;
    Get.dialog(LoadingDialog());
    var data = await http.get(fullUrl, headers: _setHeaders(this.token));
    Get.back();
    return data;
  }

  getData(apiUrl) async {
    var fullUrl = BASE_URL + apiUrl;
    return await http.get(fullUrl, headers: _setHeaders(this.token));
  }

  _setHeaders(token) => {
        "Content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + token
      };
}
