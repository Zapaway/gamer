import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'game_model.g.dart';

/// Game info.
///
/// A fresh game will have a [id] of null.
@JsonSerializable(explicitToJson: true)
class GameModel {
  @JsonKey(ignore: true,)
  late final String? id;

  final String name;
  final String nameLower;  // used for querying
  final String publisher;
  final String desc;
  final String iconImagePath;
  final GameCategoriesModel categories;

  // getters
  static const cannotLoadGameIconProvider = AssetImage(
    "assets/cannot_load_in_game_icon.png");
  Future<ImageProvider> getGameIconProvider() async {
    try {
      final ref = FirebaseStorage.instance.ref().child(iconImagePath);
      return NetworkImage(await ref.getDownloadURL());
    }
    catch (e) {
      return cannotLoadGameIconProvider;
    }
  }

  GameModel({
    required this.name,
    required this.nameLower,
    required this.publisher,
    required this.desc,
    required this.iconImagePath,
    required this.categories,
  });
  factory GameModel.fromFirestore(DocumentSnapshot doc) {
    return GameModel.fromJson(doc.data() as dynamic)..id = doc.id;
  }

  factory GameModel.fromJson(Map<String, dynamic> json) => _$GameModelFromJson(json);
  /// Does not encode [id]
  Map<String, dynamic> toJson() => _$GameModelToJson(this);
}

@JsonSerializable()
class GameCategoriesModel {
  final String genre;
  final String ageRating;

  const GameCategoriesModel({
    required this.genre,
    required this.ageRating,
  });

  factory GameCategoriesModel.fromJson(Map<String, dynamic> json) => _$GameCategoriesModelFromJson(json);
  Map<String, dynamic> toJson() => _$GameCategoriesModelToJson(this);
}