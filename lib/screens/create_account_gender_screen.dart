import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'create_account_interests_screen.dart';
import 'progress_steps_bar.dart'; // Import the new progress bar
import '../constants/app_constants.dart';

// --- Color Constants ---
const Color newPrimaryPink = Color(0xFFE91E63);
const Color newLightPinkBackground = Color(0xFFFCE4EC);
const Color nextButtonTextColor = Colors.white;
const Color textFieldBorderColor = Color(0xFFBDBDBD);
const Color appBarTitleColor = Colors.black87;
const Color bodyTextColor = Colors.black87;
const Color subtitleTextColor = Color(0xFF616161);
const Color hintTextColor = Color(0xFF9E9E9E);
const Color defaultOptionBorderColor = Color(
  0xFFE0E0E0,
); // Added back for options
// --- End Color Constants ---

class CreateAccountGenderScreen extends StatefulWidget {
  const CreateAccountGenderScreen({super.key});

  @override
  State<CreateAccountGenderScreen> createState() =>
      _CreateAccountGenderScreenState();
}

class _CreateAccountGenderScreenState extends State<CreateAccountGenderScreen> {
  String? _selectedGender;
  final TextEditingController _pronounsController = TextEditingController();

  final List<Map<String, String>> _genderOptions = [
    {'label': 'Woman', 'value': 'Woman'},
    {'label': 'Man', 'value': 'Man'},
    {'label': 'Non-binary', 'value': 'Non-binary'},
    {
      'label': 'Other',
      'value': 'Other',
      'subtitle': 'You can specify this later if you\'d like.',
    },
  ];

  // _buildProgressBar method is now removed, using ProgressStepsBar widget directly

  Widget _buildGenderOption({
    required String label,
    required String value,
    String? subtitle,
  }) {
    bool isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected ? newLightPinkBackground : Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? newPrimaryPink : defaultOptionBorderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedGender,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
              activeColor: newPrimaryPink,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.montserrat(
                      fontSize: 16.0,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: bodyTextColor,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        subtitle,
                        style: GoogleFonts.montserrat(
                          fontSize: 12.0,
                          color: subtitleTextColor,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool canProceed = _selectedGender != null && _selectedGender!.isNotEmpty;

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
              currentStep: 1, // This is Step 1
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
                            Icons.people_alt_outlined,
                            color: newPrimaryPink,
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "What's your gender identity?",
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
                        "This helps us find the best matches for you. Your gender identity will be visible on your profile.",
                        style: GoogleFonts.montserrat(
                          fontSize: 14.0,
                          color: subtitleTextColor,
                          height: 1.4,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    ..._genderOptions.map((option) {
                      return _buildGenderOption(
                        label: option['label']!,
                        value: option['value']!,
                        subtitle: option['subtitle'],
                      );
                    }).toList(),
                    const SizedBox(height: 30.0),
                    Text(
                      "Preferred Pronouns (Optional)",
                      style: GoogleFonts.montserrat(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                        color: bodyTextColor,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    TextField(
                      controller: _pronounsController,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: bodyTextColor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g., she/her, he/him, they/them',
                        hintStyle: GoogleFonts.montserrat(
                          color: hintTextColor,
                          fontSize: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: textFieldBorderColor,
                            width: 1.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: textFieldBorderColor,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: newPrimaryPink,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 14.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      "This will also be visible on your profile.",
                      style: GoogleFonts.montserrat(
                        fontSize: 13.0,
                        color: subtitleTextColor,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateAccountInterestsScreen(
                          // Navigates to "Who are you interested in"
                          gender: _selectedGender!,
                          pronouns: _pronounsController.text,
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
              'Next',
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

  @override
  void dispose() {
    _pronounsController.dispose();
    super.dispose();
  }
}
