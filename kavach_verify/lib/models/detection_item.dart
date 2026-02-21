class DetectionItem {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String location;
  final String category; // text, image, video, voice, document, link
  final DateTime detectedAt;
  final double confidenceScore;
  final String analysisDetails;
  final bool isFake;

  DetectionItem({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.location,
    required this.category,
    required this.detectedAt,
    required this.confidenceScore,
    required this.analysisDetails,
    required this.isFake,
  });

  factory DetectionItem.fromJson(Map<String, dynamic> json) {
    return DetectionItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'],
      location: json['location'] ?? '',
      category: json['category'] ?? 'text',
      detectedAt:
          DateTime.tryParse(json['detected_at'] ?? '') ?? DateTime.now(),
      confidenceScore: (json['confidence_score'] ?? 0).toDouble(),
      analysisDetails: json['analysis_details'] ?? '',
      isFake: json['is_fake'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'location': location,
      'category': category,
      'detected_at': detectedAt.toIso8601String(),
      'confidence_score': confidenceScore,
      'analysis_details': analysisDetails,
      'is_fake': isFake,
    };
  }
}

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? attachmentPath;
  final String? attachmentType;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.attachmentPath,
    this.attachmentType,
  });
}

class UserProfile {
  final String name;
  final String email;
  final String avatarUrl;
  final int totalVerified;
  final double accuracyScore;
  final String communityRank;

  UserProfile({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.totalVerified,
    required this.accuracyScore,
    required this.communityRank,
  });
}
