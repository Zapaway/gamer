import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// Basic info about a user.
class UserModel {
  final String uid;

  const UserModel({
    required this.uid,
  });
}

/// User account info on the app.
@JsonSerializable(explicitToJson: true)
class UserDataModel {
  /// initialized from [UserDataModel.fromFirestore]
  @JsonKey(ignore: true,)
  late final UserModel user;

  final String username;
  final int level;
  final String? userPfpPath;
  final String? desc;

  // getters
  static const defaultPfpProvider = AssetImage("assets/default_pfp.png");

  UserDataModel({
    required this.username,
    required this.level,
    this.userPfpPath,
    this.desc,
  });
  factory UserDataModel.fromFirestore(DocumentSnapshot doc) {
    return UserDataModel.fromJson(doc.data() as dynamic)..user = UserModel(uid: doc.id);
  }

  factory UserDataModel.fromJson(Map<String, dynamic> json) => _$UserDataModelFromJson(json);
  /// Does not encode [user]
  Map<String, dynamic> toJson() => _$UserDataModelToJson(this);
}
