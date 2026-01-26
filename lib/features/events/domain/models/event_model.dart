import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_model.freezed.dart';
part 'event_model.g.dart';

@freezed
class EventModel with _$EventModel {
  const factory EventModel({
    required String id,
    required String title,
    required String description,
    required DateTime startDate,
    DateTime? endDate,
    @Default(false) bool isAllDay,
    required String location,
    required double price,
    required String imageUrl,
    required String organizerId,
    @Default(0) int likes,
    @Default(0) int views,
    @Default(false) bool isBookmarked,
    @Default(0) int bookmarksCount,
    @Default('public') String planVisibility, // 'public', 'private'
    @Default(0) int creditsRequired,
    @Default(0) int totalSlots,
    String? recurrence, // 'none', 'daily', 'weekly', 'monthly'
    double? latitude,
    double? longitude,
    @Default(false) bool archived,
    @Default('event') String postType, // 'event' or 'promotion'
  }) = _EventModel;

  factory EventModel.fromJson(Map<String, dynamic> json) =>
      _$EventModelFromJson(json);
}
