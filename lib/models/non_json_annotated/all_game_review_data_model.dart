import 'package:flutter/material.dart';
import 'package:gamer/models/user_model.dart';
import 'package:gamer/models/user_review_model.dart';

/// Contains all data that is needed in a game review.
class AllGameReviewDataModel {
  final ImageProvider userPfpProvider;
  final UserDataModel userData;
  final UserReviewModel userReview;

  const AllGameReviewDataModel({
    required this.userPfpProvider,
    required this.userData,
    required this.userReview,
  });
}