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
      startDate: DateTime.parse(json['startDate'] as String),
      endDate:
          json['endDate'] == null
              ? null
              : DateTime.parse(json['endDate'] as String),
      isAllDay: json['isAllDay'] as bool? ?? false,
      location: json['location'] as String,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      category: json['category'] as String?,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      organizerId: json['organizerId'] as String,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      views: (json['views'] as num?)?.toInt() ?? 0,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
    );

Map<String, dynamic> _$$EventModelImplToJson(_$EventModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'isAllDay': instance.isAllDay,
      'location': instance.location,
      'lat': instance.lat,
      'lng': instance.lng,
      'category': instance.category,
      'price': instance.price,
      'imageUrl': instance.imageUrl,
      'organizerId': instance.organizerId,
      'likes': instance.likes,
      'views': instance.views,
      'isBookmarked': instance.isBookmarked,
    };
