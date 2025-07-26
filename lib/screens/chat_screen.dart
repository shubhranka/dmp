import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dmp/constants/api_constants.dart';
import 'package:dmp/models/conversation_details.dart';
import 'package:dmp/services/conversation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/chat_message.dart';
import '../models/chat_participant.dart';

// --- Color Constants ---
const Color primaryAppColor = Color(0xFFE91E63);
const Color otherUserBubbleColor = Color(0xFFF0F0F0);
const Color appBarTitleColor = Colors.black87;
const Color bodyTextColor = Colors.black87;
const Color subtitleTextColor = Color(0xFF757575);
const Color inputFieldFillColor = Color(0xFFF5F5F5);
const Color iconColor = Color(0xFF757575);
const Color connectionProgressBackgroundColor = Color(0xFFE0E0E0);

class ChatScreen extends StatefulWidget {
  final ChatParticipant chatPartner;
  final String conversationId;

  const ChatScreen({
    super.key,
    required this.chatPartner,
    required this.conversationId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ConversationService _conversationService = ConversationService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ChatMessage> _messages = [];
  int _messageCount = 0;
  String _conversationStatus = 'pending';
  bool _isLoading = true;
  WebSocketChannel? _channel;
  
  // NOTE: This is a simplification. A robust app should fetch the user's
  // internal DB ID from a `/v1/me` endpoint and store it in a provider.
  // For this implementation, we will infer our ID by checking who is NOT the partner.
  String? _myInternalId; 

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    await _loadConversation();
    await _connectWebSocket();
  }

  Future<void> _loadConversation() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final details = await _conversationService.getConversationDetails(widget.conversationId);
      
      if (mounted) {
        setState(() {
          _messages = details.messages;
          _messageCount = details.messageCount;
          _conversationStatus = details.status;

          // Infer our internal ID from the first message if it exists
          if (_messages.isNotEmpty) {
            final firstSender = _messages.first.senderId;
            // The backend needs our real internal ID, which we don't have.
            // But for the UI logic `isMessageFromMe`, we just need to know if the sender
            // is the partner or not. We can use a placeholder for ourselves.
            _myInternalId = (firstSender == widget.chatPartner.id) ? "me" : firstSender;
          }
        });
      }
      _scrollToBottom(isInitialLoad: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading chat: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _connectWebSocket() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null || !mounted) return;
    
    final wsUrl = kApiBaseUrl.replaceFirst('http', 'ws');
    final uri = Uri.parse('$wsUrl/v1/ws/chat/${widget.conversationId}?token=$token');
    
    _channel = WebSocketChannel.connect(uri);
    
    _channel!.stream.listen((message) {
      if (!mounted) return;
      
      final decoded = json.decode(message);
      final newMsg = ChatMessage(
        id: decoded['id'],
        senderId: decoded['sender_id'],
        text: decoded['content'],
        timestamp: DateTime.parse(decoded['created_at']).toLocal(),
        type: MessageType.text,
      );

      // This check prevents adding a message twice if we were using optimistic UI.
      // With our current flow, it's a good safety measure.
      if (!_messages.any((m) => m.id == newMsg.id)) {
        setState(() {
          _messages.add(newMsg);
          _messageCount++;
          // If a pending chat gets a second message, it's now active.
          if (_conversationStatus == 'pending' && _messages.length > 1) {
            _conversationStatus = 'active';
          }
        });
        _scrollToBottom();
      }
    },
    onError: (error) => log("WebSocket Error: $error"),
    onDone: () => log("WebSocket connection for ${widget.conversationId} closed."),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    try {
      await _conversationService.sendMessage(widget.conversationId, text);
      _messageController.clear();
      // No need to optimistically add the message or reload.
      // The WebSocket will deliver the new message back to us, which is the source of truth.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to send: ${e.toString().replaceAll("Exception: ", "")}"), backgroundColor: Colors.red));
      }
    }
  }

  bool _canSendMessage() {
    if (_conversationStatus == 'pending') {
      if (_messages.isEmpty) return false;
      // The person who sent the first message cannot send again until it's active.
      // We check if our inferred ID is the same as the first message sender's ID.
      return _myInternalId != _messages.first.senderId;
    }
    return true; // If active, anyone can send
  }
  
  String _getHintText() {
    return _canSendMessage() ? "Type a message..." : "Waiting for a reply...";
  }

  void _scrollToBottom({bool isInitialLoad = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final position = _scrollController.position.maxScrollExtent;
        if (isInitialLoad) {
           _scrollController.jumpTo(position);
        } else {
          _scrollController.animateTo(
            position,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  bool isMessageFromMe(String senderId) {
      return senderId != widget.chatPartner.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: appBarTitleColor, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.chatPartner.name,
          style: GoogleFonts.montserrat(color: appBarTitleColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz, color: appBarTitleColor), onPressed: () {}),
        ],
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildConnectionProgressBar(),
          Expanded(
            child: (_isLoading && _messages.isEmpty)
              ? const Center(child: CircularProgressIndicator(color: primaryAppColor))
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(10.0),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _MessageBubble(
                      message: message,
                      isMe: isMessageFromMe(message.senderId),
                      chatPartner: widget.chatPartner,
                    );
                  },
                ),
          ),
          _MessageInputBar(
            controller: _messageController,
            onSendPressed: _canSendMessage() ? _sendMessage : null,
            hintText: _getHintText(),
            onMicPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Voice messages not yet implemented.")));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionProgressBar() {
    const totalStepsForPhotoReveal = 10;
    double progressValue = _messageCount / totalStepsForPhotoReveal;
    if (progressValue > 1.0) progressValue = 1.0;
    if (progressValue.isNaN) progressValue = 0.0;
    
    final List<String> progressStages = ["Names", "Interests", "Voice Note", "Photo"];
    int currentProgressStage = 0;
    if (_messageCount >= 10) currentProgressStage = 3;
    else if (_messageCount >= 5) currentProgressStage = 2;
    else if (_messageCount >= 2) currentProgressStage = 1;

    String nextStageLabel = currentProgressStage < progressStages.length - 1
        ? progressStages[currentProgressStage + 1]
        : "Completed";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Connection Progress",
                style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: bodyTextColor),
              ),
              Text(
                "Next: $nextStageLabel Reveal",
                style: GoogleFonts.montserrat(fontSize: 12, color: subtitleTextColor),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: connectionProgressBackgroundColor,
              valueColor: const AlwaysStoppedAnimation<Color>(primaryAppColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: progressStages.asMap().entries.map((entry) {
              int idx = entry.key;
              String name = entry.value;
              bool isActive = idx <= currentProgressStage;
              return Text(
                name,
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  color: isActive ? primaryAppColor : subtitleTextColor.withOpacity(0.7),
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// --- Message Bubble Widget ---
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final ChatParticipant chatPartner;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.chatPartner,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleAlignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isMe ? primaryAppColor : otherUserBubbleColor;
    final textColor = isMe ? Colors.white : bodyTextColor;
    final bubbleRadius = const Radius.circular(16);

    final myAvatar = 'assets/avatars/avatar_male_1.png'; // Placeholder for current user's avatar

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: bubbleAlignment,
        children: [
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                CircleAvatar(
                  radius: 14,
                  backgroundImage: AssetImage(chatPartner.avatarAssetPath),
                  backgroundColor: Colors.grey[200],
                ),
                const SizedBox(width: 8),
              ],
              Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: bubbleRadius,
                    topRight: bubbleRadius,
                    bottomLeft: isMe ? bubbleRadius : Radius.zero,
                    bottomRight: isMe ? Radius.zero : bubbleRadius,
                  ),
                ),
                child: Text(
                  message.text ?? "",
                  style: GoogleFonts.montserrat(fontSize: 14.5, color: textColor, height: 1.4),
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 14,
                  backgroundImage: AssetImage(myAvatar),
                  backgroundColor: Colors.grey[200],
                ),
              ],
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 3.0,
              left: isMe ? 0 : 44,
              right: isMe ? 44 : 0,
            ),
            child: Text(
              "${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}",
              style: GoogleFonts.montserrat(fontSize: 10.5, color: subtitleTextColor.withOpacity(0.8)),
            ),
          ),
        ],
      ),
    );
  }
}


// --- Message Input Bar Widget ---
class _MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onSendPressed; // Nullable to allow disabling
  final VoidCallback onMicPressed;
  final String hintText;

  const _MessageInputBar({
    required this.controller,
    required this.onSendPressed,
    required this.onMicPressed,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onSendPressed != null;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1.0)),
        ),
        child: Row(
          children: [
            IconButton(icon: const Icon(Icons.sentiment_satisfied_alt_outlined, color: iconColor), onPressed: () {}),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: isEnabled,
                style: GoogleFonts.montserrat(fontSize: 15),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: GoogleFonts.montserrat(color: Colors.grey[500], fontSize: 15),
                  filled: true,
                  fillColor: isEnabled ? inputFieldFillColor : Colors.grey[200],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            IconButton(icon: const Icon(Icons.mic_none_outlined, color: iconColor), onPressed: onMicPressed),
            IconButton(
              icon: Icon(
                Icons.send_rounded,
                color: isEnabled ? primaryAppColor : Colors.grey,
                size: 28,
              ),
              onPressed: onSendPressed,
            ),
          ],
        ),
      ),
    );
  }
}