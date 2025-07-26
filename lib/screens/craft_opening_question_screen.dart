// lib/screens/craft_opening_question_screen.dart

import 'package:dmp/screens/dealbreakers_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import '../screens/progress_steps_bar.dart';

const Color primaryAppColor = Color(0xFFE91E63);
const Color lightPinkBackground = Color(0xFFFCE4EC);
const Color appBarTitleColor = Colors.black87;
const Color bodyTextColor = Colors.black87;
const Color subtitleTextColor = Color(0xFF616161);
const Color textFieldBorderColor = Color(0xFFBDBDBD);
const Color hintTextColor = Color(0xFF9E9E9E);
const Color inactiveChipColor = Color(0xFFF0F0F0);
const Color activeChipTextColor = primaryAppColor;
const Color inactiveChipTextColor = Colors.black54;

class Suggestion {
  final String text;
  final String category;
  Suggestion({required this.text, required this.category});
}

class CraftOpeningQuestionScreen extends StatefulWidget {
  final String gender;
  final String pronouns;
  final List<String> sexualInterests;
  final List<String> generalInterests;

  const CraftOpeningQuestionScreen({
    super.key,
    required this.gender,
    required this.pronouns,
    required this.sexualInterests,
    required this.generalInterests,
  });

  @override
  State<CraftOpeningQuestionScreen> createState() =>
      _CraftOpeningQuestionScreenState();
}

class _CraftOpeningQuestionScreenState
    extends State<CraftOpeningQuestionScreen> {
  final TextEditingController _questionController = TextEditingController();
  final int _maxChars = 200;
  String _selectedCategory = "Funny";

  final List<Suggestion> _allSuggestions = [
    Suggestion(
      text: "If you were a comedian, what would be your opening joke?",
      category: "Funny",
    ),
    Suggestion(
      text: "What's the most useless talent you have?",
      category: "Funny",
    ),
    Suggestion(
      text: "What's a skill you've always wanted to learn, and why?",
      category: "Deep",
    ),
    Suggestion(
      text:
          "If you could have dinner with any historical figure, who would it be?",
      category: "Deep",
    ),
    Suggestion(
      text: "Ideal Sunday: a cozy cafe, an adventurous hike, or a lazy day in?",
      category: "Activity-Based",
    ),
    Suggestion(
      text:
          "Beach vacation or mountain retreat? And what's the first thing you'd do?",
      category: "Activity-Based",
    ),
    Suggestion(
      text: "What's the weirdest food combination you secretly enjoy?",
      category: "Quirky",
    ),
    Suggestion(
      text: "If animals could talk, which would be the rudest?",
      category: "Quirky",
    ),
  ];

  List<Suggestion> get _filteredSuggestions {
    return _allSuggestions
        .where((s) => s.category == _selectedCategory)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _questionController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Widget _buildCategoryChip(String category) {
    bool isActive = _selectedCategory == category;
    return ChoiceChip(
      label: Text(category),
      selected: isActive,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedCategory = category;
          });
        }
      },
      backgroundColor: inactiveChipColor,
      selectedColor: lightPinkBackground,
      labelStyle: GoogleFonts.montserrat(
        color: isActive ? activeChipTextColor : inactiveChipTextColor,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isActive ? primaryAppColor : Colors.transparent,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildSuggestionItem(Suggestion suggestion) {
    return GestureDetector(
      onTap: () {
        _questionController.text = suggestion.text;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: textFieldBorderColor.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                suggestion.text,
                style: GoogleFonts.montserrat(
                  fontSize: 14.5,
                  color: bodyTextColor,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "Use this question",
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: primaryAppColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool canProceed = _questionController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: appBarTitleColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Opening Question',
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
            currentStep: 5,
            totalSteps: kTotalAccountCreationSteps,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Craft Your Opening Question',
                    style: GoogleFonts.montserrat(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: bodyTextColor,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    "This is your chance to spark a meaningful conversation. Make it count!",
                    style: GoogleFonts.montserrat(
                      fontSize: 15.0,
                      color: subtitleTextColor,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  TextField(
                    controller: _questionController,
                    maxLength: _maxChars,
                    maxLines: 3,
                    minLines: 1,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: bodyTextColor,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          "E.g., What's a skill you're currently trying to learn?",
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
                      counterText:
                          "${_questionController.text.length}/$_maxChars characters",
                      counterStyle: GoogleFonts.montserrat(
                        color: subtitleTextColor,
                        fontSize: 12,
                      ),
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(_maxChars),
                    ],
                  ),
                  const SizedBox(height: 30.0),
                  Text(
                    'Need Inspiration?',
                    style: GoogleFonts.montserrat(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: bodyTextColor,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      _buildCategoryChip("Funny"),
                      _buildCategoryChip("Deep"),
                      _buildCategoryChip("Activity-Based"),
                      _buildCategoryChip("Quirky"),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  if (_filteredSuggestions.isNotEmpty)
                    ..._filteredSuggestions
                        .take(2)
                        .map((s) => _buildSuggestionItem(s))
                        .toList(),
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
            onPressed: !canProceed
                ? null
                : () {
                    // Navigate to the next screen, passing all data along.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DealbreakersScreen(
                          gender: widget.gender,
                          pronouns: widget.pronouns,
                          sexualInterests: widget.sexualInterests,
                          generalInterests: widget.generalInterests,
                          openingQuestion: _questionController.text.trim(),
                        ),
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryAppColor,
              disabledBackgroundColor: primaryAppColor.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(
              'Save Question',
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
