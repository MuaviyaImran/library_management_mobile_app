import 'package:flutter/cupertino.dart';

class userDataProvider with ChangeNotifier {
  Map<dynamic, dynamic> loggedInUserData = {};

  saveUser(data) {
    loggedInUserData.clear();
    loggedInUserData = data;
    print(loggedInUserData);
    notifyListeners();
  }
}
