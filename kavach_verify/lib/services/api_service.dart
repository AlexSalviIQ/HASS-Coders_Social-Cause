import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Change this to your backend URL
  // Android emulator: http://10.0.2.2:8000
  // Web/Desktop: http://localhost:8000
  // Physical device: http://<YOUR_LAN_IP>:8000
  static const String baseUrl = 'http://127.0.0.1:8000';

  static const Duration _timeout = Duration(seconds: 10);

  static Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json',
  };

  // ─── AUTH ───

  static Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/register'),
            headers: _jsonHeaders,
            body: jsonEncode({
              'email': email,
              'username': username,
              'password': password,
            }),
          )
          .timeout(_timeout);
      return jsonDecode(response.body);
    } on TimeoutException {
      return {'status': 'error', 'message': 'Server not reachable (timed out)'};
    } catch (e) {
      return {'status': 'error', 'message': 'Connection failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String emailOrUsername,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/login'),
            headers: _jsonHeaders,
            body: jsonEncode({
              'email_or_username': emailOrUsername,
              'password': password,
            }),
          )
          .timeout(_timeout);
      return jsonDecode(response.body);
    } on TimeoutException {
      return {'status': 'error', 'message': 'Server not reachable (timed out)'};
    } catch (e) {
      return {'status': 'error', 'message': 'Connection failed: $e'};
    }
  }

  // ─── PROFILE ───

  static Future<Map<String, dynamic>> getProfile(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/profile/$userId'))
          .timeout(_timeout);
      return jsonDecode(response.body);
    } on TimeoutException {
      return {'status': 'error', 'message': 'Server not reachable (timed out)'};
    } catch (e) {
      return {'status': 'error', 'message': 'Connection failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? name,
    String? email,
    String? phone,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (phone != null) body['phone'] = phone;
      if (bio != null) body['bio'] = bio;
      if (avatarUrl != null) body['avatar_url'] = avatarUrl;

      final response = await http
          .put(
            Uri.parse('$baseUrl/api/profile/$userId'),
            headers: _jsonHeaders,
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return jsonDecode(response.body);
    } on TimeoutException {
      return {'status': 'error', 'message': 'Server not reachable (timed out)'};
    } catch (e) {
      return {'status': 'error', 'message': 'Connection failed: $e'};
    }
  }

  // ─── DETECTIONS ───

  static Future<Map<String, dynamic>> listDetections({
    String? userId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final params = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      if (userId != null) params['user_id'] = userId;

      final uri = Uri.parse(
        '$baseUrl/api/detections',
      ).replace(queryParameters: params);
      final response = await http.get(uri).timeout(_timeout);
      return jsonDecode(response.body);
    } on TimeoutException {
      return {'status': 'error', 'message': 'Server not reachable (timed out)'};
    } catch (e) {
      return {'status': 'error', 'message': 'Connection failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> getDetection(String detectionId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/detections/$detectionId'))
          .timeout(_timeout);
      return jsonDecode(response.body);
    } on TimeoutException {
      return {'status': 'error', 'message': 'Server not reachable (timed out)'};
    } catch (e) {
      return {'status': 'error', 'message': 'Connection failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> createDetection({
    required String userId,
    required String title,
    required String description,
    String? imageUrl,
    String? location,
    required String category,
    required double confidenceScore,
    required String analysisDetails,
    required bool isFake,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/detections'),
            headers: _jsonHeaders,
            body: jsonEncode({
              'user_id': userId,
              'title': title,
              'description': description,
              'image_url': imageUrl,
              'location': location,
              'category': category,
              'confidence_score': confidenceScore,
              'analysis_details': analysisDetails,
              'is_fake': isFake,
            }),
          )
          .timeout(_timeout);
      return jsonDecode(response.body);
    } on TimeoutException {
      return {'status': 'error', 'message': 'Server not reachable (timed out)'};
    } catch (e) {
      return {'status': 'error', 'message': 'Connection failed: $e'};
    }
  }

  // ─── REPORTS ───

  static Future<Map<String, dynamic>> submitReport({
    required String userId,
    required String description,
    List<String> proofUrls = const [],
    List<String> documentationUrls = const [],
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/reports'),
            headers: _jsonHeaders,
            body: jsonEncode({
              'user_id': userId,
              'description': description,
              'proof_urls': proofUrls,
              'documentation_urls': documentationUrls,
            }),
          )
          .timeout(_timeout);
      return jsonDecode(response.body);
    } on TimeoutException {
      return {'status': 'error', 'message': 'Server not reachable (timed out)'};
    } catch (e) {
      return {'status': 'error', 'message': 'Connection failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> getUserReports(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/reports/$userId'))
          .timeout(_timeout);
      return jsonDecode(response.body);
    } on TimeoutException {
      return {'status': 'error', 'message': 'Server not reachable (timed out)'};
    } catch (e) {
      return {'status': 'error', 'message': 'Connection failed: $e'};
    }
  }

  // ─── FEEDBACK ───

  static Future<Map<String, dynamic>> submitFeedback({
    required String userId,
    required int rating,
    String? message,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/feedback'),
            headers: _jsonHeaders,
            body: jsonEncode({
              'user_id': userId,
              'rating': rating,
              'message': message ?? '',
            }),
          )
          .timeout(_timeout);
      return jsonDecode(response.body);
    } on TimeoutException {
      return {'status': 'error', 'message': 'Server not reachable (timed out)'};
    } catch (e) {
      return {'status': 'error', 'message': 'Connection failed: $e'};
    }
  }

  // ─── CHAT ───

  static Future<Map<String, dynamic>> getChatHistory({
    required String userId,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final params = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      final uri = Uri.parse(
        '$baseUrl/api/chat/history/$userId',
      ).replace(queryParameters: params);
      final response = await http.get(uri).timeout(_timeout);
      return jsonDecode(response.body);
    } on TimeoutException {
      return {'status': 'error', 'message': 'Server not reachable (timed out)'};
    } catch (e) {
      return {'status': 'error', 'message': 'Connection failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> saveChatMessage({
    required String userId,
    required String text,
    required bool isUser,
    String? attachmentPath,
    String? attachmentType,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/chat/message'),
            headers: _jsonHeaders,
            body: jsonEncode({
              'user_id': userId,
              'text': text,
              'is_user': isUser,
              'attachment_path': attachmentPath,
              'attachment_type': attachmentType,
            }),
          )
          .timeout(_timeout);
      return jsonDecode(response.body);
    } on TimeoutException {
      return {'status': 'error', 'message': 'Server not reachable (timed out)'};
    } catch (e) {
      return {'status': 'error', 'message': 'Connection failed: $e'};
    }
  }

  // ─── VERIFY (AI Analysis) ───

  static Future<Map<String, dynamic>> verify({
    String? claimText,
    String? filePath,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/verify'),
      );

      if (claimText != null && claimText.isNotEmpty) {
        request.fields['claim_text'] = claimText;
      }

      if (filePath != null && filePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('file', filePath));
      }

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);
      return jsonDecode(response.body);
    } on TimeoutException {
      return {'status': 'error', 'message': 'Server not reachable (timed out)'};
    } catch (e) {
      return {'status': 'error', 'message': 'Connection failed: $e'};
    }
  }

  // ─── COMMUNITY STATS ───

  static Future<Map<String, dynamic>> getCommunityStats() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/community/stats'))
          .timeout(_timeout);
      return jsonDecode(response.body);
    } on TimeoutException {
      return {'status': 'error', 'message': 'Server not reachable (timed out)'};
    } catch (e) {
      return {'status': 'error', 'message': 'Connection failed: $e'};
    }
  }
}
