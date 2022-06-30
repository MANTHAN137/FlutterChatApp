import 'package:flutter/material.dart';

class Transition extends StatefulWidget {
  Transition(
      {Key? key,
      required this.backgroundcolor,
      required this.child,
      required this.twoprocess})
      : super(key: key);
  final Function twoprocess;
  final Widget child;
  final Color backgroundcolor;

  @override
  State<Transition> createState() => _TransitionState();
}

class _TransitionState extends State<Transition> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    widget.twoprocess();
  }

  @override
  Widget build(BuildContext context) {
    return Material(color: widget.backgroundcolor,child: Center(child: widget.child),);
  }
}
