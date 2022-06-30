import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/chatscreen.dart';
import 'package:chat_app/views/signin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../helperfunction/sharedpref_helper.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isSearching = false;
  late String myName, myProfilePic, myUserName, myEmail;
  TextEditingController searchUsernameEditingController =
      TextEditingController();

  getMyInfoFromSharedPreference() async {
    myName = await SharedPreferenceHelper().getDisplayName as String;

    myProfilePic = await SharedPreferenceHelper().getUserProfileUrl() as String;
    myUserName = await SharedPreferenceHelper().getUserName() as String;
    myEmail = await SharedPreferenceHelper().getUserEmail() as String;
  }

  late Stream userStream;
  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_b";
    }
  }

  onSearchBtnClick() async {
    isSearching = true;
    setState(() {});
    userStream = await DatabaseMethods()
        .getUserByUserName(searchUsernameEditingController.text);
    setState(() {});
  }

  Widget searchListUserTile(
      {required String profileUrl, name, username, email}) {
    return GestureDetector(
      onTap: () {
        var chatRoomId = getChatRoomIdByUsernames(myUserName, username);

        Map<String, dynamic> chatRoomInfoMap = {"users": [
          myUserName,username
        ]};

            
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(username, name)));
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(80),
            child: Image.network(
              profileUrl,
              height: 30,
              width: 30,
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(name), Text(email)],
          )
        ],
      ),
    );
  }

  Widget searchUsersList() {
    return StreamBuilder(
      stream: userStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: (snapshot.data as QuerySnapshot).docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds =
                      (snapshot.data as QuerySnapshot).docs[index];
                  return searchListUserTile(
                      profileUrl: ds['imgUrl'],
                      name: ds['name'],
                      username: ds['username'],
                      email: ds['email']);
                },
              )
            : Center(
                child: const CircularProgressIndicator(),
              );
      },
    );
  }

  Widget chatRoomsList() {
    return Container();
  }

  @override
  void initState() {
    // TODO: implement initState
    getMyInfoFromSharedPreference();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MeChat"),
        actions: [
          InkWell(
            onTap: () {
              AuthMethods().signOut().then((s) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const SignIn()));
              });
            },
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Icon(Icons.exit_to_app_sharp)),
          )
        ],
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              children: [
                isSearching
                    ? GestureDetector(
                        onTap: () {
                          isSearching = false;
                          searchUsernameEditingController.text = "";
                          setState(() {});
                        },
                        child: const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(Icons.arrow_back)),
                      )
                    : Container(),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.black87,
                            width: 2.0,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        Expanded(
                            child: TextField(
                          controller: searchUsernameEditingController,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Search Username'),
                        )),
                        GestureDetector(
                            onTap: () {
                              if (searchUsernameEditingController != "") {
                                onSearchBtnClick();
                              }
                            },
                            child: const Icon(Icons.search))
                      ],
                    ),
                  ),
                ),
              ],
            ),
            isSearching ? searchUsersList() : chatRoomsList()
          ],
        ),
      ),
    );
  }
}
