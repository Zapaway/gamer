import 'package:flutter/material.dart';

/// Touch out of a widget to stop focusing on it
/// and dismiss the keyboard.
class KeyboardDismissible extends StatelessWidget {
  final Widget child;

  const KeyboardDismissible({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: child,
    );
  }
}
