import 'package:dmp/models/chat_message.dart';
import 'package:dmp/models/user_profile.dart' as full_profile;
import 'package:dmp/services/conversation_service.dart';
import 'package:dmp/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Models
import '../models/match_profile.dart';
import '../models/user_interest_profile.dart';
import '../models/chat_participant.dart';

// Screens
import 'chat_screen.dart';

// Color Constants
const Color primaryAppColor = Color(0xFFE91E63);
const Color lightPinkBackground = Color(0xFFFCE4EC);
const Color appBarTitleColor = Colors.black87;
const Color bodyTextColor = Colors.black87;
const Color subtitleTextColor = Color(0xFF616161);
const Color cardBackgroundColor = Color(0xFFF9F9F9);

class MatchDetailProfileScreen extends StatefulWidget {
  final MatchProfile match; // We still need the initial preview data

  const MatchDetailProfileScreen({super.key, required this.match});

  State<MatchDetailProfileScreen> createState() => _MatchDetailProfileScreenState();
}

class _MatchDetailProfileScreenState extends State<MatchDetailProfileScreen> {
  final UserService _userService = UserService();
  final ConversationService _conversationService = ConversationService();
  late Future<full_profile.UserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    // Fetch the full profile when the screen loads
    _profileFuture = _userService.getProfileById(widget.match.id);
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
          widget.match.displayName, // Use preview name initially
          style: GoogleFonts.montserrat(color: appBarTitleColor, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz, color: appBarTitleColor), onPressed: () {}),
        ],
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<full_profile.UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryAppColor));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Profile not found.'));
          }

          final userProfile = snapshot.data!;
          final onboardingData = userProfile.onboardingProfile;

          // If onboarding is incomplete, show a different view
          if (onboardingData == null) {
            return const Center(
              child: Text("This user has not completed their profile yet."),
            );
          }

          return _buildFullProfileView(context, userProfile, onboardingData);
        },
      ),
    );
  }

  void _showReplyDialog(BuildContext context, full_profile.UserProfile userProfile) {
  final TextEditingController replyController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isSending = false; // To manage the loading state within the dialog

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      // Use a StatefulWidget inside the dialog to manage its state
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              "Reply to ${userProfile.displayName}",
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"${userProfile.onboardingProfile?.openingQuestion}"',
                    style: GoogleFonts.montserrat(fontStyle: FontStyle.italic, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: replyController,
                    autofocus: true,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Your reply...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Reply cannot be empty.";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: isSending ? null : () async {
                  if (formKey.currentState!.validate()) {
                    setDialogState(() => isSending = true);
                    try {
                      await _conversationService.startConversation(
                        recipientId: userProfile.id,
                        content: replyController.text.trim(),
                      );

                      if (mounted) {
                        Navigator.of(dialogContext).pop(); // Close the dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Your message has been sent!"),
                            backgroundColor: Colors.green,
                          ),
                        );
                        // Optionally, pop the profile screen too
                        Navigator.of(context).pop();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: ${e.toString()}"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } finally {
                       if (mounted) {
                         setDialogState(() => isSending = false);
                       }
                    }
                  }
                },
                child: isSending
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Send"),
              ),
            ],
          );
        },
      );
    },
  );
}

  Widget _buildFullProfileView(BuildContext context, full_profile.UserProfile userProfile, full_profile.OnboardingProfile onboardingData) {
  final List<UserInterestProfile> interests = onboardingData.generalInterests.map((name) {
    return UserInterestProfile(name: name, weight: "Shared", role: "Enthusiast");
  }).toList();

  // *** THE MAIN CHANGE IS HERE: USING A COLUMN INSTEAD OF A STACK ***
  return Column(
    children: [
      // This Expanded widget makes the content scrollable
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: AssetImage(widget.match.avatarAssetPath),
              ),
              const SizedBox(height: 12),
              Text(
                userProfile.displayName,
                style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: bodyTextColor),
              ),
              const SizedBox(height: 24),

              _buildSectionTitle("Interests"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: interests.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                    childAspectRatio: 1.8,
                  ),
                  itemBuilder: (context, index) {
                    return _buildInterestCard(interests[index]);
                  },
                ),
              ),

              _buildSectionTitle("${userProfile.displayName.split(" ").first}'s Opening Question"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: lightPinkBackground,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    onboardingData.openingQuestion,
                    style: GoogleFonts.montserrat(fontSize: 15, color: bodyTextColor.withOpacity(0.9), height: 1.4),
                  ),
                ),
              ),
              const SizedBox(height: 20), // Padding at the very bottom of the scrollable area
            ],
          ),
        ),
      ),
      // The Action Bar is now a direct child of the Column, outside the scrollable area.
      _buildBottomActionBar(context, userProfile),
    ],
  );
}

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 24.0, bottom: 12.0),
      child: Text(title, style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: bodyTextColor)),
    );
  }

  Widget _buildInterestCard(UserInterestProfile interest) {
    return Card(
      elevation: 0,
      color: cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              interest.name,
              style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w600, color: bodyTextColor),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // We can hide these as our backend doesn't provide them yet
            // Text("Weight: ${interest.weight}", style: GoogleFonts.montserrat(fontSize: 12, color: subtitleTextColor)),
            // Text("Role: ${interest.role}", style: GoogleFonts.montserrat(fontSize: 12, color: subtitleTextColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, full_profile.UserProfile userProfile) {
    return Container(
      color: Colors.white, // To ensure it covers content behind it
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0).copyWith(bottom: MediaQuery.of(context).padding.bottom + 12.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.favorite_border, size: 20, color: Colors.white),
              label: Text('Show Interest', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
              onPressed: () { _showReplyDialog(context, userProfile);},
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryAppColor,
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20, color: bodyTextColor),
              label: Text('Message', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: bodyTextColor)),
              onPressed: () {
                _showReplyDialog(context, userProfile);
                // final chatPartner = ChatParticipant(
                //   id: userProfile.id,
                //   name: userProfile.displayName,
                //   avatarAssetPath: widget.match.avatarAssetPath,
                // );
                // Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(chatPartner: chatPartner)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
