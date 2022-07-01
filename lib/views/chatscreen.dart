// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_print, unnecessary_string_escapes

import 'package:chat_app/constants/constants.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/transition.dart';
import 'package:chat_app/widgets/message_blob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

import '../helperfunction/sharedpref_helper.dart';

class ChatScreen extends StatefulWidget {
  final String chatWithUsername, name;
  ChatScreen(this.chatWithUsername, this.name, this.personImage);
  String personImage;

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.transparent,
          elevation: 0.0,
          title: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.keyboard_arrow_left,
                      color: primaryAppColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      widget.personImage,
                      height: 40,
                      width: 40,
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Text(
                    widget.name,
                    style: primaryTextStyle(
                        color: primaryAppColor,
                        size: 19,
                        weight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: Container(
          child: Stack(
            children: [
              Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.76,
                          decoration: BoxDecoration(
                            color: chatScreenColor,
                          ),
                          child: ShaderMask(
                            shaderCallback: (Rect rect) {
                              return LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black,
                                  Colors.transparent,
                                  Colors.transparent,
                                  Colors.black
                                ],
                                stops: [
                                  0.0,
                                  0.1,
                                  0.9,
                                  1.0
                                ], // 10% purple, 80% transparent, 10% purple
                              ).createShader(rect);
                            },
                            blendMode: BlendMode.dstOut,
                            child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                itemCount: 200,
                                itemBuilder: ((context, index) {  
                              return Align(
                                alignment: Alignment.bottomRight,
                                child: MessageBlob(chat: "sfsjfkshjfks",who: SendBy.friend,time: "sdsd",),
                              );
                            })),
                          ),
                        ),
                      ],
                    ),
                  )),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                            height: 60,
                            child: CupertinoSearchTextField(
                              suffixIcon: Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 22,
                              ),
                              suffixInsets: EdgeInsets.only(right: 13),
                              controller: messageTextEditingController,
                              placeholder: "Message...",
                              onSuffixTap: () {
                                addMessage(true);
                              },
                              onSubmitted: (v) {
                                addMessage(true);
                              },
                              placeholderStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.6)),
                              style: primaryTextStyle(
                                  color: Colors.white,
                                  size: 16,
                                  weight: FontWeight.w500),
                              prefixIcon: SizedBox(
                                width: 10,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(21),
                                color: primaryAppColor.withOpacity(0.9),
                              ),
                            )),
                      )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
