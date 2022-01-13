import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gamer/models/game_model.dart';
import 'package:gamer/models/user_model.dart';
import 'package:gamer/models/user_review_model.dart';
import 'package:gamer/services/database_service.dart';
import 'package:json_annotation/json_annotation.dart';

part 'game_review_relationship_model.g.dart';

/// Describes the relationship of a user to a game review.
/// Represents a sub-collection of [GameModel].
@JsonSerializable()
class GameReviewRelationshipModel {
  /// Must be initialized using [GameReviewRelationship.fromFirestore]
  @JsonKey(ignore: true)
  late final String id;  // user ID

  final String userReviewID;

  // getters
  Future<UserDataModel> getUser() async {
    return await DatabaseService(
      userModel: UserModel(uid: id)
    ).getUserData();
  }
  Future<UserReviewModel> getUserReview() async {
    return await DatabaseService(
      userModel: UserModel(uid: id)
    ).getUserReviewData(userReviewID).then((value) {
      return value;
    });
  }

  GameReviewRelationshipModel({required this.userReviewID});
  factory GameReviewRelationshipModel.fromFirestore(DocumentSnapshot doc) {
    return GameReviewRelationshipModel.fromJson(doc.data() as dynamic)..id = doc.id;
  }

  factory GameReviewRelationshipModel.fromJson(Map<String, dynamic> json)
    => _$GameReviewRelationshipModelFromJson(json);
  Map<String, dynamic> toJson() => _$GameReviewRelationshipModelToJson(this);
}