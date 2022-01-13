import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gamer/models/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_review_model.g.dart';

DateTime datetimeFromJson(dynamic val) => (val as Timestamp).toDate();
dynamic datetimeToJson(DateTime dateTime) => Timestamp.fromDate(dateTime);

/// User review info on a game.
/// Represents a sub-collection of [UserDataModel].
///
/// A fresh review will have a [id] of null.
@JsonSerializable()
class UserReviewModel {
  @JsonKey(ignore: true)
  late final String? id;

  @JsonKey(
    fromJson: datetimeFromJson,
    toJson: datetimeToJson
  )
  final DateTime createdOn;
  final String gameID;
  final String userID;
  final int gameplayStars;
  final int playabilityStars;
  final int visualsStars;
  final String? review;

  UserReviewModel({
    required this.createdOn,
    required this.gameID,
    required this.userID,
    required this.gameplayStars,
    required this.playabilityStars,
    required this.visualsStars,
    this.review,
  });
  factory UserReviewModel.fromFirestore(DocumentSnapshot doc) {
    return UserReviewModel.fromJson(doc.data() as dynamic)..id = doc.id;
  }

  factory UserReviewModel.fromJson(Map<String, dynamic> json) => _$UserReviewModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserReviewModelToJson(this);
}