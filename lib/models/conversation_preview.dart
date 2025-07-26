class ConversationPreview {
  final String conversationId;
  final String status;
  final String otherUserId;
  final String otherUserDisplayName;
  final String lastMessage;
  final String lastMessageSenderId;
  final DateTime lastMessageAt;
  final DateTime updatedAt;

  ConversationPreview({
    required this.conversationId,
    required this.status,
    required this.otherUserId,
    required this.otherUserDisplayName,
    required this.lastMessage,
    required this.lastMessageSenderId,
    required this.lastMessageAt,
    required this.updatedAt,
  });

  factory ConversationPreview.fromJson(Map<String, dynamic> json) {
    return ConversationPreview(
      conversationId: json['conversation_id'] ?? '',
      status: json['status'] ?? 'pending',
      otherUserId: json['other_user_id'] ?? '',
      otherUserDisplayName: json['other_user_display_name'] ?? 'Unknown',
      lastMessage: json['last_message'] ?? 'No messages yet.',
      lastMessageSenderId: json['last_message_sender_id'] ?? '',
      lastMessageAt: DateTime.tryParse(json['last_message_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}