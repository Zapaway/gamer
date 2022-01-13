import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamer/models/non_json_annotated/all_game_review_data_model.dart';

/// Game data related to its reviews.
class GameReviews {
  final List<AllGameReviewDataModel> allReviews;

  const GameReviews({required this.allReviews});

  // general game data
  int get amountOfReviews => allReviews.length;
  double get averageGameplayStars => amountOfReviews != 0 ? allReviews
    .map((e) => e.userReview.gameplayStars)
    .reduce((a, b) => a + b)
    / amountOfReviews : 0;
  double get averagePlayabilityStars => amountOfReviews != 0 ? allReviews
    .map((e) => e.userReview.playabilityStars)
    .reduce((a, b) => a + b)
    / amountOfReviews : 0;
  double get averageVisualsStars => amountOfReviews != 0 ? allReviews
    .map((e) => e.userReview.visualsStars)
    .reduce((a, b) => a + b)
    / amountOfReviews : 0;
}
/// Allows notification of any game review changes, including
/// real time user review updates.
class GameReviewsNotifier extends StateNotifier<GameReviews> {
  final Ref ref;

  GameReviewsNotifier({required this.ref})
    : super(const GameReviews(allReviews: []));

  void set(List<AllGameReviewDataModel> reviews)
    => state = GameReviews(allReviews: reviews);
}
