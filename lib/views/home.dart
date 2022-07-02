// ignore_for_file: use_key_in_widget_constructors, unnecessary_string_escapes, unused_local_variable, avoid_print, unrelated_type_equality_checks, must_be_immutable, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:chat_app/constants/constants.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/search_user_tile.dart';
import 'package:chat_app/views/signin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../helperfunction/sharedpref_helper.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isSearching = false;
  late String myName, myProfilePic, myEmail, myUserName;

  TextEditingController searchUsernameEditingController =
      TextEditingController();

  getMyInfoFromSharedPreference() async {
    myName = (await SharedPreferenceHelper().getDisplayName());
    myProfilePic = (await SharedPreferenceHelper().getUserProfileUrl());
    myEmail = (await SharedPreferenceHelper().getUserEmail());
    myUserName = myEmail.replaceAll("@gmail.com", "");
    myUserName = (await SharedPreferenceHelper().getUserName());
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
    userStream =
        await DatabaseMethods().getName(searchUsernameEditingController.text);

    setState(() {});
  }

  Future<List<SearchListUserTile>> getAllFireUsers() async {
    List<Widget> widgets = [];
    CollectionReference cr = await DatabaseMethods().getAllUsers();
    QuerySnapshot qs = await cr.get();
    final List<SearchListUserTile> allData = await qs.docs.map((e) {
      return SearchListUserTile(
          profileUrl: e['imgUrl'],
          name: e['name'],
          email: e['email'],
          username: e['username'],
          myUserName: myUserName);
    }).toList();
    print(allData[0].name);
    return allData;
  }

  void searchByName(String name) {
    final suggestion = fireusers.where((element) {
      final storename = element.name.toLowerCase();
      final input = name.toLowerCase();
      return storename.contains(input);
    }).toList();
    setState(() {
      if (suggestion.isNotEmpty) {
        dupliFireusers = suggestion;
      } else {
        print("empty");
        dupliFireusers = fireusers;
      }
    });
  }

  List<SearchListUserTile> fireusers = [];
  List<SearchListUserTile> dupliFireusers = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getAllFireUsers().then((value) {
        fireusers = value;
        dupliFireusers = value;
        setState(() {});
      });
    });
    getMyInfoFromSharedPreference();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        foregroundColor: Colors.transparent,
        title: Padding(
          padding: const EdgeInsets.only(top: 10, left: 10),
          child:  Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Me",
                style: primaryTextStyle(
                    color: Colors.orange.shade300,
                    size: 32,
                    weight: FontWeight.w700),
              ),
              Text(
                "Chat",
                style: primaryTextStyle(
                    color: primaryAppColor,
                    size: 32,
                    weight: FontWeight.w700),
              ),
            ],
          ),
        ),
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
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.grey.shade900,
                )),
          )
        ],
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: SizedBox(
                height: 40,
                child: CupertinoSearchTextField(
                  placeholder: "Search for chats",
                  onChanged: (x) {
                    searchByName(x);
                    setState(() {});
                  },
                ),
              ),
            ),
            searchUsersList()
          ],
        ),
      ),
    );
  }

  Widget searchUsersList() {
    return fireusers.isNotEmpty
        ? ListView.separated(
            physics: BouncingScrollPhysics(),
            itemCount: dupliFireusers.length,
            shrinkWrap: true,
            separatorBuilder: ((context, index) {
              return const Divider();
            }),
            itemBuilder: (context, index) {
              return dupliFireusers[index];
            },
          )
        : SizedBox(
          height: MediaQuery.of(context).size.height*0.6,
          child: Center(
              child: CircularProgressIndicator(
                color: primaryAppColor,
                strokeWidth: 3,
              ),
            ),
        );
  }
}
