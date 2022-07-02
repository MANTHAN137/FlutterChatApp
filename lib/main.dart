// ignore_for_file: unused_local_variable

import 'package:chat_app/services/auth.dart';
import 'package:chat_app/views/home.dart';
import 'package:chat_app/views/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      home: FutureBuilder(
        future: AuthMethods().getCurrentUser(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            User? currentUser = snapshot.data;
            return Home(email: currentUser!.email!,);
          } else {
            return const SignIn();
          }
        },
      ),
    );
  }
}
