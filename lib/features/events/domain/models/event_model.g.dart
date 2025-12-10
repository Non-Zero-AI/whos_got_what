// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EventModelImpl _$$EventModelImplFromJson(Map<String, dynamic> json) =>
    _$EventModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      location: json['location'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      organizerId: json['organizerId'] as String,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
    );

Map<String, dynamic> _$$EventModelImplToJson(_$EventModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'date': instance.date.toIso8601String(),
      'location': instance.location,
      'price': instance.price,
      'imageUrl': instance.imageUrl,
      'organizerId': instance.organizerId,
      'likes': instance.likes,
      'isBookmarked': instance.isBookmarked,
    };
