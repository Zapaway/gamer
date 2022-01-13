import 'package:flutter/material.dart';

/// Turns off all indicators when scrolling.
class NoScrollableIndicatorBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}