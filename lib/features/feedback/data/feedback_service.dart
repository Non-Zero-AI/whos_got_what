import 'dart:convert';
import 'package:http/http.dart' as http;

class FeedbackService {
  static const String _webhookUrl =
      'https://n8n.srv1023211.hstgr.cloud/webhook/userfeedback';
  static const String _appSecret =
      'wGW_2025_Feedback_Secret'; // This should be stored securely

  static Future<void> sendFeedback({
    required String userEmail,
    required String subject,
    required String message,
    required String feedbackType,
  }) async {
    try {
      final payload = {
        'username': userEmail,
        'subject': subject,
        'message': message,
        'feedbackType': feedbackType,
        'timestamp': DateTime.now().toIso8601String(),
        'source': 'streetside_local_app',
        'auth': _appSecret, // Simple authentication to verify source
      };

      final response = await http.post(
        Uri.parse(_webhookUrl),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'StreetsideLocal/1.0',
          'X-App-Auth': _appSecret, // Additional header for authentication
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Webhook failed with status: ${response.statusCode}, body: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to send feedback: $e');
    }
  }
}
