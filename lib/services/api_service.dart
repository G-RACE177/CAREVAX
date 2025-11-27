import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  Future<List<Map<String, dynamic>>> getFollowups() async {
    final uri = Uri.parse(followupsEndpoint());
    final resp = await http.get(uri).timeout(const Duration(seconds: 10));
    if (resp.statusCode == 200) {
      final List<dynamic> data = jsonDecode(resp.body);
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    throw Exception('Failed to fetch followups: HTTP ${resp.statusCode}');
  }

  Future<List<Map<String, dynamic>>> getHouseholds() async {
    final uri = Uri.parse(householdsEndpoint());
    final resp = await http.get(uri).timeout(const Duration(seconds: 10));
    if (resp.statusCode == 200) {
      final List<dynamic> data = jsonDecode(resp.body);
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    throw Exception('Failed to fetch households: HTTP ${resp.statusCode}');
  }

  Future<List<Map<String, dynamic>>> getChildren() async {
    final uri = Uri.parse(childrenEndpoint());
    final resp = await http.get(uri).timeout(const Duration(seconds: 10));
    if (resp.statusCode == 200) {
      final List<dynamic> data = jsonDecode(resp.body);
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    throw Exception('Failed to fetch children: HTTP ${resp.statusCode}');
  }

  /// Example: post a followup assignment to the legacy PHP backend.
  Future<bool> postFollowup(Map<String, dynamic> payload) async {
    final uri = Uri.parse(followupsEndpoint());
    final resp = await http.post(uri, body: payload).timeout(const Duration(seconds: 10));
    return resp.statusCode == 200 || resp.statusCode == 201;
  }
}
