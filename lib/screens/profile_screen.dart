import 'package:dmp/models/user_profile.dart';
import 'package:dmp/screens/edit_profile_screen.dart';
import 'package:dmp/screens/find_your_spark_screen.dart';
import 'package:dmp/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Consistent Color Palette
const Color kPrimaryPink = Color(0xFFE91E63);
const Color kScaffoldBackground = Color(0xFFF8F8F8);
const Color kCardBackground = Colors.white;
const Color kTitleColor = Colors.black87;
const Color kSubtitleColor = Colors.grey;
const Color kIconColor = Color(0xFF757575);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  late Future<UserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    setState(() {
      _profileFuture = _authService.getMyProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldBackground,
      body: FutureBuilder<UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimaryPink),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    "Failed to load profile",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: kSubtitleColor),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loadProfile,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("No profile data found."));
          }

          final userProfile = snapshot.data!;
          return _buildProfileView(context, userProfile);
        },
      ),
    );
  }

  Widget _buildProfileView(BuildContext context, UserProfile profile) {
    // --- Header Section ---
    final Widget header = Container(
      padding: const EdgeInsets.all(24.0),
      color: kCardBackground,
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: kPrimaryPink.withOpacity(0.1),
            child: Text(
              profile.displayName.isNotEmpty
                  ? profile.displayName[0].toUpperCase()
                  : '?',
              style: GoogleFonts.montserrat(
                fontSize: 40,
                color: kPrimaryPink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile.displayName,
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kTitleColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.email,
            style: GoogleFonts.montserrat(fontSize: 16, color: kSubtitleColor),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn("Joined", "3m ago"), // Placeholder
              _buildStatColumn("Status", "Active"), // Placeholder
              _buildStatColumn("Matches", "12"), // Placeholder
            ],
          ),
        ],
      ),
    );

    // --- Onboarding Info Section ---
    final Widget onboardingInfo = profile.onboardingProfile == null
        ? _buildInfoCard(
            title: "Complete Your Profile!",
            child: Center(
              child: Column(
                children: [
                  const Text("Your onboarding profile is missing."),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      /* Navigate to onboarding */
                    },
                    child: const Text("Complete Profile Now"),
                  ),
                ],
              ),
            ),
          )
        : _buildInfoCard(
            title: "My Profile Details",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem(
                  Icons.person_outline,
                  "Gender",
                  profile.onboardingProfile!.gender,
                ),
                _buildDetailItem(
                  Icons.tag_faces_outlined,
                  "Pronouns",
                  profile.onboardingProfile!.pronouns,
                ),
                _buildDetailItem(
                  Icons.favorite_border,
                  "Interested In",
                  profile.onboardingProfile!.sexualOrientation.join(', '),
                ),
                _buildDetailItem(
                  Icons.question_answer_outlined,
                  "Opening Question",
                  profile.onboardingProfile!.openingQuestion,
                  isQuote: true,
                ),
                const SizedBox(height: 16),
                Text(
                  "My Interests",
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kTitleColor,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: profile.onboardingProfile!.generalInterests
                      .map(
                        (interest) => Chip(
                          label: Text(
                            interest,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          backgroundColor: kPrimaryPink.withOpacity(0.1),
                          labelStyle: const TextStyle(color: kPrimaryPink),
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          );

    // --- Actions Section ---
    final Widget actions = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        children: [
          _buildActionItem(
            context,
            icon: Icons.edit_outlined,
            title: "Edit Profile",
            onTap: () async {
              // Navigate to the edit screen and wait for a result
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(profile: profile),
                ),
              );

              // If the result is true, it means the profile was saved successfully.
              // We then call _loadProfile() to refresh the data on this screen.
              if (result == true) {
                _loadProfile();
              }
            },
          ),
          const Divider(height: 0),
          _buildActionItem(
            context,
            icon: Icons.shield_outlined,
            title: "Safety & Privacy",
            onTap: () {},
          ),
          const Divider(height: 0),
          _buildActionItem(
            context,
            icon: Icons.settings_outlined,
            title: "Settings",
            onTap: () {},
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout, color: kPrimaryPink),
            label: Text(
              "Sign Out",
              style: TextStyle(
                color: kPrimaryPink,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const FindYourSparkScreen(),
                  ),
                  (Route<dynamic> route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryPink.withOpacity(0.1),
              elevation: 0,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );

    return ListView(
      children: [header, const SizedBox(height: 16), onboardingInfo, actions],
    );
  }

  // --- Reusable Helper Widgets ---

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kTitleColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.montserrat(fontSize: 14, color: kSubtitleColor),
        ),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 24, thickness: 1),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String label,
    String value, {
    bool isQuote = false,
  }) {
    if (value.isEmpty)
      return const SizedBox.shrink(); // Don't show empty fields
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kIconColor, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    color: kSubtitleColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isQuote ? '"$value"' : value,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    height: 1.4,
                    color: kTitleColor,
                    fontStyle: isQuote ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: kIconColor),
      title: Text(
        title,
        style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: kSubtitleColor,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
