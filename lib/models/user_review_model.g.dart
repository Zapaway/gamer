// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserReviewModel _$UserReviewModelFromJson(Map<String, dynamic> json) =>
    UserReviewModel(
      createdOn: datetimeFromJson(json['createdOn']),
      gameID: json['gameID'] as String,
      userID: json['userID'] as String,
      gameplayStars: json['gameplayStars'] as int,
      playabilityStars: json['playabilityStars'] as int,
      visualsStars: json['visualsStars'] as int,
      review: json['review'] as String?,
    );

Map<String, dynamic> _$UserReviewModelToJson(UserReviewModel instance) =>
    <String, dynamic>{
      'createdOn': datetimeToJson(instance.createdOn),
      'gameID': instance.gameID,
      'userID': instance.userID,
      'gameplayStars': instance.gameplayStars,
      'playabilityStars': instance.playabilityStars,
      'visualsStars': instance.visualsStars,
      'review': instance.review,
    };
