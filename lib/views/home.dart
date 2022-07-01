import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/chatscreen.dart';
import 'package:chat_app/views/signin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Widget searchListUserTile(
      {required String profileUrl, name, username, email}) {
    return GestureDetector(
      onTap: () {
        var chatRoomId = getChatRoomIdByUsernames(myUserName, username);

        Map<String, dynamic> chatRoomInfoMap = {
          "users": [myUserName, username]
        };

        DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(username, name)));
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              profileUrl,
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
                name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 2,
              ),
              Text(email)
            ],
          )
        ],
      ),
    );
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
    print(allData);

    return allData;
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

    //   return fireusers.isEmpty
    //       ? ListView.builder(
    //           itemCount: fireusers.length,
    //           shrinkWrap: true,
    //           itemBuilder: (context, index) {
    //             return fireusers[index];
    //           },
    //         )
    //       : Center(
    //           child: const CircularProgressIndicator(),
    //         );
  }

  Widget chatRoomsList() {
    return Container();
  }

  void searchByName(String name) {
    final suggestion = fireusers.where((element) {
      final storename = element.name.toLowerCase();
      final input = name.toLowerCase();

      return storename.contains(input);
    }).toList();

    setState(() {
      fireusers = suggestion;
    });
  }

  List<SearchListUserTile> fireusers = [];

  @override
  void initState() {
    getMyInfoFromSharedPreference();
    getAllFireUsers().then((value) {
      fireusers = value;
    });

    super.initState();
    print(fireusers.toString());
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
                          onChanged: (value) {
                            searchByName(value);
                          },
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
// 
// class SearchListUserTile extends StatefulWidget {
//   SearchListUserTile(
//       {Key? key,
//       required this.myUserName,
//       required this.name,
//       required this.email,
//       required this.profileUrl,
//       required this.username})
//       : super(key: key);
//   String myUserName, name, profileUrl, email, username;
//   @override
//   State<SearchListUserTile> createState() => _SearchListUserTileState();
// }
// 
// class _SearchListUserTileState extends State<SearchListUserTile> {
//   getChatRoomIdByUsernames(String a, String b) {
//     if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
//       return "$b\_$a";
//     } else {
//       return "$a\_b";
//     }
//   }
// 
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         var chatRoomId =
//             getChatRoomIdByUsernames(widget.myUserName, widget.username);
// 
//         Map<String, dynamic> chatRoomInfoMap = {
//           "users": [widget.myUserName, widget.username]
//         };
// 
//         DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
// 
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) =>
//                     ChatScreen(widget.username, widget.name)));
//       },
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: Image.network(
//               widget.profileUrl,
//               height: 60,
//               width: 60,
//             ),
//           ),
//           const SizedBox(
//             width: 20,
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 widget.name,
//                 style:
//                     const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(
//                 height: 2,
//               ),
//               Text(widget.email)
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }
