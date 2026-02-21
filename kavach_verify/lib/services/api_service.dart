import 'dart:convert';
import 'package:http/http.dart' as http;

/// API Service class for connecting to the custom AI backend.
/// All endpoints are stubbed and ready for integration.
/// Replace [_baseUrl] with your actual API base URL when ready.
class ApiService {
  // TODO: Replace with your actual AI backend URL
  static const String _baseUrl = 'https://your-api-endpoint.com/api/v1';

  // Optional: Add auth token management
  static String? _authToken;

  static void setAuthToken(String token) {
    _authToken = token;
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  /// Analyze text content for fake detection
  static Future<Map<String, dynamic>> analyzeText(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/analyze/text'),
        headers: _headers,
        body: jsonEncode({'text': text}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to analyze text: ${response.statusCode}');
    } catch (e) {
      // Return mock response for demo
      return _mockAnalysisResponse(text);
    }
  }

  /// Analyze an image for manipulation/deepfake
  static Future<Map<String, dynamic>> analyzeImage(String imagePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/analyze/image'),
      );
      request.headers.addAll(_headers);
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to analyze image: ${response.statusCode}');
    } catch (e) {
      return _mockAnalysisResponse('image');
    }
  }

  /// Analyze a video for deepfake content
  static Future<Map<String, dynamic>> analyzeVideo(String videoPath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/analyze/video'),
      );
      request.headers.addAll(_headers);
      request.files.add(await http.MultipartFile.fromPath('file', videoPath));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to analyze video: ${response.statusCode}');
    } catch (e) {
      return _mockAnalysisResponse('video');
    }
  }

  /// Analyze a voice/audio clip
  static Future<Map<String, dynamic>> analyzeVoice(String audioPath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/analyze/voice'),
      );
      request.headers.addAll(_headers);
      request.files.add(await http.MultipartFile.fromPath('file', audioPath));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to analyze voice: ${response.statusCode}');
    } catch (e) {
      return _mockAnalysisResponse('voice');
    }
  }

  /// Analyze a document (PDF, etc.)
  static Future<Map<String, dynamic>> analyzeDocument(String docPath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/analyze/document'),
      );
      request.headers.addAll(_headers);
      request.files.add(await http.MultipartFile.fromPath('file', docPath));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to analyze document: ${response.statusCode}');
    } catch (e) {
      return _mockAnalysisResponse('document');
    }
  }

  /// Analyze a URL/link
  static Future<Map<String, dynamic>> analyzeLink(String url) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/analyze/link'),
        headers: _headers,
        body: jsonEncode({'url': url}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to analyze link: ${response.statusCode}');
    } catch (e) {
      return _mockAnalysisResponse('link');
    }
  }

  /// Get user profile data
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/profile'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to get profile: ${response.statusCode}');
    } catch (e) {
      return {
        'name': 'Alakshya Singh',
        'email': 'alakshya@kavachverify.com',
        'total_verified': 147,
        'accuracy_score': 96.3,
        'community_rank': 'Gold Defender',
      };
    }
  }

  /// Get recent detections for the feed
  static Future<List<Map<String, dynamic>>> getRecentDetections() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/detections/recent'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      throw Exception('Failed to get detections: ${response.statusCode}');
    } catch (e) {
      return [];
    }
  }

  /// Submit feedback/comment on a detection
  static Future<bool> submitComment(String detectionId, String comment) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/detections/$detectionId/comments'),
        headers: _headers,
        body: jsonEncode({'comment': comment}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return true; // Mock success
    }
  }

  /// Submit app feedback
  static Future<bool> submitFeedback(String feedback) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/feedback'),
        headers: _headers,
        body: jsonEncode({'feedback': feedback}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return true; // Mock success
    }
  }

  // Mock response for demo
  static Map<String, dynamic> _mockAnalysisResponse(String type) {
    return {
      'is_fake': true,
      'confidence_score': 0.92,
      'analysis':
          'This $type has been analyzed and flagged as potentially fake content. '
          'Multiple indicators suggest manipulation or misinformation.',
      'details': [
        'Pattern analysis detected anomalies',
        'Source verification failed',
        'Cross-reference check found inconsistencies',
        'Content matches known misinformation templates',
      ],
    };
  }
}
