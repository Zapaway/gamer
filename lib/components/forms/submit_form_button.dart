import 'package:flutter/material.dart';

/// Button that submits a form and matches the theme of the app.
///
/// If [disabledColor] is not passed into the constructor, it will take on
/// the value of [color]. This color will only appear if [onPressed] is null.
class AppSubmitFormButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color disabledColor;
  final bool isBolded;
  final Widget? icon;
  final VoidCallback? onPressed;

  late final ButtonStyle buttonStyle = TextButton.styleFrom(
    backgroundColor: onPressed != null ? color : disabledColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
    ),
    minimumSize: const Size.fromHeight(60),
  );
  late final TextStyle textStyle = TextStyle(
    fontSize: 20,
    fontWeight: isBolded ? FontWeight.bold : FontWeight.normal,
    color: Colors.white,
  );

  AppSubmitFormButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color = Colors.black,
    Color? disabledColor,
    this.isBolded = false,
    this.icon,
  }) : disabledColor = disabledColor ?? color, super(key: key);

  @override
  Widget build(BuildContext context) {
    return icon == null
      ? TextButton(
        style: buttonStyle,
        child: Text(text, style: textStyle,),
        onPressed: onPressed,
      )
      : TextButton.icon(
        style: buttonStyle,
        icon: icon!,
        label: Text(text, style: textStyle,),
        onPressed: onPressed,
      );
  }
}