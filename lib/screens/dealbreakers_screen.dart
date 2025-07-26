// lib/screens/dealbreakers_screen.dart

import 'dart:convert';
import 'package:dmp/constants/api_constants.dart';
import 'package:dmp/screens/discover_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../screens/progress_steps_bar.dart';

const Color primaryAppColor = Color(0xFFE91E63);
const Color appBarTitleColor = Colors.black87;
const Color bodyTextColor = Colors.black87;
const Color subtitleTextColor = Color(0xFF616161);
const Color textFieldBorderColor = Color(0xFFBDBDBD);
const Color hintTextColor = Color(0xFF9E9E9E);

class DealbreakersScreen extends StatefulWidget {
  // Accepts all data from the entire onboarding flow
  final String gender;
  final String pronouns;
  final List<String> sexualInterests;
  final List<String> generalInterests;
  final String openingQuestion;

  const DealbreakersScreen({
    super.key,
    required this.gender,
    required this.pronouns,
    required this.sexualInterests,
    required this.generalInterests,
    required this.openingQuestion,
  });

  @override
  State<DealbreakersScreen> createState() => _DealbreakersScreenState();
}

class _DealbreakersScreenState extends State<DealbreakersScreen> {
  final TextEditingController _dealbreakersController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _dealbreakersController.dispose();
    super.dispose();
  }

  Future<void> _submitOnboardingData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: You are not logged in.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final idToken = await user.getIdToken();
    if (idToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Could not retrieve auth token.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final url = Uri.parse('$kApiBaseUrl/v1/onboarding');
    final body = json.encode({
      'gender': widget.gender,
      'pronouns': widget.pronouns,
      'sexual_orientation': widget.sexualInterests,
      'general_interests': widget.generalInterests,
      'opening_question': widget.openingQuestion,
      'dealbreakers': _dealbreakersController.text.trim(),
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

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile created successfully!')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DiscoverScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        final responseBody = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${responseBody['error'] ?? 'Something went wrong.'}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
          'Dealbreakers',
          style: GoogleFonts.montserrat(
            color: appBarTitleColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const ProgressStepsBar(
            currentStep: 6,
            totalSteps: kTotalAccountCreationSteps,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'What are you not looking for?',
                    style: GoogleFonts.montserrat(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: bodyTextColor,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    "This helps us filter out profiles that aren't a good fit for you, ensuring more meaningful connections.",
                    style: GoogleFonts.montserrat(
                      fontSize: 15.0,
                      color: subtitleTextColor,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  TextField(
                    controller: _dealbreakersController,
                    maxLines: 7,
                    minLines: 5,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: bodyTextColor,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'e.g., Smoking, excessive drinking, lack of ambition, different political views, prefers cats over dogs...',
                      hintStyle: GoogleFonts.montserrat(
                        color: hintTextColor,
                        fontSize: 15,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(
                          color: textFieldBorderColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(
                          color: textFieldBorderColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(
                          color: primaryAppColor,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    "Be specific! The more details you provide, the better we can tailor your matches.",
                    style: GoogleFonts.montserrat(
                      fontSize: 13.0,
                      color: subtitleTextColor.withOpacity(0.8),
                    ),
                  ),
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
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: primaryAppColor),
                )
              : ElevatedButton(
                  onPressed: _submitOnboardingData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryAppColor,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    'Save Dealbreakers',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
