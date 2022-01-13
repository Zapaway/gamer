import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamer/models/user_model.dart';
import 'package:gamer/models/user_review_model.dart';

/// Allows the success widget to use the user and review data for building.
typedef UserReviewDataOnGameSuccessFunc = Widget Function(
  UserDataModel,
  UserReviewModel?
);
typedef WidgetCallback = Widget Function();

/// All data of the user and their review on the game that is continuously
/// fetched are within this wrapper.
///
/// [userDataModelAsync] & [userReviewModelAsync] are required to
/// add clarity as to what async values the parent widget is using.
///
/// [error] and [loading] will apply to both [UserDataModel]
/// and [UserReviewModel] watchers.
class UserReviewDataOnGameProviderWrapper extends ConsumerWidget {
  final AsyncValue<UserDataModel> userDataModelAsync;
  final AsyncValue<UserReviewModel?> userReviewModelAsync;
  final String gameID;

  final UserReviewDataOnGameSuccessFunc success;
  final WidgetCallback error;
  final WidgetCallback loading;

  const UserReviewDataOnGameProviderWrapper({
    Key? key,
    required this.userDataModelAsync,
    required this.userReviewModelAsync,
    required this.gameID,
    required this.success,
    required this.error,
    required this.loading,
  }) : super(key: key);

  /// Use this if the [error] and [loading] widgets will be the same.
  factory UserReviewDataOnGameProviderWrapper.maybeWhen(
    {
      required AsyncValue<UserDataModel> userDataModelAsync,
      required AsyncValue<UserReviewModel?> userReviewModelAsync,
      required String gameID,
      required UserReviewDataOnGameSuccessFunc success,
      required WidgetCallback orElse,
    }
  ) => UserReviewDataOnGameProviderWrapper(
    userDataModelAsync: userDataModelAsync,
    userReviewModelAsync: userReviewModelAsync,
    gameID: gameID,
    success: success,
    error: orElse,
    loading: orElse,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return userReviewModelAsync.when(
      data: (userReview) {
        return userDataModelAsync.when(
          data: (userData) => success(userData, userReview),
          error: (_, __) => error(),
          loading: () => loading(),
        );
      },
      error: (_, __) => error(),
      loading: () => loading(),
    );
  }
}