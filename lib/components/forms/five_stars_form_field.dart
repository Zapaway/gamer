import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// App rating system that uses five stars.
class FiveStarsFormField extends FormField<int> {
  final double? width;
  final Widget? label;
  final void Function(int?)? onSavedCallback;
  final MainAxisAlignment rowAxisAlignment;
  final double spacing;

  FiveStarsFormField({
    Key? key,
    this.width,
    this.label,
    this.onSavedCallback,
    this.rowAxisAlignment = MainAxisAlignment.start,
    this.spacing = 0,
    int initStars = 0,
    bool enabled = true,
    FormFieldValidator<int>? validator,
  }) : super(
    key: key,
    initialValue: initStars,
    enabled: enabled,
    onSaved: onSavedCallback,
    validator: validator,
    builder: (state) {
      return Row(
        mainAxisAlignment: rowAxisAlignment,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (label != null) label,

          ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, i) {
              return Padding(
                padding: EdgeInsets.only(right: spacing),
                child: GestureDetector(
                  child: SvgPicture.asset(
                    i < (state.value ?? 0) ? "assets/colored_star.svg" : "assets/grey_star.svg",
                    width: width,
                  ),
                  onTap: () {
                    if (enabled) state.didChange(i + 1);
                  },
                ),
              );
            },
          ),
        ],
      );
    },
  );
}
