// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameModel _$GameModelFromJson(Map<String, dynamic> json) => GameModel(
      name: json['name'] as String,
      nameLower: json['nameLower'] as String,
      publisher: json['publisher'] as String,
      desc: json['desc'] as String,
      iconImagePath: json['iconImagePath'] as String,
      categories: GameCategoriesModel.fromJson(
          json['categories'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GameModelToJson(GameModel instance) => <String, dynamic>{
      'name': instance.name,
      'nameLower': instance.nameLower,
      'publisher': instance.publisher,
      'desc': instance.desc,
      'iconImagePath': instance.iconImagePath,
      'categories': instance.categories.toJson(),
    };

GameCategoriesModel _$GameCategoriesModelFromJson(Map<String, dynamic> json) =>
    GameCategoriesModel(
      genre: json['genre'] as String,
      ageRating: json['ageRating'] as String,
    );

Map<String, dynamic> _$GameCategoriesModelToJson(
        GameCategoriesModel instance) =>
    <String, dynamic>{
      'genre': instance.genre,
      'ageRating': instance.ageRating,
    };
