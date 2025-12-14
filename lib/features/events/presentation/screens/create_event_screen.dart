import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whos_got_what/features/auth/data/auth_providers.dart';
import 'package:whos_got_what/features/events/data/event_repository_impl.dart';
import 'package:whos_got_what/features/events/data/user_events_provider.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

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
      _startDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
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
      initialTime: _endDate != null
          ? TimeOfDay.fromDateTime(_endDate!)
          : TimeOfDay.fromDateTime(_startDate.add(const Duration(hours: 1))),
    );
    if (time == null || !mounted) return;

    setState(() {
      _endDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<String?> _uploadEventImage({required String userId}) async {
    if (_selectedImageFile == null) return null;

    setState(() => _isUploadingImage = true);

    try {
      final fileExt = _selectedImageFile!.path.split('.').last;
      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

  // NOTE: Make sure you create this bucket in Supabase Storage.
  const bucketName = 'event-images';

      await Supabase.instance.client.storage.from(bucketName).upload(
            fileName,
            _selectedImageFile!,
            fileOptions: const FileOptions(upsert: true),
          );

      return Supabase.instance.client.storage.from(bucketName).getPublicUrl(fileName);
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider);

    // Require an account to create events
    if (user == null) {
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
                  // Go to auth screen
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

    // Default image if user skips upload
    var imageUrl =
        'https://placehold.co/1000x800/png?text=Event';

    if (_selectedImageFile != null) {
      try {
        final uploaded = await _uploadEventImage(userId: user.id);
        if (uploaded != null) imageUrl = uploaded;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image upload failed: $e')),
          );
        }
        return;
      }
    }

    final startTime = _startDate;

    DateTime endTime;
    if (_isAllDay) {
      // Supabase schema requires end_time; for all-day treat as end-of-day.
      endTime = DateTime(startTime.year, startTime.month, startTime.day, 23, 59);
    } else {
      endTime = _endDate ?? startTime.add(const Duration(hours: 1));
    }

    try {
      final repo = ref.read(eventRepositoryProvider);
      await repo.createEvent(
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
      );

      // Refresh feeds
      ref.invalidate(eventsProvider);
      ref.invalidate(userEventsProvider);
    } on PostgrestException catch (e) {
      if (!mounted) return;
      final msg = e.message.toLowerCase();
      final isRls = msg.contains('row-level security') || msg.contains('rls') || msg.contains('permission');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRls
                ? 'Event not saved: your account is not permitted to create events yet.'
                : 'Event save failed: ${e.message}',
          ),
        ),
      );
      return;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event save failed: $e')),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event saved.')),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('EEE, MMM d, y • h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Event name'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Details'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                const SizedBox(height: 16),
                Row(
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
                    const Text('All day event'),
                  ],
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Start'),
                  subtitle: Text(dateFormatter.format(_startDate)),
                  trailing: const Icon(Icons.edit_calendar_outlined),
                  onTap: _pickStartDateTime,
                ),
                if (!_isAllDay)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('End'),
                    subtitle: Text(
                      _endDate == null ? 'Select end date & time' : dateFormatter.format(_endDate!),
                    ),
                    trailing: const Icon(Icons.edit_calendar_outlined),
                    onTap: _pickEndDateTime,
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ticketUrlController,
                  decoration: const InputDecoration(labelText: 'Ticket purchase URL'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _linkUrlController,
                  decoration: const InputDecoration(labelText: 'Event website / info URL'),
                ),

                const SizedBox(height: 24),
                const Text('Event Image', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    GestureDetector(
                      onTap: _isUploadingImage ? null : _pickImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          image: _selectedImageFile != null
                              ? DecorationImage(
                                  image: FileImage(_selectedImageFile!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _selectedImageFile == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add_photo_alternate_outlined, size: 40),
                                  SizedBox(height: 8),
                                  Text('Tap to upload image'),
                                ],
                              )
                            : null,
                      ),
                    ),
                    if (_selectedImageFile != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _removeImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                if (_isUploadingImage)
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: LinearProgressIndicator(),
                  ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isUploadingImage ? null : _submit,
                    child: Text(_isUploadingImage ? 'Uploading...' : 'Save Event'),
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
