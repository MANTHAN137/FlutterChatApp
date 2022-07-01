import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Color primaryAppColor = Colors.grey.shade900;
const Color chatScreenColor = Color(0xffFAFAFA);
TextStyle primaryTextStyle(
    {required Color color, required double size, required FontWeight weight}) {
  return GoogleFonts.poppins(
    color: color,
    fontSize: size,
    fontWeight: weight,
  );
}

enum SendBy {
  me,
  friend
}