// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDataModel _$UserDataModelFromJson(Map<String, dynamic> json) =>
    UserDataModel(
      username: json['username'] as String,
      level: json['level'] as int,
      userPfpPath: json['userPfpPath'] as String?,
      desc: json['desc'] as String?,
    );

Map<String, dynamic> _$UserDataModelToJson(UserDataModel instance) =>
    <String, dynamic>{
      'username': instance.username,
      'level': instance.level,
      'userPfpPath': instance.userPfpPath,
      'desc': instance.desc,
    };
