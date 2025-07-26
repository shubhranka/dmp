// lib/screens/discover_screen.dart

import 'package:dmp/models/match_profile.dart';
import 'package:dmp/screens/match_detail_profile_screen.dart';
import 'package:dmp/services/match_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Color constants can stay here or be moved to a central theme file
const Color primaryAppColor = Color(0xFFE91E63);
const Color bodyTextColor = Colors.black87;
const Color subtitleTextColor = Color(0xFF757575);
const Color cardBackgroundColor = Colors.white;
const Color iconColor = Color(0xFF757575);

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  late Future<List<MatchProfile>> _matchesFuture;
  final MatchService _matchService = MatchService();

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  void _loadMatches() {
    setState(() {
      _matchesFuture = _matchService.getPotentialMatches();
    });
  }

  // This Match Card widget remains the same as it's part of the body
  Widget _buildMatchCard(BuildContext context, MatchProfile match) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchDetailProfileScreen(match: match),
          ),
        );
      },
      child: Card(
        elevation: 0.5,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        color: cardBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: Colors.grey[200]!, width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: AssetImage(match.avatarAssetPath),
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.displayName,
                      style: GoogleFonts.montserrat(
                        fontSize: 17.0,
                        fontWeight: FontWeight.w600,
                        color: bodyTextColor,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      match.matchReason,
                      style: GoogleFonts.montserrat(
                        fontSize: 13.5,
                        color: subtitleTextColor,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8.0),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Asks: ",
                            style: GoogleFonts.montserrat(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: bodyTextColor.withOpacity(0.9),
                            ),
                          ),
                          TextSpan(
                            text: "'${match.openingQuestion}'",
                            style: GoogleFonts.montserrat(
                              fontSize: 13.5,
                              color: subtitleTextColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Icon(
                match.customIconFlag == true
                    ? Icons.chat_bubble_outline_rounded
                    : Icons.mic_none_outlined,
                color: iconColor,
                size: 22.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // *** THE MAIN CHANGE IS HERE ***
    // We return the FutureBuilder directly, NOT a Scaffold widget.
    return FutureBuilder<List<MatchProfile>>(
      future: _matchesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: primaryAppColor),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Failed to load matches: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loadMatches,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No Matches Found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Try changing your preferences or check back later!',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loadMatches,
                  child: const Text('Refresh'),
                ),
              ],
            ),
          );
        } else {
          final matches = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              return _buildMatchCard(context, matches[index]);
            },
          );
        }
      },
    );
  }
}
