// ignore_for_file: unused_import, non_constant_identifier_names, avoid_print, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:library_management/utils/appConstants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseMethods {
  Future addUserInfoToDBGoogle(
      String? userid, Map<String, dynamic> UserInfoMapGoogle) async {
    return await FirebaseFirestore.instance
        .collection(ALLUSERS)
        .doc(userid)
        .set(UserInfoMapGoogle);
  }

  Future addUserInfoToDB(
      String? userid, Map<String, dynamic> UserInfoMap) async {
    return await FirebaseFirestore.instance
        .collection(ALLUSERS)
        .doc(UserInfoMap['name'])
        .set(UserInfoMap);
  }

  getUserInfo(String email) async {
    return FirebaseFirestore.instance
        .collection(ALLUSERS)
        .where("userEmail", isEqualTo: email)
        .get()
        .catchError((e) {
    });
  }

  Stream<QuerySnapshot> getUsers() {
    return FirebaseFirestore.instance.collection(ALLUSERS).snapshots();
  }

  Future addMessage(String chatRoomId, String messageId,
      Map<String, dynamic> messageInfoMap) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .doc(messageId)
        .set(messageInfoMap);
  }

  updateLastMessageSend(
      String chatRoomId, Map<String, dynamic> lastMessageInfoMap) {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .update(lastMessageInfoMap);
  }

  createChatRoom(
      String chatRoomId, Map<String, dynamic> chatRoomInfoMap) async {
    final snapShot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .get();

    if (snapShot.exists) {
      // chatroom already exists
      return true;
    } else {
      // chatroom does not exists
      return FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomId)
          .set(chatRoomInfoMap);
    }
  }

  addchatHolderstochatrooms(
      String chatRoomId, Map<String, dynamic> chatHolderInfoMap) async {
    final snapShot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("ChatHolders")
        .doc()
        .get();

    if (snapShot.exists) {
      // Holders already exists
      return true;
    } else {
      // Holders does not exists
      return FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomId)
          .collection("ChatHolders")
          .doc()
          .set(chatHolderInfoMap);
    }
  }

  Stream<QuerySnapshot> getChatRoomMessages(chatRoomId) {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("ts", descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getChatRooms() {
    return FirebaseFirestore.instance.collection("chatrooms").snapshots();
  }

  Stream<QuerySnapshot> getUserByUserName(String username) {
    return FirebaseFirestore.instance
        .collection(ALLUSERS)
        .where("username", isEqualTo: username)
        .snapshots();
  }

  getUserOtherInfo(String username) async {
    return await FirebaseFirestore.instance
        .collection(ALLUSERS)
        .where("username", isEqualTo: username)
        .get()
        .catchError((e) {
    });
  }
}
