// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

EventModel _$EventModelFromJson(Map<String, dynamic> json) {
  return _EventModel.fromJson(json);
}

/// @nodoc
mixin _$EventModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  bool get isAllDay => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  String get organizerId => throw _privateConstructorUsedError;
  int get likes => throw _privateConstructorUsedError;
  int get views => throw _privateConstructorUsedError;
  bool get isBookmarked => throw _privateConstructorUsedError;
  int get bookmarksCount => throw _privateConstructorUsedError;
  String get planVisibility =>
      throw _privateConstructorUsedError; // 'public', 'private'
  int get creditsRequired => throw _privateConstructorUsedError;
  int get totalSlots => throw _privateConstructorUsedError;
  String? get recurrence =>
      throw _privateConstructorUsedError; // 'none', 'daily', 'weekly', 'monthly'
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  bool get archived => throw _privateConstructorUsedError;
  String get postType => throw _privateConstructorUsedError;

  /// Serializes this EventModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EventModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventModelCopyWith<EventModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventModelCopyWith<$Res> {
  factory $EventModelCopyWith(
    EventModel value,
    $Res Function(EventModel) then,
  ) = _$EventModelCopyWithImpl<$Res, EventModel>;
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    DateTime startDate,
    DateTime? endDate,
    bool isAllDay,
    String location,
    double price,
    String imageUrl,
    String organizerId,
    int likes,
    int views,
    bool isBookmarked,
    int bookmarksCount,
    String planVisibility,
    int creditsRequired,
    int totalSlots,
    String? recurrence,
    double? latitude,
    double? longitude,
    bool archived,
    String postType,
  });
}

/// @nodoc
class _$EventModelCopyWithImpl<$Res, $Val extends EventModel>
    implements $EventModelCopyWith<$Res> {
  _$EventModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EventModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? isAllDay = null,
    Object? location = null,
    Object? price = null,
    Object? imageUrl = null,
    Object? organizerId = null,
    Object? likes = null,
    Object? views = null,
    Object? isBookmarked = null,
    Object? bookmarksCount = null,
    Object? planVisibility = null,
    Object? creditsRequired = null,
    Object? totalSlots = null,
    Object? recurrence = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? archived = null,
    Object? postType = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            title:
                null == title
                    ? _value.title
                    : title // ignore: cast_nullable_to_non_nullable
                        as String,
            description:
                null == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String,
            startDate:
                null == startDate
                    ? _value.startDate
                    : startDate // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            endDate:
                freezed == endDate
                    ? _value.endDate
                    : endDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            isAllDay:
                null == isAllDay
                    ? _value.isAllDay
                    : isAllDay // ignore: cast_nullable_to_non_nullable
                        as bool,
            location:
                null == location
                    ? _value.location
                    : location // ignore: cast_nullable_to_non_nullable
                        as String,
            price:
                null == price
                    ? _value.price
                    : price // ignore: cast_nullable_to_non_nullable
                        as double,
            imageUrl:
                null == imageUrl
                    ? _value.imageUrl
                    : imageUrl // ignore: cast_nullable_to_non_nullable
                        as String,
            organizerId:
                null == organizerId
                    ? _value.organizerId
                    : organizerId // ignore: cast_nullable_to_non_nullable
                        as String,
            likes:
                null == likes
                    ? _value.likes
                    : likes // ignore: cast_nullable_to_non_nullable
                        as int,
            views:
                null == views
                    ? _value.views
                    : views // ignore: cast_nullable_to_non_nullable
                        as int,
            isBookmarked:
                null == isBookmarked
                    ? _value.isBookmarked
                    : isBookmarked // ignore: cast_nullable_to_non_nullable
                        as bool,
            bookmarksCount:
                null == bookmarksCount
                    ? _value.bookmarksCount
                    : bookmarksCount // ignore: cast_nullable_to_non_nullable
                        as int,
            planVisibility:
                null == planVisibility
                    ? _value.planVisibility
                    : planVisibility // ignore: cast_nullable_to_non_nullable
                        as String,
            creditsRequired:
                null == creditsRequired
                    ? _value.creditsRequired
                    : creditsRequired // ignore: cast_nullable_to_non_nullable
                        as int,
            totalSlots:
                null == totalSlots
                    ? _value.totalSlots
                    : totalSlots // ignore: cast_nullable_to_non_nullable
                        as int,
            recurrence:
                freezed == recurrence
                    ? _value.recurrence
                    : recurrence // ignore: cast_nullable_to_non_nullable
                        as String?,
            latitude:
                freezed == latitude
                    ? _value.latitude
                    : latitude // ignore: cast_nullable_to_non_nullable
                        as double?,
            longitude:
                freezed == longitude
                    ? _value.longitude
                    : longitude // ignore: cast_nullable_to_non_nullable
                        as double?,
            archived:
                null == archived
                    ? _value.archived
                    : archived // ignore: cast_nullable_to_non_nullable
                        as bool,
            postType:
                null == postType
                    ? _value.postType
                    : postType // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EventModelImplCopyWith<$Res>
    implements $EventModelCopyWith<$Res> {
  factory _$$EventModelImplCopyWith(
    _$EventModelImpl value,
    $Res Function(_$EventModelImpl) then,
  ) = __$$EventModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    DateTime startDate,
    DateTime? endDate,
    bool isAllDay,
    String location,
    double price,
    String imageUrl,
    String organizerId,
    int likes,
    int views,
    bool isBookmarked,
    int bookmarksCount,
    String planVisibility,
    int creditsRequired,
    int totalSlots,
    String? recurrence,
    double? latitude,
    double? longitude,
    bool archived,
    String postType,
  });
}

/// @nodoc
class __$$EventModelImplCopyWithImpl<$Res>
    extends _$EventModelCopyWithImpl<$Res, _$EventModelImpl>
    implements _$$EventModelImplCopyWith<$Res> {
  __$$EventModelImplCopyWithImpl(
    _$EventModelImpl _value,
    $Res Function(_$EventModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EventModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? isAllDay = null,
    Object? location = null,
    Object? price = null,
    Object? imageUrl = null,
    Object? organizerId = null,
    Object? likes = null,
    Object? views = null,
    Object? isBookmarked = null,
    Object? bookmarksCount = null,
    Object? planVisibility = null,
    Object? creditsRequired = null,
    Object? totalSlots = null,
    Object? recurrence = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? archived = null,
    Object? postType = null,
  }) {
    return _then(
      _$EventModelImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        title:
            null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                    as String,
        description:
            null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String,
        startDate:
            null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        endDate:
            freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        isAllDay:
            null == isAllDay
                ? _value.isAllDay
                : isAllDay // ignore: cast_nullable_to_non_nullable
                    as bool,
        location:
            null == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                    as String,
        price:
            null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                    as double,
        imageUrl:
            null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                    as String,
        organizerId:
            null == organizerId
                ? _value.organizerId
                : organizerId // ignore: cast_nullable_to_non_nullable
                    as String,
        likes:
            null == likes
                ? _value.likes
                : likes // ignore: cast_nullable_to_non_nullable
                    as int,
        views:
            null == views
                ? _value.views
                : views // ignore: cast_nullable_to_non_nullable
                    as int,
        isBookmarked:
            null == isBookmarked
                ? _value.isBookmarked
                : isBookmarked // ignore: cast_nullable_to_non_nullable
                    as bool,
        bookmarksCount:
            null == bookmarksCount
                ? _value.bookmarksCount
                : bookmarksCount // ignore: cast_nullable_to_non_nullable
                    as int,
        planVisibility:
            null == planVisibility
                ? _value.planVisibility
                : planVisibility // ignore: cast_nullable_to_non_nullable
                    as String,
        creditsRequired:
            null == creditsRequired
                ? _value.creditsRequired
                : creditsRequired // ignore: cast_nullable_to_non_nullable
                    as int,
        totalSlots:
            null == totalSlots
                ? _value.totalSlots
                : totalSlots // ignore: cast_nullable_to_non_nullable
                    as int,
        recurrence:
            freezed == recurrence
                ? _value.recurrence
                : recurrence // ignore: cast_nullable_to_non_nullable
                    as String?,
        latitude:
            freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                    as double?,
        longitude:
            freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                    as double?,
        archived:
            null == archived
                ? _value.archived
                : archived // ignore: cast_nullable_to_non_nullable
                    as bool,
        postType:
            null == postType
                ? _value.postType
                : postType // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EventModelImpl implements _EventModel {
  const _$EventModelImpl({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    this.endDate,
    this.isAllDay = false,
    required this.location,
    required this.price,
    required this.imageUrl,
    required this.organizerId,
    this.likes = 0,
    this.views = 0,
    this.isBookmarked = false,
    this.bookmarksCount = 0,
    this.planVisibility = 'public',
    this.creditsRequired = 0,
    this.totalSlots = 0,
    this.recurrence,
    this.latitude,
    this.longitude,
    this.archived = false,
    this.postType = 'event',
  });

  factory _$EventModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final DateTime startDate;
  @override
  final DateTime? endDate;
  @override
  @JsonKey()
  final bool isAllDay;
  @override
  final String location;
  @override
  final double price;
  @override
  final String imageUrl;
  @override
  final String organizerId;
  @override
  @JsonKey()
  final int likes;
  @override
  @JsonKey()
  final int views;
  @override
  @JsonKey()
  final bool isBookmarked;
  @override
  @JsonKey()
  final int bookmarksCount;
  @override
  @JsonKey()
  final String planVisibility;
  // 'public', 'private'
  @override
  @JsonKey()
  final int creditsRequired;
  @override
  @JsonKey()
  final int totalSlots;
  @override
  final String? recurrence;
  // 'none', 'daily', 'weekly', 'monthly'
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  @JsonKey()
  final bool archived;
  @override
  @JsonKey()
  final String postType;

  @override
  String toString() {
    return 'EventModel(id: $id, title: $title, description: $description, startDate: $startDate, endDate: $endDate, isAllDay: $isAllDay, location: $location, price: $price, imageUrl: $imageUrl, organizerId: $organizerId, likes: $likes, views: $views, isBookmarked: $isBookmarked, bookmarksCount: $bookmarksCount, planVisibility: $planVisibility, creditsRequired: $creditsRequired, totalSlots: $totalSlots, recurrence: $recurrence, latitude: $latitude, longitude: $longitude, archived: $archived, postType: $postType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.isAllDay, isAllDay) ||
                other.isAllDay == isAllDay) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.organizerId, organizerId) ||
                other.organizerId == organizerId) &&
            (identical(other.likes, likes) || other.likes == likes) &&
            (identical(other.views, views) || other.views == views) &&
            (identical(other.isBookmarked, isBookmarked) ||
                other.isBookmarked == isBookmarked) &&
            (identical(other.bookmarksCount, bookmarksCount) ||
                other.bookmarksCount == bookmarksCount) &&
            (identical(other.planVisibility, planVisibility) ||
                other.planVisibility == planVisibility) &&
            (identical(other.creditsRequired, creditsRequired) ||
                other.creditsRequired == creditsRequired) &&
            (identical(other.totalSlots, totalSlots) ||
                other.totalSlots == totalSlots) &&
            (identical(other.recurrence, recurrence) ||
                other.recurrence == recurrence) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.archived, archived) ||
                other.archived == archived) &&
            (identical(other.postType, postType) ||
                other.postType == postType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    title,
    description,
    startDate,
    endDate,
    isAllDay,
    location,
    price,
    imageUrl,
    organizerId,
    likes,
    views,
    isBookmarked,
    bookmarksCount,
    planVisibility,
    creditsRequired,
    totalSlots,
    recurrence,
    latitude,
    longitude,
    archived,
    postType,
  ]);

  /// Create a copy of EventModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventModelImplCopyWith<_$EventModelImpl> get copyWith =>
      __$$EventModelImplCopyWithImpl<_$EventModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventModelImplToJson(this);
  }
}

abstract class _EventModel implements EventModel {
  const factory _EventModel({
    required final String id,
    required final String title,
    required final String description,
    required final DateTime startDate,
    final DateTime? endDate,
    final bool isAllDay,
    required final String location,
    required final double price,
    required final String imageUrl,
    required final String organizerId,
    final int likes,
    final int views,
    final bool isBookmarked,
    final int bookmarksCount,
    final String planVisibility,
    final int creditsRequired,
    final int totalSlots,
    final String? recurrence,
    final double? latitude,
    final double? longitude,
    final bool archived,
    final String postType,
  }) = _$EventModelImpl;

  factory _EventModel.fromJson(Map<String, dynamic> json) =
      _$EventModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  DateTime get startDate;
  @override
  DateTime? get endDate;
  @override
  bool get isAllDay;
  @override
  String get location;
  @override
  double get price;
  @override
  String get imageUrl;
  @override
  String get organizerId;
  @override
  int get likes;
  @override
  int get views;
  @override
  bool get isBookmarked;
  @override
  int get bookmarksCount;
  @override
  String get planVisibility; // 'public', 'private'
  @override
  int get creditsRequired;
  @override
  int get totalSlots;
  @override
  String? get recurrence; // 'none', 'daily', 'weekly', 'monthly'
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  bool get archived;
  @override
  String get postType;

  /// Create a copy of EventModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventModelImplCopyWith<_$EventModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
