import 'dart:convert';
import 'package:dmp/constants/api_constants.dart';
import 'package:dmp/models/conversation_details.dart';
import 'package:dmp/models/conversation_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ConversationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to send the very first message to start a conversation
  Future<bool> startConversation({
    required String recipientId,
    required String content,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in.');
    }
    final idToken = await user.getIdToken();

    final url = Uri.parse('$kApiBaseUrl/v1/conversations/start');
    final body = json.encode({
      'recipient_id': recipientId,
      'content': content,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: body,
      );

      if (response.statusCode == 201) { // 201 Created
        print('Conversation started successfully.');
        return true;
      } else {
        final error = json.decode(response.body)['error'] ?? 'Unknown server error';
        print('Failed to start conversation. Status: ${response.statusCode}, Error: $error');
        throw Exception(error);
      }
    } catch (e) {
      print('An error occurred while starting conversation: $e');
      throw Exception('Could not connect to the server.');
    }
  }

  Future<List<ConversationPreview>> getConversations() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in.');
    final idToken = await user.getIdToken();

    final url = Uri.parse('$kApiBaseUrl/v1/conversations');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $idToken'},
      );
      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        return body.map((dynamic item) => ConversationPreview.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load conversations: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching conversations: $e');
    }
  }

  // NEW METHOD to send a message
  Future<void> sendMessage(String conversationId, String content) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in.');
    final idToken = await user.getIdToken();

    final url = Uri.parse('$kApiBaseUrl/v1/conversations/$conversationId/messages');
    final body = json.encode({'content': content});

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: body,
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to send message: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  Future<ConversationDetails> getConversationDetails(String conversationId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in.');
    final idToken = await user.getIdToken();

    final url = Uri.parse('$kApiBaseUrl/v1/conversations/$conversationId');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $idToken'},
      );
      if (response.statusCode == 200) {
        return ConversationDetails.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load conversation details: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching conversation details: $e');
    }
  }
}