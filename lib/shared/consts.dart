import 'package:flutter/material.dart';

class AppColors {
  static const Color darkBlue = Color.fromARGB(255, 12, 36, 81);
  static const Color darkTurquoise = Color.fromARGB(255, 58, 157, 163);
  static const Color turquoise = Color.fromARGB(255, 39, 172, 165);
  static const Color lightBlue = Color.fromARGB(255, 74, 176, 208);
  static const Color lightTurquoise = Color.fromARGB(255, 44, 220, 209);
  static const Color grey = Color.fromARGB(255, 196, 196, 196);
  static const Color darkGrey = Color.fromARGB(255, 40, 40, 40);
  static const Color transparentWhite = Color.fromARGB(39, 188, 188, 188);
  static const Color almostBlack = Color.fromARGB(255, 18, 18, 18);
  static const Color darkGreen = Color.fromARGB(255, 12, 81, 77);

  static const BoxDecoration backgroundGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.darkBlue,
        AppColors.turquoise,
      ],
    )
  );
  static const BoxDecoration reverseBackgroundGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.turquoise,
        AppColors.darkBlue,
      ],
    )
  );
}