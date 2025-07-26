import 'package:dmp/models/chat_message.dart';
import 'package:dmp/models/conversation_preview.dart';
import 'package:dmp/screens/chat_screen.dart';
import 'package:dmp/services/conversation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ConversationsListScreen extends StatefulWidget {
  const ConversationsListScreen({super.key});

  @override
  State<ConversationsListScreen> createState() => _ConversationsListScreenState();
}

class _ConversationsListScreenState extends State<ConversationsListScreen> {
  final ConversationService _conversationService = ConversationService();
  late Future<List<ConversationPreview>> _conversationsFuture;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  void _loadConversations() {
    setState(() {
      _conversationsFuture = _conversationService.getConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _loadConversations(),
        child: FutureBuilder<List<ConversationPreview>>(
          future: _conversationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No conversations yet."));
            }

            final conversations = snapshot.data!;
            return ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final convo = conversations[index];
                final isMyMessage = convo.lastMessageSenderId == currentUserId;

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(convo.otherUserDisplayName.substring(0, 1)),
                  ),
                  title: Text(convo.otherUserDisplayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    "${isMyMessage ? 'You: ' : ''}${convo.lastMessage}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: convo.status == 'pending' ? const Chip(label: Text('Pending'), backgroundColor: Colors.amber) : null,
                  onTap: () {
  // We need to create a ChatParticipant object for the person we are chatting with.
  final chatPartner = ChatParticipant(
    id: convo.otherUserId, // This is the user's INTERNAL database ID
    name: convo.otherUserDisplayName,
    // We need a placeholder avatar until we fetch more profile details
    avatarAssetPath: 'assets/avatars/avatar_placeholder.png', 
  );

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ChatScreen(
        chatPartner: chatPartner,
        conversationId: convo.conversationId,
      ),
    ),
  );
},
                );
              },
            );
          },
        ),
      ),
    );
  }
}