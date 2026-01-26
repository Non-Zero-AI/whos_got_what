import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:whos_got_what/shared/widgets/neumorphic_container.dart';
import 'package:whos_got_what/shared/widgets/neumorphic_text_field.dart';
import 'package:whos_got_what/shared/widgets/raised_button.dart';
import 'package:whos_got_what/core/theme/text_styles.dart';
import 'package:whos_got_what/features/feedback/data/feedback_service.dart';

enum FeedbackSubject {
  general('General Feedback'),
  bugReport('Bug Report'),
  billingIssue('Billing Issue'),
  featureRequest('Feature Request'),
  other('Other');

  const FeedbackSubject(this.label);
  final String label;
}

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final _subjectController = TextEditingController();

  FeedbackSubject? _selectedSubject;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate() || _selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a subject and fill all fields'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FeedbackService.sendFeedback(
        userEmail: _emailController.text.trim(),
        subject:
            _subjectController.text.trim().isEmpty
                ? _selectedSubject!.label
                : _subjectController.text.trim(),
        message: _messageController.text.trim(),
        feedbackType: _selectedSubject!.label,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for your feedback!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sending feedback: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Feedback'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject Selection
              Text(
                'Subject',
                style: AppTextStyles.labelSecondary(
                  context,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              NeumorphicContainer(
                borderRadius: BorderRadius.circular(16),
                padding: const EdgeInsets.all(4),
                child: Column(
                  children:
                      FeedbackSubject.values.map((subject) {
                        final isSelected = _selectedSubject == subject;
                        return NeumorphicContainer(
                          borderRadius: BorderRadius.circular(12),
                          margin: const EdgeInsets.all(2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          onTap:
                              () => setState(() => _selectedSubject = subject),
                          surfaceColor:
                              isSelected
                                  ? colorScheme.primary.withValues(alpha: 0.1)
                                  : null,
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color:
                                    isSelected
                                        ? colorScheme.primary
                                        : colorScheme.onSurface.withValues(
                                          alpha: 0.6,
                                        ),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  subject.label,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color:
                                        isSelected
                                            ? colorScheme.primary
                                            : colorScheme.onSurface,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Email Field
              Text(
                'Your Email',
                style: AppTextStyles.labelSecondary(
                  context,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              NeumorphicTextField(
                controller: _emailController,
                hintText: 'Enter your email address',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Subject Details (optional)
              Text(
                'Subject Details',
                style: AppTextStyles.labelSecondary(
                  context,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              NeumorphicTextField(
                controller: _subjectController,
                hintText: 'Brief subject line (optional)',
                maxLength: 100,
              ),
              const SizedBox(height: 24),

              // Message Field
              Text(
                'Message',
                style: AppTextStyles.labelSecondary(
                  context,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              NeumorphicTextField(
                controller: _messageController,
                hintText: 'Tell us more about your feedback...',
                maxLines: 6,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your message';
                  }
                  if (value.trim().length < 10) {
                    return 'Message must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: RaisedButton(
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  child:
                      _isSubmitting
                          ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.onPrimary,
                              ),
                            ),
                          )
                          : Text('Send Feedback'),
                ),
              ),
              const SizedBox(height: 16),

              // Info Text
              Text(
                'We value your feedback and will review your message as soon as possible.',
                style: AppTextStyles.labelSecondary(
                  context,
                ).copyWith(fontSize: 12, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
