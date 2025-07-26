import 'package:dmp/models/chat_message.dart'; // We'll reuse our existing ChatMessage model

// Represents the full JSON object from GET /v1/conversations/:id
class ConversationDetails {
  final String id;
  final String status;
  final int messageCount;
  final bool photosUnlocked;
  final List<ChatMessage> messages;

  ConversationDetails({
    required this.id,
    required this.status,
    required this.messageCount,
    required this.photosUnlocked,
    required this.messages,
  });

  factory ConversationDetails.fromJson(Map<String, dynamic> json) {
    var messageList = json['messages'] as List;
    List<ChatMessage> messages = messageList.map((i) {
      // We need to adapt the JSON from the backend to our ChatMessage model
      return ChatMessage(
        id: i['id'],
        senderId: i['sender_id'],
        text: i['content'],
        timestamp: DateTime.parse(i['created_at']),
        type: MessageType.text, // For now, all messages are text
      );
    }).toList();

    return ConversationDetails(
      id: json['id'],
      status: json['status'],
      messageCount: json['message_count'],
      photosUnlocked: json['photos_unlocked'],
      messages: messages,
    );
  }
}