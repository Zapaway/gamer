import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamer/shared/consts.dart';

/// Text form field that matches the theme of the app.
///
/// If the text field is multiline, it will have the same border radius
/// of 20px. Else, it will have 50px unfocused and 20px focused.
class AppTextFormField extends StatefulWidget {
  final String hintText;
  final String? Function(String?) validator;
  final String? helperText;
  final String? counterLabel;
  final void Function(String?)? onChanged;
  final ScrollController? scrollController;
  final List<TextInputFormatter>? formatters;
  final String? initValue;
  final bool obscureText;
  final bool autoCorrect;
  final bool darkMode;

  /// If value is...
  /// - less than 1, multiline with automatic wrapping
  /// - 1, single line
  /// - greater than 1, multiline with sized amount of lines
  final int lines;

  /// if there is invalid text, it switches from
  /// [AutovalidateMode.disabled] to [AutovalidateMode.onUserInteraction]
  /// and same vice versa
  ///
  /// **NOTE: You must save the form for this to take effect.**
  final bool useSpecialAutovalidationMode;

  const AppTextFormField({
    Key? key,
    required this.hintText,
    required this.validator,
    this.helperText,
    this.counterLabel,
    this.onChanged,
    this.scrollController,
    this.formatters,
    this.initValue,
    this.obscureText = false,
    this.autoCorrect = false,
    this.darkMode = true,
    this.lines = 1,
    this.useSpecialAutovalidationMode = false,
  }) : super(key: key);

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  bool _useAutovalidateOnUserInteract = false;
  int? _textCounter;

  @override
  void initState() {
    _textCounter = widget.counterLabel != null ? 0 : null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final helperAndCounterTextStyle = TextStyle(
      fontSize: 14,
      color: widget.darkMode ? Colors.black : Colors.white,
    );
    final keyboardType = widget.lines != 1
      ? TextInputType.multiline
      : TextInputType.text;

    return TextFormField(
      initialValue: widget.initValue,
      autocorrect: widget.autoCorrect,
      scrollController: widget.scrollController,
      maxLines: widget.lines < 1 ? null : widget.lines,
      keyboardType: keyboardType,
      inputFormatters: widget.formatters,
      obscureText: widget.obscureText,
      style: TextStyle(
        fontSize: 22,
        color: widget.darkMode ? Colors.black : Colors.white
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
        hintText: widget.hintText,
        hintStyle: TextStyle(
            fontSize: 22,
            color: widget.darkMode ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.5)
        ),
        helperText: widget.helperText,
        helperStyle: helperAndCounterTextStyle,
        helperMaxLines: 10,
        counterText: widget.counterLabel != null
          ? "$_textCounter${widget.counterLabel}"
          : null,
        counterStyle: helperAndCounterTextStyle.copyWith(fontWeight: FontWeight.bold),
        errorStyle: helperAndCounterTextStyle.copyWith(color: Colors.red),
        errorMaxLines: 10,
        focusColor: AppColors.darkBlue,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            keyboardType == TextInputType.multiline
              ? 20 : 50
          ),
          borderSide: BorderSide(
            color: widget.darkMode ? Colors.black : Colors.white
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: widget.darkMode ? AppColors.lightBlue : Colors.white
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            keyboardType == TextInputType.multiline
              ? 20 : 50
          ),
          borderSide: const BorderSide(
            color: Colors.red
          )
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Colors.red
          ),
        ),
      ),
      onChanged: (x) {
        if (widget.counterLabel != null) {
          setState(() => _textCounter = x.length);
        }
        widget.onChanged?.call(x);
      },
      onSaved: (_) => setState(() {}),
      autovalidateMode: _useAutovalidateOnUserInteract
        ? AutovalidateMode.onUserInteraction
        : AutovalidateMode.disabled,
      validator: (x) {
        final errText = widget.validator(x);
        if (widget.useSpecialAutovalidationMode) {
          if (errText != null) {
            _useAutovalidateOnUserInteract = true;
          }
          else {
            _useAutovalidateOnUserInteract = false;
          }
        }

        return errText;
      },
    );
  }
}