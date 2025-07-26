enum MessageType {
  text,
  voice,
  image,
  system,
} // Added image type for future, system for icebreakers

class ChatMessage {
  final String id;
  final String senderId; // To identify who sent the message
  final String? text;
  final DateTime timestamp;
  final MessageType type;
  final String? voiceNotePath; // For local asset or URL
  final Duration? voiceNoteDuration;
  final String? imageUrl; // For images

  ChatMessage({
    required this.id,
    required this.senderId,
    this.text,
    required this.timestamp,
    required this.type,
    this.voiceNotePath,
    this.voiceNoteDuration,
    this.imageUrl,
  });
}

// lib/models/chat_participant.dart (or use a general User model if you have one)
class ChatParticipant {
  final String id;
  final String name;
  final String avatarAssetPath;

  ChatParticipant({
    required this.id,
    required this.name,
    required this.avatarAssetPath,
  });
}
