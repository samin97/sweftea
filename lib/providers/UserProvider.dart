import 'package:flutter/cupertino.dart';
import 'package:swfteaproject/model/User.dart';

class UserProvider with ChangeNotifier {
  User user;
  void setUser(User user) {
    this.user = user;
    notifyListeners();
  }

  User getUser() {
    return this.user;
  }
}
