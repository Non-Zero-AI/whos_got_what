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
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      organizerId: json['organizerId'] as String,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      views: (json['views'] as num?)?.toInt() ?? 0,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      bookmarksCount: (json['bookmarksCount'] as num?)?.toInt() ?? 0,
      planVisibility: json['planVisibility'] as String? ?? 'public',
      creditsRequired: (json['creditsRequired'] as num?)?.toInt() ?? 0,
      totalSlots: (json['totalSlots'] as num?)?.toInt() ?? 0,
      recurrence: json['recurrence'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      archived: json['archived'] as bool? ?? false,
      postType: json['postType'] as String? ?? 'event',
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
      'price': instance.price,
      'imageUrl': instance.imageUrl,
      'organizerId': instance.organizerId,
      'likes': instance.likes,
      'views': instance.views,
      'isBookmarked': instance.isBookmarked,
      'bookmarksCount': instance.bookmarksCount,
      'planVisibility': instance.planVisibility,
      'creditsRequired': instance.creditsRequired,
      'totalSlots': instance.totalSlots,
      'recurrence': instance.recurrence,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'archived': instance.archived,
      'postType': instance.postType,
    };
