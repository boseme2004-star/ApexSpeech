import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/api';
  // Use 10.0.2.2 for Android emulator
  // Use your actual IP for physical device e.g. http://192.168.1.100:8080/api

  static const Duration timeout = Duration(seconds: 10);

  // ── Headers ──
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
      };

  // ══════════════════════════════════════════
  // USER ENDPOINTS
  // ══════════════════════════════════════════

  // Register
  static Future<Map<String, dynamic>?> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/users/register'),
            headers: headers,
            body: jsonEncode({
              'username': username,
              'email': email,
              'passwordHash': password,
            }),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      print('REGISTER ERROR: ${response.body}');
      return null;
    } catch (e) {
      print('REGISTER EXCEPTION: $e');
      return null;
    }
  }

  // Login
  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/users/login'),
            headers: headers,
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      print('LOGIN ERROR: ${response.body}');
      return null;
    } catch (e) {
      print('LOGIN EXCEPTION: $e');
      return null;
    }
  }

  // Get user by ID
  static Future<Map<String, dynamic>?> getUser(int userId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/users/$userId'), headers: headers)
          .timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('GET USER EXCEPTION: $e');
      return null;
    }
  }

  // Update user
  static Future<bool> updateUser(
      int userId, Map<String, dynamic> data) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/users/$userId'),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(timeout);
      return response.statusCode == 200;
    } catch (e) {
      print('UPDATE USER EXCEPTION: $e');
      return false;
    }
  }

  // ══════════════════════════════════════════
  // TRANSCRIPTION ENDPOINTS
  // ══════════════════════════════════════════

  // Save transcription
  static Future<Map<String, dynamic>?> saveTranscription({
    required int userId,
    required String transcript,
    required int wordCount,
    required int fillerWordCount,
    required int repeatedWordCount,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/transcriptions'),
            headers: headers,
            body: jsonEncode({
              'userId': userId,
              'transcript': transcript,
              'wordCount': wordCount,
              'fillerWordCount': fillerWordCount,
              'repeatedWordCount': repeatedWordCount,
            }),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      print('SAVE TRANSCRIPTION ERROR: ${response.body}');
      return null;
    } catch (e) {
      print('SAVE TRANSCRIPTION EXCEPTION: $e');
      return null;
    }
  }

  // Get all transcriptions for user
  static Future<List<Map<String, dynamic>>> getTranscriptions(
      int userId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/transcriptions/user/$userId'),
            headers: headers,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('GET TRANSCRIPTIONS EXCEPTION: $e');
      return [];
    }
  }

  // Get single transcription
  static Future<Map<String, dynamic>?> getTranscription(
      int transcriptionId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/transcriptions/$transcriptionId'),
            headers: headers,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('GET TRANSCRIPTION EXCEPTION: $e');
      return null;
    }
  }

  // Update transcription
  static Future<bool> updateTranscription(
      int id, Map<String, dynamic> data) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/transcriptions/$id'),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(timeout);
      return response.statusCode == 200;
    } catch (e) {
      print('UPDATE TRANSCRIPTION EXCEPTION: $e');
      return false;
    }
  }

  // Delete transcription
  static Future<bool> deleteTranscription(int id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/transcriptions/$id'),
            headers: headers,
          )
          .timeout(timeout);
      return response.statusCode == 200;
    } catch (e) {
      print('DELETE TRANSCRIPTION EXCEPTION: $e');
      return false;
    }
  }

  // ══════════════════════════════════════════
  // AI FEEDBACK ENDPOINTS
  // ══════════════════════════════════════════

  // Save feedback
  static Future<Map<String, dynamic>?> saveFeedback({
    required int transcriptionId,
    required double overallScore,
    required double clarityScore,
    required double grammarScore,
    required double confidenceScore,
    required String strengths,
    required String improvements,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/feedback'),
            headers: headers,
            body: jsonEncode({
              'transcriptionId': transcriptionId,
              'overallScore': overallScore,
              'clarityScore': clarityScore,
              'grammarScore': grammarScore,
              'confidenceScore': confidenceScore,
              'strengths': strengths,
              'improvements': improvements,
            }),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      print('SAVE FEEDBACK ERROR: ${response.body}');
      return null;
    } catch (e) {
      print('SAVE FEEDBACK EXCEPTION: $e');
      return null;
    }
  }

  // Get feedback for transcription
  static Future<Map<String, dynamic>?> getFeedback(
      int transcriptionId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/feedback/$transcriptionId'),
            headers: headers,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('GET FEEDBACK EXCEPTION: $e');
      return null;
    }
  }

  // ══════════════════════════════════════════
  // UTILITY
  // ══════════════════════════════════════════

  // Check if API is reachable
  static Future<bool> isOnline() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/transcriptions/user/0'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode != 500;
    } catch (e) {
      return false;
    }
  }
}