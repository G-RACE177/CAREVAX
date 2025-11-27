import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// SMSService supports both the JSON bulk API and the HTTP/plain API.
/// Callers can choose which method to use. This service is configured
/// for production endpoints.
class SMSService {
  final String username = 'BBMI';
  final String password = 'asimblack256';
  final String senderId = 'BBMI';

  String get _jsonEndpoint => 'https://www.egosms.co/api/v1/json/';
  String get _plainEndpoint => 'https://www.egosms.co/api/v1/plain/';

  /// Sends using the JSON bulk API. This supports multiple messages in one
  /// request and is recommended for bulk sending.
  Future<Map<String, dynamic>> sendViaJson({
    required String message,
    required List<String> recipients,
    String priority = '0',
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final List<Map<String, String>> msgData = recipients.map((number) {
      return {
        'number': number,
        'message': message,
        'senderid': senderId,
        'priority': priority,
      };
    }).toList();

    final requestBody = {
      'method': 'SendSms',
      'userdata': {'username': username, 'password': password},
      'msgdata': msgData,
    };

    try {
      final uri = Uri.parse(_jsonEndpoint);
      print('JSON send -> POST $uri');
      final response = await http
          .post(uri,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: json.encode(requestBody))
          .timeout(timeout);

      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      }

      return {
        'success': false,
        'error': 'HTTP ${response.statusCode}: ${response.body}'
      };
    } on SocketException catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    } on FormatException catch (e) {
      return {'success': false, 'error': 'Invalid JSON response: $e'};
    } catch (e) {
      return {'success': false, 'error': 'Exception: $e'};
    }
  }

  /// Sends using the HTTP/plain API. Typically single-recipient per
  /// request (but supports comma-separated lists on some endpoints).
  Future<Map<String, dynamic>> sendViaPlain({
    required String message,
    required List<String> recipients,
    String priority = '0',
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final String numbers = recipients.join(',');

    final Map<String, String> params = {
      'username': username,
      'password': password,
      'number': numbers,
      'message': message,
      'sender': senderId,
      'priority': priority,
    };

    try {
      final uri = Uri.parse(_plainEndpoint);
      print('Plain send -> POST $uri');
      final response = await http
          .post(uri, headers: {'Content-Type': 'application/x-www-form-urlencoded'}, body: params)
          .timeout(timeout);

      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final body = response.body.toLowerCase();
        if (body.contains('ok') || body.contains('success')) {
          return {'success': true, 'data': response.body};
        }
        return {'success': false, 'error': 'API response: ${response.body}'};
      }

      return {
        'success': false,
        'error': 'HTTP ${response.statusCode}: ${response.body}'
      };
    } on SocketException catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    } catch (e) {
      return {'success': false, 'error': 'Exception: $e'};
    }
  }

  /// Convenience method: choose method by name: 'json' | 'plain'
  Future<Map<String, dynamic>> sendBulkSMS({
    required String message,
    required List<String> recipients,
    String method = 'json', // 'json' or 'plain'
    String priority = '0',
  }) async {
    if (method == 'plain') {
      return await sendViaPlain(message: message, recipients: recipients, priority: priority);
    }
    return await sendViaJson(message: message, recipients: recipients, priority: priority);
  }
}
