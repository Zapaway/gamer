import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamer/models/game_model.dart';
import 'package:gamer/models/non_json_annotated/all_game_review_data_model.dart';
import 'package:gamer/models/game_review_relationship_model.dart';
import 'package:gamer/models/user_model.dart';
import 'package:gamer/models/user_review_model.dart';
import 'package:gamer/providers/user_related_providers.dart';
import 'package:gamer/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:gamer/services/storage_service.dart';

import 'game_reviews_notifier.dart';

/// Fetches game data. Use [gameIconFutureProvider] to fetch its icon.
final gameDataStreamProvider = StreamProvider
  .autoDispose.family<GameModel, String>(
    (ref, gameID) => DatabaseService.getGameDataStream(gameID)
);

/// Allows for manipulation of review and rebuilding the widget ... (add more later)
AutoDisposeStateNotifierProvider<GameReviewsNotifier, GameReviews>
  getUserReviewModelListOnGameController() => StateNotifierProvider
    .autoDispose<GameReviewsNotifier, GameReviews>(
      (ref) => GameReviewsNotifier(ref: ref)
);
/// Convenient provider that transforms each [GameReviewRelationshipModel] into
/// [UserReviewModel]. This notifies BOTH when the amount of reviews change and
/// changes to the the review itself.
final userReviewModelsOnGameFutureProvider = FutureProvider
    .autoDispose.family<List<AllGameReviewDataModel>, String>(
        (ref, gameID) async {
      final relationshipsFuture = ref.watch(
        gameReviewsStreamProvider(gameID).future
      );

      final relationships = await relationshipsFuture;
      return [
        for (final key in relationships.keys)
          await _gameReviewDataFromUserReview(
            UserModel(uid: key),
            relationships[key]!.userReviewID,
            ref
          ),
      ];
    }
);
/// Fetches game review relationship data.
final gameReviewsStreamProvider = StreamProvider
  .autoDispose.family<Map<String, GameReviewRelationshipModel>, String>(
    (ref, gameID) => DatabaseService.getGameReviewRelationshipStream(gameID)
);

/// Fetches the game's icon picture.
final gameIconFutureProvider = FutureProvider
  .autoDispose.family<ImageProvider, String>(
    (ref, gameID) async {
      ref.maintainState = true;

      // only care about if the path value changes
      final gameIconPath = ref.watch(gameDataStreamProvider(gameID).select(
        (value) => value.maybeWhen(
          data: (x) => x.iconImagePath,
          orElse: () => null
        )
      ));

      if (gameIconPath == null) return GameModel.cannotLoadGameIconProvider;
      return StorageService().attemptToGetImageProviderFromFile(
          gameIconPath, GameModel.cannotLoadGameIconProvider
      );
    }
);

/// Gets all data of a game review in real time.
Future<AllGameReviewDataModel> _gameReviewDataFromUserReview
  (UserModel userModel, String userReviewID, AutoDisposeFutureProviderRef ref)
async {
  final userDataStreamProvider = getUserDataStreamProvider(userModel);
  final cachedUserPfpFut = ref.watch(
    getUserPfpIconFutureProvider(userDataStreamProvider).future
  );
  final userDataFut = ref.watch(userDataStreamProvider.future);
  final userReviewFut = ref.watch(
    getUserReviewOnGameStreamProvider(userModel, userReviewID).future
  );

  return AllGameReviewDataModel(
    userPfpProvider: await cachedUserPfpFut,
    userData: await userDataFut,
    userReview: await userReviewFut,
  );
}