import 'package:chat_app/constants/constants.dart';
import 'package:chat_app/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Me",
                style: primaryTextStyle(
                    color: Colors.orange.shade300,
                    size: size.width * 0.16,
                    weight: FontWeight.w700),
              ),
              Text(
                "Chat",
                style: primaryTextStyle(
                    color: primaryAppColor,
                    size: size.width * 0.16,
                    weight: FontWeight.w700),
              ),
            ],
          ),
          Text(
            "Chat like a champ!",
            style: primaryTextStyle(
                color: primaryAppColor,
                size: size.width * 0.05,
                weight: FontWeight.w400),
          ),
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Lottie.asset("assets/chatman.json"),
          ),
          Center(
              child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.orange.shade300, // background (button) color
              onPrimary: Colors.white, 
              elevation: 5,
              padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)
              )// foreground (text) color
            ),
            onPressed: () {
              AuthMethods().signInWithGoogle(context);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(FontAwesomeIcons.googlePlusG,color: Colors.red,),
                const SizedBox(width: 20,),
                Text(
                  "Sign In with Google",
                  style: primaryTextStyle(
                      color: Colors.white, size: 18, weight: FontWeight.w500),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
