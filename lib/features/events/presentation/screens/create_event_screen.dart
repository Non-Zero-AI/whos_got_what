import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whos_got_what/features/auth/data/auth_providers.dart';
import 'package:whos_got_what/features/events/data/event_repository_impl.dart';
import 'package:whos_got_what/features/events/data/user_events_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:whos_got_what/features/notifications/data/notification_repository.dart';
import 'package:whos_got_what/features/profile/data/profile_providers.dart';
import 'package:whos_got_what/shared/widgets/neumorphic_text_field.dart';
import 'package:whos_got_what/shared/widgets/neumorphic_container.dart';
import 'package:whos_got_what/shared/widgets/address_autocomplete_field.dart';
import 'package:whos_got_what/core/theme/text_styles.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  final String? eventId;

  const CreateEventScreen({super.key, this.eventId});

  bool get isEditing => eventId != null;

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _ticketUrlController = TextEditingController();
  final _linkUrlController = TextEditingController();

  DateTime _startDate = DateTime.now().add(const Duration(hours: 1));
  DateTime? _endDate;
  bool _isAllDay = false;

  File? _selectedImageFile;
  bool _isUploadingImage = false;
  String _postType = 'event'; // 'event' or 'promotion'

  bool _isLoadingEvent = false;
  String? _existingImageUrl; // For edit mode - keep track of existing image

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadExistingEvent();
    }
  }

  Future<void> _loadExistingEvent() async {
    if (widget.eventId == null) return;

    setState(() => _isLoadingEvent = true);

    try {
      final repo = ref.read(eventRepositoryProvider);
      final event = await repo.getEventById(widget.eventId!);

      if (event != null && mounted) {
        setState(() {
          _titleController.text = event.title;
          _descriptionController.text = event.description;
          _locationController.text = event.location;
          _startDate = event.startDate;
          _endDate = event.endDate;
          _isAllDay = event.isAllDay;
          _existingImageUrl = event.imageUrl;
          _postType = event.postType;
          // Note: ticketUrl and linkUrl are not in EventModel, so we can't pre-fill them
          // They would need to be added to the model if needed
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load event: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingEvent = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _ticketUrlController.dispose();
    _linkUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;

    if (!mounted) return;

    setState(() {
      _selectedImageFile = File(picked.path);
    });
  }

  void _removeImage() {
    setState(() {
      _selectedImageFile = null;
    });
  }

  Future<void> _pickStartDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startDate),
    );
    if (time == null || !mounted) return;

    setState(() {
      _startDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _pickEndDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime:
          _endDate != null
              ? TimeOfDay.fromDateTime(_endDate!)
              : TimeOfDay.fromDateTime(
                _startDate.add(const Duration(hours: 1)),
              ),
    );
    if (time == null || !mounted) return;

    setState(() {
      _endDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<String?> _uploadEventImage({required String userId}) async {
    if (_selectedImageFile == null) return null;

    setState(() => _isUploadingImage = true);

    try {
      final fileExt = _selectedImageFile!.path.split('.').last;
      final fileName =
          '$userId/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // NOTE: Make sure you create this bucket in Supabase Storage.
      const bucketName = 'event-images';

      await Supabase.instance.client.storage
          .from(bucketName)
          .upload(
            fileName,
            _selectedImageFile!,
            fileOptions: const FileOptions(upsert: true),
          );

      return Supabase.instance.client.storage
          .from(bucketName)
          .getPublicUrl(fileName);
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  /// Send push notifications to users subscribed to this creator's notifications
  Future<void> _notifySubscribers({
    required String creatorId,
    required String eventId,
    required String eventTitle,
  }) async {
    try {
      // Get creator's display name for the notification
      final profile = await ref.read(profileProvider(creatorId).future);
      final creatorName = profile?.displayName ?? 'Someone you follow';

      // Trigger notification via Supabase Edge Function
      final notificationRepo = ref.read(notificationRepositoryProvider);
      await notificationRepo.notifySubscribersOfNewEvent(
        creatorId: creatorId,
        eventId: eventId,
        eventTitle: eventTitle,
        creatorName: creatorName,
      );
    } catch (e) {
      // Don't fail the event creation if notification fails
      debugPrint('Failed to send notifications: $e');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider);

    if (user == null) {
      // ... sign up dialog code stays same ...
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Sign up required'),
            content: const Text(
              'You need an account to create events. Please sign up or sign in to continue.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/auth');
                },
                child: const Text('Create account'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Show loading indicator
    setState(() => _isUploadingImage = true);

    try {
      // Determine image URL
      String? imageUrl;

      if (_selectedImageFile != null) {
        // User selected a new image - upload it
        final uploaded = await _uploadEventImage(userId: user.id);
        imageUrl = uploaded;
      } else if (widget.isEditing && _existingImageUrl != null) {
        // Keep existing image when editing
        imageUrl = _existingImageUrl;
      }

      // Default placeholder if no image
      imageUrl ??= 'https://placehold.co/1000x800/png?text=Event';

      final startTime = _startDate;
      DateTime endTime;
      if (_isAllDay) {
        endTime = DateTime(
          startTime.year,
          startTime.month,
          startTime.day,
          23,
          59,
        );
      } else {
        endTime = _endDate ?? startTime.add(const Duration(hours: 1));
      }

      final repo = ref.read(eventRepositoryProvider);

      if (widget.isEditing) {
        await repo.updateEvent(widget.eventId!, {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
          'is_all_day': _isAllDay,
          'image_url': imageUrl,
          'location': _locationController.text.trim(),
          'ticket_url': _ticketUrlController.text.trim(),
          'link_url': _linkUrlController.text.trim(),
          'post_type': _postType,
        });
      } else {
        final newEvent = await repo.createEvent(
          creatorId: user.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          startTime: startTime,
          endTime: endTime,
          isAllDay: _isAllDay,
          imageUrl: imageUrl,
          location: _locationController.text.trim(),
          price: 0.0,
          ticketUrl: _ticketUrlController.text.trim(),
          linkUrl: _linkUrlController.text.trim(),
          postType: _postType,
        );

        _notifySubscribers(
          creatorId: user.id,
          eventId: newEvent.id,
          eventTitle: newEvent.title,
        );
      }

      // Refresh providers
      ref.invalidate(eventsProvider);
      ref.invalidate(userEventsProvider);
      if (widget.isEditing) {
        ref.invalidate(eventByIdProvider(widget.eventId!));
        // Force a refresh of the user events by ID to ensure the list updates immediately
        ref.invalidate(userEventsByIdProvider(user.id));
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditing ? 'Event updated.' : 'Event saved.'),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingImage = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  Widget _buildPostTypeToggle(ThemeData theme) {
    // Colors for the toggle
    const eventPurple = Color(0xFF7C3AED);
    const eventPurpleLight = Color(0xFFE0D4FF);
    const promoPurple = Color(0xFFFF6B35);
    const promoOrangeLight = Color(0xFFFFD4C4);

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _postType = 'event'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient:
                    _postType == 'event'
                        ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            eventPurple.withValues(alpha: 0.95),
                            eventPurple.withValues(alpha: 0.85),
                          ],
                        )
                        : null,
                color: _postType == 'event' ? null : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      _postType == 'event'
                          ? eventPurpleLight.withValues(alpha: 0.3)
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow:
                    _postType == 'event'
                        ? [
                          BoxShadow(
                            color: eventPurple.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : null,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.event_rounded,
                    size: 28,
                    color:
                        _postType == 'event'
                            ? eventPurpleLight
                            : theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Event',
                    style: TextStyle(
                      color:
                          _postType == 'event'
                              ? eventPurpleLight
                              : theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _postType = 'promotion'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient:
                    _postType == 'promotion'
                        ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            promoPurple.withValues(alpha: 0.95),
                            promoPurple.withValues(alpha: 0.85),
                          ],
                        )
                        : null,
                color:
                    _postType == 'promotion' ? null : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      _postType == 'promotion'
                          ? promoOrangeLight.withValues(alpha: 0.3)
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow:
                    _postType == 'promotion'
                        ? [
                          BoxShadow(
                            color: promoPurple.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : null,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.local_offer_rounded,
                    size: 28,
                    color:
                        _postType == 'promotion'
                            ? promoOrangeLight
                            : theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Promotion',
                    style: TextStyle(
                      color:
                          _postType == 'promotion'
                              ? promoOrangeLight
                              : theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('EEE, MMM d, y • h:mm a');
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Event' : 'Create Event',
          style: AppTextStyles.titleLarge(context),
        ),
      ),
      body:
          _isLoadingEvent
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Post Type Toggle (Event vs Promotion)
                        Text(
                          'What are you posting?',
                          style: AppTextStyles.titleMedium(context),
                        ),
                        const SizedBox(height: 12),
                        _buildPostTypeToggle(theme),
                        const SizedBox(height: 24),

                        NeumorphicTextField(
                          controller: _titleController,
                          hintText:
                              _postType == 'promotion'
                                  ? 'Enter promotion name'
                                  : 'Enter event name',
                          labelText:
                              _postType == 'promotion'
                                  ? 'Promotion name'
                                  : 'Event name',
                          validator:
                              (v) =>
                                  v == null || v.trim().isEmpty
                                      ? 'Please enter a name'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        NeumorphicTextField(
                          controller: _descriptionController,
                          hintText: 'Enter event details',
                          labelText: 'Details',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        AddressAutocompleteField(
                          controller: _locationController,
                          hintText: 'Enter address or place name',
                          labelText: 'Location',
                        ),
                        const SizedBox(height: 20),
                        NeumorphicContainer(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _isAllDay,
                                onChanged: (v) {
                                  setState(() {
                                    _isAllDay = v ?? false;
                                    if (_isAllDay) _endDate = null;
                                  });
                                },
                              ),
                              Text(
                                'All day event',
                                style: AppTextStyles.body(context),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        NeumorphicContainer(
                          padding: const EdgeInsets.all(16),
                          onTap: _pickStartDateTime,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Start',
                                    style: AppTextStyles.labelSecondary(
                                      context,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dateFormatter.format(_startDate),
                                    style: AppTextStyles.body(context),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.edit_calendar_outlined,
                                color: theme.colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                        if (!_isAllDay) ...[
                          const SizedBox(height: 12),
                          NeumorphicContainer(
                            padding: const EdgeInsets.all(16),
                            onTap: _pickEndDateTime,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'End',
                                      style: AppTextStyles.labelSecondary(
                                        context,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _endDate == null
                                          ? 'Select end date & time'
                                          : dateFormatter.format(_endDate!),
                                      style: AppTextStyles.body(context),
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.edit_calendar_outlined,
                                  color: theme.colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        NeumorphicTextField(
                          controller: _ticketUrlController,
                          hintText: 'Enter ticket purchase URL',
                          labelText: 'Ticket purchase URL',
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: 16),
                        NeumorphicTextField(
                          controller: _linkUrlController,
                          hintText: 'Enter event website URL',
                          labelText: 'Event website / info URL',
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Event Image',
                          style: AppTextStyles.titleMedium(context),
                        ),
                        const SizedBox(height: 12),
                        NeumorphicContainer(
                          padding: EdgeInsets.zero,
                          onTap: _isUploadingImage ? null : _pickImage,
                          child: Stack(
                            children: [
                              Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image:
                                      _selectedImageFile != null
                                          ? DecorationImage(
                                            image: FileImage(
                                              _selectedImageFile!,
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                          : (_existingImageUrl != null
                                              ? DecorationImage(
                                                image: NetworkImage(
                                                  _existingImageUrl!,
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                              : null),
                                ),
                                child:
                                    _selectedImageFile == null &&
                                            _existingImageUrl == null
                                        ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons
                                                  .add_photo_alternate_outlined,
                                              size: 40,
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.6),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Tap to upload image',
                                              style: AppTextStyles.captionMuted(
                                                context,
                                              ),
                                            ),
                                          ],
                                        )
                                        : null,
                              ),
                              if (_selectedImageFile != null ||
                                  _existingImageUrl != null)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: NeumorphicContainer(
                                    padding: EdgeInsets.zero,
                                    borderRadius: BorderRadius.circular(20),
                                    width: 32,
                                    height: 32,
                                    onTap: () {
                                      setState(() {
                                        _selectedImageFile = null;
                                        _existingImageUrl = null;
                                      });
                                    },
                                    child: Icon(
                                      Icons.close,
                                      color: theme.colorScheme.onSurface,
                                      size: 18,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (_isUploadingImage)
                          const Padding(
                            padding: EdgeInsets.only(top: 16.0),
                            child: LinearProgressIndicator(),
                          ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isUploadingImage ? null : _submit,
                            child: Text(
                              _isUploadingImage
                                  ? 'Uploading...'
                                  : (widget.isEditing
                                      ? 'Update Event'
                                      : 'Save Event'),
                              style: AppTextStyles.labelPrimary(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
