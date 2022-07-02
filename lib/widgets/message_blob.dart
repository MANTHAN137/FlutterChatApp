// ignore_for_file: must_be_immutable, unused_local_variable

import 'package:chat_app/constants/constants.dart';
import 'package:flutter/material.dart';

class MessageBlob extends StatefulWidget {
  MessageBlob(
      {Key? key, required this.chat, required this.time, required this.who})
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
    final size = MediaQuery.of(context).size;

    AlignmentGeometry alignmentGeometry = Alignment.bottomLeft;

    if (widget.who == SendBy.me) {
      alignmentGeometry = Alignment.bottomRight;
    }

    return Align(
      alignment: alignmentGeometry,
      child: Container(
        constraints: BoxConstraints(maxWidth: size.width * 0.8),
        padding: const EdgeInsets.all(18),
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: widget.who == SendBy.me ? color1 : color2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: Text(
                widget.chat,
                textAlign: TextAlign.left,
                style: primaryTextStyle(
                    color: primaryAppColor, size: 14, weight: FontWeight.w500),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(widget.time),
            )
          ],
        ),
      ),
    );
  }
}
