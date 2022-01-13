import 'package:flutter/material.dart';
import 'package:gamer/shared/consts.dart';

class GameCategoryChip extends StatelessWidget {
  final String category;

  const GameCategoryChip({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        category,
        style: const TextStyle(
            fontSize: 14,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 3,
        softWrap: false,
      ),
      backgroundColor: AppColors.turquoise,
      labelPadding: const EdgeInsets.symmetric(vertical: 0.1, horizontal: 15),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
