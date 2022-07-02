// ignore_for_file: must_be_immutable, unnecessary_string_escapes
import 'package:chat_app/constants/constants.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/chatscreen.dart';
import 'package:flutter/cupertino.dart';

class SearchListUserTile extends StatefulWidget {
  SearchListUserTile(
      {Key? key,
      required this.myUserName,
      required this.name,
      required this.email,
      required this.profileUrl,
      required this.username})
      : super(key: key);
  String myUserName, name, profileUrl, email, username;
  @override
  State<SearchListUserTile> createState() => _SearchListUserTileState();
}

class _SearchListUserTileState extends State<SearchListUserTile> {
  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_b";
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        String chatRoomId =
            getChatRoomIdByUsernames(widget.myUserName, widget.username);

        Map<String, dynamic> chatRoomInfoMap = {
          "users": [widget.myUserName, widget.username]
        };

        DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
        Navigator.of(context).push(
            SecondPageRoute(widget.username, widget.name, widget.profileUrl,chatRoomId));
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.network(
              widget.profileUrl,
              height: 60,
              width: 60,
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style: primaryTextStyle(
                    color: primaryAppColor, size: 16, weight: FontWeight.w600),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(widget.email)
            ],
          )
        ],
      ),
    );
  }
}

class SecondPageRoute extends CupertinoPageRoute {
  SecondPageRoute(this.chatWithUsername, this.name, this.personImage,this.chatRoomId)
      : super(
            builder: (BuildContext context) =>
                ChatScreen(chatWithUsername, name, personImage,chatRoomId));

  String chatWithUsername, name, personImage,chatRoomId;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return ScaleTransition(
        scale: animation.drive(Tween(begin: 1,end: 1)),
        child: ChatScreen(chatWithUsername, name, personImage,chatRoomId));
  }
}
