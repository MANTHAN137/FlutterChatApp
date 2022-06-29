
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/views/signin.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
      title: const Text("MeChat"),
      actions: [
        InkWell(
          onTap: () {
            AuthMethods().signOut().then((s){
              Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>SignIn()));
            });
          },
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.exit_to_app_sharp)),
        )
      ],
    ));
  }
}
