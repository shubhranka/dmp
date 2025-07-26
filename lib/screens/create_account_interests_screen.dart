import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_general_interests_screen.dart'; // Will navigate to this new screen
import 'progress_steps_bar.dart'; // Import the new progress bar
import '../constants/app_constants.dart';

// --- Color Constants ---
const Color newPrimaryPink = Color(0xFFE91E63);
const Color newLightPinkBackground = Color(0xFFFCE4EC);
const Color nextButtonTextColor = Colors.white;
const Color appBarTitleColor = Colors.black87;
const Color bodyTextColor = Colors.black87;
const Color subtitleTextColor = Color(0xFF616161);
const Color defaultOptionBorderColor = Color(
  0xFFE0E0E0,
); // Added back for options
// --- End Color Constants ---

class CreateAccountInterestsScreen extends StatefulWidget {
  final String gender;
  final String pronouns;

  const CreateAccountInterestsScreen({
    super.key,
    required this.gender,
    required this.pronouns,
  });

  @override
  State<CreateAccountInterestsScreen> createState() =>
      _CreateAccountInterestsScreenState();
}

class _CreateAccountInterestsScreenState
    extends State<CreateAccountInterestsScreen> {
  final List<String> _interestOptionsList = [
    'Women',
    'Men',
    'Non-binary people',
    'All genders',
    'Prefer not to say',
  ];
  final Map<String, bool> _selectedInterests = {};

  // _buildProgressBar method is now removed

  @override
  void initState() {
    super.initState();
    for (var option in _interestOptionsList) {
      _selectedInterests[option] = false;
    }
  }

  Widget _buildInterestCheckboxOption({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    bool isSelected = value;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      decoration: BoxDecoration(
        color: isSelected ? newLightPinkBackground : Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: isSelected ? newPrimaryPink : defaultOptionBorderColor,
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: CheckboxListTile(
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 16.0,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: bodyTextColor,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: newPrimaryPink,
        controlAffinity: ListTileControlAffinity.leading,
        checkboxShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool canProceed = _selectedInterests.values.any((isSelected) => isSelected);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Create Account',
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
      body: SafeArea(
        child: Column(
          children: [
            const ProgressStepsBar(
              currentStep: 2, // This is Step 2
              totalSteps: kTotalAccountCreationSteps,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.favorite_border,
                            color: newPrimaryPink,
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Who are you interested in?",
                              style: GoogleFonts.montserrat(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: bodyTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        "Select all that apply. We'll use this to find potential matches.",
                        style: GoogleFonts.montserrat(
                          fontSize: 14.0,
                          color: subtitleTextColor,
                          height: 1.4,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    ..._interestOptionsList.map((option) {
                      return _buildInterestCheckboxOption(
                        title: option,
                        value: _selectedInterests[option]!,
                        onChanged: (bool? newValue) {
                          setState(() {
                            _selectedInterests[option] = newValue!;
                          });
                        },
                      );
                    }).toList(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 24.0),
          child: ElevatedButton(
            onPressed: !canProceed
                ? null
                : () {
                    List<String> selectedSexualInterests = _selectedInterests
                        .entries
                        .where((entry) => entry.value)
                        .map((entry) => entry.key)
                        .toList();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddGeneralInterestsScreen(
                          // Pass all collected data so far
                          gender: widget.gender,
                          pronouns: widget.pronouns,
                          sexualInterests: selectedSexualInterests,
                        ),
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: newPrimaryPink,
              disabledBackgroundColor: newPrimaryPink.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              elevation: 0,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(
              'Continue',
              style: GoogleFonts.montserrat(
                color: nextButtonTextColor,
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
