// ignore_for_file: non_constant_identifier_names, file_names, unused_local_variable

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static String uid = "UID";
  static String userNameKey = "USERNAMEKEY";
  static String phoneKey = "USERPHONE";
  static String userEmailKey = "USEREMAILKEY";
  static String typeKey = "TYPE";
  static String profilePic = "PROFILEPIC";
  static String Books_Issued = "Books_Issued";
  static String fine_ammount = "FINE";

  //save data
  Future<bool> saveUserName(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userNameKey, userName);
  }

  Future<bool> saveUserEmail(String getUseremail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userEmailKey, getUseremail);
  }

  Future<bool> saveUId(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(uid, id);
  }

  Future<bool> savePhone(String phone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(phoneKey, phone);
  }

  Future<bool> saveBooksIssued(int booksIssued) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(Books_Issued, booksIssued);
  }

  Future<bool> saveFine(int fine) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(fine_ammount, fine);
  }

  Future<bool> savePic(String pic) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(profilePic, pic);
  }

  Future<bool> saveType(String type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(typeKey, type);
  }

  //get data
  Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var UserName = prefs.getString(userNameKey);
    return prefs.getString(userNameKey);
  }

  Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  Future<String?> getUId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(uid);
  }

  Future<String?> getPhone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(phoneKey);
  }

  Future<String?> getType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(typeKey);
  }

  Future<SharedPreferences> deleteData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs..clear();
  }
}
