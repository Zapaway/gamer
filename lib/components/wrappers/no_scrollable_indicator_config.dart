import 'package:flutter/material.dart';
import 'package:gamer/shared/no_scrollable_indicator_behavior.dart';

/// Quick widget wrapper for [NoScrollableIndicatorBehavior].
class NoScrollableIndicatorConfig extends StatelessWidget {
  final Widget child;

  const NoScrollableIndicatorConfig({
    Key? key,
    required this.child
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: NoScrollableIndicatorBehavior(),
      child: child
    );
  }
}
