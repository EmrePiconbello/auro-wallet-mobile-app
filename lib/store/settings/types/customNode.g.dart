// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customNode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomNode _$CustomNodeFromJson(Map<String, dynamic> json) => CustomNode(
      name: json['name'] as String,
      url: json['url'] as String,
      networksType: json['networksType'] as String?,
      chainId: json['chainId'] as String?,
    );

Map<String, dynamic> _$CustomNodeToJson(CustomNode instance) =>
    <String, dynamic>{
      'name': instance.name,
      'url': instance.url,
      'networksType': instance.networksType,
      'chainId': instance.chainId,
    };
