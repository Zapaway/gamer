import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamer/models/user_model.dart';
import 'package:gamer/models/user_review_model.dart';
import 'package:gamer/services/auth_service.dart';
import 'package:gamer/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:gamer/services/storage_service.dart';

import 'game_related_providers.dart';

typedef UserModelGetterUsingUserDataModelStreamProviderRef =
UserModel? Function(AutoDisposeStreamProviderRef<UserDataModel>);

/* Providers. */
/// Used in auth methods and screens.
final authStateStreamProvider = StreamProvider.autoDispose<UserModel?>(
  (ref) => AuthService().onAuthStateChanged
);

/// Can be used in anywhere except for auth methods and screens to
/// retrieve current user data. Use [currUserPfpIconFutureProvider] to fetch
/// current user's profile picture.
final currUserDataStreamProvider = _getUserDataStreamProvider(
  (ref) => ref.watch(authStateStreamProvider).value
);

/// Fetches the current user's profile picture.
final currUserPfpIconFutureProvider = getUserPfpIconFutureProvider(
  currUserDataStreamProvider);

/// Convenient provider that automatically detects if the curr user's review is
/// new or existing and uses its corresponding provider.
final alwaysUpdateCurrUserReviewFutureProvider = FutureProvider
  .autoDispose.family<UserReviewModel?, String>((ref, gameID) async {
    final currNewReviewFuture = ref.watch(
      newCurrUserReviewOnGameStreamProvider(gameID).future
    );
    final currExistingReviewFuture = ref.watch(
      existingCurrUserReviewOnGameFutureProvider(gameID).future
    );

    UserReviewModel? res;
    res = await currNewReviewFuture; // if not new, attempt to find existing one
    res ??= await currExistingReviewFuture;
    return res;
  }
);
/// Fetches the current user's game review using [gameID].
/// Only useful if listening for a NEW review.
final newCurrUserReviewOnGameStreamProvider = StreamProvider
  .autoDispose.family<UserReviewModel?, String>((ref, gameID) {
    final user = ref
      .watch(authStateStreamProvider)
      .asData
      ?.value;
    if (user == null) return Stream.value(null);

    // keep watching the list of game reviews to see if there is a new one
    final allGameReviews = ref
      .watch(gameReviewsStreamProvider(gameID))
      .asData
      ?.value;
    if (allGameReviews == null) return Stream.value(null);

    final relationship = allGameReviews[user.uid];
    if (relationship == null) return Stream.value(null);

    return DatabaseService(userModel: user)
      .getUserReviewDataStream(relationship.userReviewID);
  }
);
/// Fetches the current user's game review using [gameID].
/// Only useful if listening to updates of the EXISTING review.
final existingCurrUserReviewOnGameFutureProvider = FutureProvider
  .autoDispose.family<UserReviewModel?, String>((ref, gameID) async {
    final user = ref
      .watch(authStateStreamProvider)
      .asData
      ?.value;
    if (user == null) return null;

    final allGameReviews = await DatabaseService
      .getGameReviewRelationships(gameID);
    final relationship = allGameReviews[user.uid];
    if (relationship == null) return null;

    // keep watching the existing review to listen to updates
    final userReviewOnGameStreamProvider = StreamProvider
      .autoDispose<UserReviewModel>(
        (ref) => DatabaseService(userModel: user)
          .getUserReviewDataStream(relationship.userReviewID)
    );
    final userReviewFuture = ref.watch(userReviewOnGameStreamProvider.future);

    return await userReviewFuture;
  }
);

/* Functions to get providers based on arguments passed. */
/// Simplified method to get user data stream provider using only a [UserModel].
AutoDisposeStreamProvider<UserDataModel> getUserDataStreamProvider(
    UserModel userModel
    ) => _getUserDataStreamProvider((_) => userModel);
/// Get user data stream provider with a function to get [UserModel].
AutoDisposeStreamProvider<UserDataModel> _getUserDataStreamProvider(
    UserModelGetterUsingUserDataModelStreamProviderRef userModelGetter
    ) {
  return StreamProvider.autoDispose((ref) {
    final userModel = userModelGetter(ref);

    return userModel != null
      ? DatabaseService(userModel: userModel).userDataStream
      : throw CannotLoadUserDataException();
  });
}

AutoDisposeStreamProvider<List<UserReviewModel>> getUserReviewsStreamProvider(
  UserModel userModel
) {
  return StreamProvider.autoDispose((ref) =>
    DatabaseService(userModel: userModel).getAllUserReviewsStream()
  );
}

AutoDisposeFutureProvider<ImageProvider> getUserPfpIconFutureProvider(
    AutoDisposeStreamProvider<UserDataModel> userDataModelStreamProvider
    ) {
  return FutureProvider.autoDispose<ImageProvider>((ref) async {
    ref.maintainState = true;

    // only care about if the path value changes
    final userPfpPath = ref.watch(userDataModelStreamProvider.select(
      (value) => value.maybeWhen(
        data: (x) => x.userPfpPath,
        orElse: () => null
      )
    ));
    if (userPfpPath == null) return UserDataModel.defaultPfpProvider;

    return StorageService().attemptToGetImageProviderFromFile(
        userPfpPath, UserDataModel.defaultPfpProvider
    );
  });
}

/// Notifies of any changes to a currently existing user review on a game.
AutoDisposeStreamProvider<UserReviewModel> getUserReviewOnGameStreamProvider(
  UserModel user, String userReviewID,
) {
  return StreamProvider.autoDispose<UserReviewModel>(
    (ref) => DatabaseService(userModel: user)
      .getUserReviewDataStream(userReviewID)
  );
}


class CannotLoadUserDataException implements Exception {
  final String message = "Error loading in user data.";
}