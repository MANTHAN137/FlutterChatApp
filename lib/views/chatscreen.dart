// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_print, unnecessary_string_escapes, must_be_immutable, unused_local_variable, unrelated_type_equality_checks

import 'dart:collection';

import 'package:chat_app/constants/constants.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/widgets/message_blob.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:random_string/random_string.dart';

class ChatScreen extends StatefulWidget {
  final String chatWithUsername, name;
  ChatScreen(
      this.chatWithUsername, this.name, this.personImage, this.chatRoomId, this.myUsername);
  String personImage;
  String chatRoomId;
  String myUsername;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late String messageId = "";
  String? myName, myProfilePic, myEmail;
  String? myUserName;
  Queue<MessageBlob> messageBlobs = Queue();
  Stream<QuerySnapshot<Map<String, dynamic>>>? chatMessageStream;
  TextEditingController messageTextEditingController = TextEditingController();

  // getMyInfoFromSharedPreference() async {
  //   myName = (await SharedPreferenceHelper().getDisplayName());
  //   myProfilePic = (await SharedPreferenceHelper().getUserProfileUrl());
  //   myUserName = (await SharedPreferenceHelper().getUserName());
  //   myEmail = (await SharedPreferenceHelper().getUserEmail());
  // }

  addMessage(bool sendClicked) {
    if (messageTextEditingController.text != "") {
      String message = messageTextEditingController.text;
      var lastMessageTs = DateTime.now();

      String time = DateFormat.Hm().format(lastMessageTs);

      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": widget.myUsername,
        "ts": lastMessageTs,
        "imgUrl": myProfilePic
      };

      messageBlobs
          .addFirst(MessageBlob(chat: message, time: time, who: SendBy.me));

      if (messageId == "") {
        messageId = randomAlphaNumeric(12);
      }

      DatabaseMethods()
          .addMessage(widget.chatRoomId, messageId, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendTs": lastMessageTs,
          "lastMessageSendBy": widget.myUsername
        };
        DatabaseMethods()
            .updateLastMessageSend(widget.chatRoomId, lastMessageInfoMap);
      });

      if (sendClicked) {
        messageTextEditingController.text = "";
        messageId = "";
      }
    }
  }

  // doThisOnLaunch() async {
  //   await getMyInfoFromSharedPreference();
  // }

  Widget chatMessageList() {
    return StreamBuilder<QuerySnapshot>(
        stream: chatMessageStream,
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.size != 0) {
              return ListView.builder(
                  reverse: true,
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: ((context, index) {
                    String time = DateFormat.Hm().format(
                        (snapshot.data?.docs[index].get("ts") as Timestamp)
                            .toDate());

                    SendBy who = SendBy.friend;
                    if (snapshot.data!.docs[index].get('sendBy') ==
                        widget.myUsername) {
                      who = SendBy.me;
                    }

                    return MessageBlob(
                        chat: snapshot.data!.docs[index].get("message"),
                        time: time,
                        who: who);
                  }));
            } else {
              return Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.transparent,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.height * 0.4,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0.6, 4),
                              spreadRadius: 1,
                              blurRadius: 8)
                        ]),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "No messages yet...",
                          style: primaryTextStyle(
                              color: primaryAppColor,
                              size: 18,
                              weight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Send a message or reply with a greeting \nbelow!",
                          textAlign: TextAlign.center,
                          style: primaryTextStyle(
                              color: primaryAppColor,
                              size: 16,
                              weight: FontWeight.w400),
                        ),
                        Lottie.asset(
                          "assets/hello.json",
                          repeat: true,
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
          } else {
            return Center(
              child:
                  Lottie.asset("assets/loader.json", height: 200, width: 200),
            );
          }
        }));
  }

  @override
  void initState() {
    DatabaseMethods().getConversationMessages(widget.chatRoomId).then((value) {
      setState(() {
        chatMessageStream = value;
      });
    });
    // doThisOnLaunch();
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
                          height: MediaQuery.of(context).size.height * 0.77,
                          decoration: BoxDecoration(
                              color: chatScreenColor,
                              border: Border.all(
                                  color: primaryAppColor.withOpacity(0.02))),
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
                                    0.05,
                                    0.95,
                                    1.0
                                  ], // 10% purple, 80% transparent, 10% purple
                                ).createShader(rect);
                              },
                              blendMode: BlendMode.dstOut,
                              child: chatMessageList()),
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
