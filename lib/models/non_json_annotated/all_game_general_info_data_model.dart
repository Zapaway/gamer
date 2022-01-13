import 'package:flutter/material.dart';
import 'package:gamer/models/game_model.dart';

/// All game info that does not include reviews.
class AllGameGeneralInfoDataModel {
  final ImageProvider gameIconProvider;
  final GameModel gameModel;
  final int amountOfReviews;
  final double averageGameplayStars;
  final double averagePlayabilityStars;
  final double averageVisualsStars;

  const AllGameGeneralInfoDataModel({
    required this.gameIconProvider,
    required this.gameModel,
    required this.amountOfReviews,
    required this.averageGameplayStars,
    required this.averagePlayabilityStars,
    required this.averageVisualsStars,
  });
}
