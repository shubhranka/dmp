// lib/screens/add_general_interests_screen.dart

import 'package:dmp/screens/record_audio_intro_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import 'progress_steps_bar.dart';

const Color primaryAppColor = Color(0xFFE91E63);
const Color chipLabelColor = Colors.white;
const Color searchBarFillColor = Color(0xFFF5F5F5);
const Color suggestedItemBorderColor = Color(0xFFE0E0E0);
const Color suggestedItemIconColor = primaryAppColor;
const Color suggestedItemTextColor = Colors.black87;
const Color appBarTitleColor = Colors.black87;
const Color sectionTitleColor = Colors.black54;
const Color screenBackgroundColor = Colors.white;

class SuggestedInterest {
  final String name;
  final IconData icon;
  SuggestedInterest({required this.name, required this.icon});
}

class AddGeneralInterestsScreen extends StatefulWidget {
  final String gender;
  final String pronouns;
  final List<String> sexualInterests;

  const AddGeneralInterestsScreen({
    super.key,
    required this.gender,
    required this.pronouns,
    required this.sexualInterests,
  });

  @override
  State<AddGeneralInterestsScreen> createState() =>
      _AddGeneralInterestsScreenState();
}

class _AddGeneralInterestsScreenState extends State<AddGeneralInterestsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _myGeneralInterests = {};

  final List<SuggestedInterest> _suggestedInterestsData = [
    SuggestedInterest(name: 'Music', icon: Icons.music_note_outlined),
    SuggestedInterest(name: 'Reading', icon: Icons.book_outlined),
    SuggestedInterest(name: 'Hiking', icon: Icons.hiking_outlined),
    SuggestedInterest(name: 'Cooking', icon: Icons.soup_kitchen_outlined),
    SuggestedInterest(name: 'Travel', icon: Icons.flight_takeoff_outlined),
    SuggestedInterest(name: 'Gaming', icon: Icons.sports_esports_outlined),
    SuggestedInterest(name: 'Art', icon: Icons.palette_outlined),
    SuggestedInterest(name: 'Photography', icon: Icons.camera_alt_outlined),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addInterest(String interest) {
    if (interest.trim().isNotEmpty) {
      setState(() {
        if (!_myGeneralInterests.any(
          (item) => item.toLowerCase() == interest.trim().toLowerCase(),
        )) {
          _myGeneralInterests.add(interest.trim());
        }
      });
    }
  }

  void _removeInterest(String interest) {
    setState(() {
      _myGeneralInterests.remove(interest);
    });
  }

  void _toggleSuggestedInterest(String interestName) {
    setState(() {
      if (_myGeneralInterests.contains(interestName)) {
        _myGeneralInterests.remove(interestName);
      } else {
        _myGeneralInterests.add(interestName);
      }
    });
  }

  Widget _buildMyInterests() {
    if (_myGeneralInterests.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 10.0),
          child: Text(
            'MY INTERESTS',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: sectionTitleColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _myGeneralInterests.map((interest) {
            return Chip(
              label: Text(
                interest,
                style: GoogleFonts.montserrat(
                  color: chipLabelColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              backgroundColor: primaryAppColor,
              deleteIcon: const Icon(
                Icons.close,
                color: chipLabelColor,
                size: 18,
              ),
              onDeleted: () => _removeInterest(interest),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSuggestedInterests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
          child: Text(
            'SUGGESTED',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: sectionTitleColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _suggestedInterestsData.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            childAspectRatio: 2.8,
          ),
          itemBuilder: (context, index) {
            final interest = _suggestedInterestsData[index];
            return OutlinedButton.icon(
              icon: Icon(
                interest.icon,
                size: 22,
                color: suggestedItemIconColor,
              ),
              label: Text(
                interest.name,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w500,
                  color: suggestedItemTextColor,
                  fontSize: 15,
                ),
              ),
              onPressed: () => _toggleSuggestedInterest(interest.name),
              style: OutlinedButton.styleFrom(
                backgroundColor: screenBackgroundColor,
                foregroundColor: suggestedItemTextColor,
                side: const BorderSide(
                  color: suggestedItemBorderColor,
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                alignment: Alignment.centerLeft,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: appBarTitleColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Add Interests',
          style: GoogleFonts.montserrat(
            color: appBarTitleColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: screenBackgroundColor,
        elevation: 0,
      ),
      backgroundColor: screenBackgroundColor,
      body: Column(
        children: [
          const ProgressStepsBar(
            currentStep: 3,
            totalSteps: kTotalAccountCreationSteps,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    controller: _searchController,
                    style: GoogleFonts.montserrat(fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Search or add interests',
                      hintStyle: GoogleFonts.montserrat(
                        color: Colors.grey[500],
                        fontSize: 15,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[600],
                        size: 22,
                      ),
                      filled: true,
                      fillColor: searchBarFillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15.0,
                      ),
                    ),
                    onSubmitted: (value) {
                      _addInterest(value);
                      _searchController.clear();
                    },
                  ),
                  _buildMyInterests(),
                  _buildSuggestedInterests(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            onPressed: (_myGeneralInterests.isNotEmpty)
                ? () {
                    // Pass all data to the next screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecordAudioIntroScreen(
                          gender: widget.gender,
                          pronouns: widget.pronouns,
                          sexualInterests: widget.sexualInterests,
                          generalInterests: _myGeneralInterests.toList(),
                        ),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryAppColor,
              disabledBackgroundColor: primaryAppColor.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
            child: Text(
              'Next',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
