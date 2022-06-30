import 'package:chat_app/services/auth.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Massenger"),
          shadowColor: Colors.grey,
          backgroundColor: Color.fromARGB(255, 255, 139, 104),
        ),
        body: Center(
          child: GestureDetector(
            onTap: () {
              AuthMethods().signInWithGoogle(context);
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 245, 156, 129),
                  borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: const Text(
                "Sign In with Google",
                style: TextStyle(fontSize: 20,fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ));
  }
}
