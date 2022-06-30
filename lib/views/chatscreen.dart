import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/transition.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

import '../helperfunction/sharedpref_helper.dart';

class ChatScreen extends StatefulWidget {
  final String chatWithUsername, name;
  ChatScreen(this.chatWithUsername, this.name);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late String chatRoomId, messageId = "";
  late String myName, myProfilePic, myEmail;
  String myUserName = "Manthan";

  TextEditingController messageTextEditingController = TextEditingController();

  getMyInfoFromSharedPreference() async {
    myName = (await SharedPreferenceHelper().getDisplayName());

    myProfilePic = (await SharedPreferenceHelper().getUserProfileUrl());
    myUserName = (await SharedPreferenceHelper().getUserName());
    print(myUserName);
    myEmail = (await SharedPreferenceHelper().getUserEmail());

    chatRoomId =
        await getChatRoomIdByUsernames(widget.chatWithUsername, myUserName);
  }

  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_b";
    }
  }

  addMessage(bool sendClicked) {
    if (messageTextEditingController.text != "") {
      String message = messageTextEditingController.text;
      var lastMessageTs = DateTime.now();
      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": myUserName,
        "ts": lastMessageTs,
        "imgUrl": myProfilePic
      };
      if (messageId == "") {
        messageId = randomAlphaNumeric(12);
      }

      DatabaseMethods()
          .addMessage(chatRoomId, messageId, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendTs": lastMessageTs,
          "lastMessageSendBy": myUserName
        };
        DatabaseMethods().updateLastMessageSend(chatRoomId, lastMessageInfoMap);

        if (sendClicked) {
          messageTextEditingController.text = "";
          messageId = "";
        }
      });
    }
  }

  getAndSetMessages() async {}
  doThisOnLaunch() async {
    await getMyInfoFromSharedPreference();
    //   getAndSetMessages();
  }

  @override
  void initState() {
    doThisOnLaunch();
    print(myUserName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return myUserName != "Manthan"
        ? Container()
        : Scaffold(
            appBar: AppBar(title: Text(widget.name)),
            // ignore: unnecessary_null_comparison
            body: Container(
              child: Stack(
                children: [
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 0, 5, 10),
                      color: Colors.black.withOpacity(0.8),
                      child: Row(
                        children: [
                          Expanded(
                              child: TextField(
                            controller: messageTextEditingController,
                            onChanged: (value) {
                              addMessage(false);
                            },
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Message",
                                hintStyle: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white.withOpacity(0.7))),
                          )),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: GestureDetector(
                              onTap: () {
                                addMessage(true);
                              },
                              child: const Icon(
                                Icons.send_rounded,
                                size: 45,
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));
  }
}

// @override
// Widget build(BuildContext context) {
//   return TextField();
// }
