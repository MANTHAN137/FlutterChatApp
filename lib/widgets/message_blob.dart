// ignore_for_file: must_be_immutable

import 'package:chat_app/constants/constants.dart';
import 'package:flutter/material.dart';

class MessageBlob extends StatefulWidget {
  MessageBlob({Key? key, required this.chat, required this.time, required this.who})
      : super(key: key);
  String chat;
  String time;
  SendBy who;

  @override
  State<MessageBlob> createState() => _MessageBlobState();
}

class _MessageBlobState extends State<MessageBlob> {
  Color color1 = const Color(0xffFFD5D4);
  Color color2 = const Color(0xffE5E5E5);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: widget.who==SendBy.me ? color1 : color2
      ),
      child: Text(widget.chat,textAlign: TextAlign.left,),
    );
  }
}
