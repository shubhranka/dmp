import 'package:dmp/models/user_profile.dart';
import 'package:dmp/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Re-using colors from other screens for consistency
const Color kPrimaryPink = Color(0xFFE91E63);
const Color kAppBarTitleColor = Colors.black87;
const Color kBodyTextColor = Colors.black87;
const Color kSubtitleColor = Color(0xFF616161);
const Color kTextFieldBorderColor = Color(0xFFBDBDBD);
const Color kHintTextColor = Color(0xFF9E9E9E);

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Controllers and state variables for the form fields
  late TextEditingController _pronounsController;
  late TextEditingController _openingQuestionController;
  late TextEditingController _dealbreakersController;
  late String _selectedGender;
  late Set<String> _selectedSexualInterests;
  late Set<String> _selectedGeneralInterests;

  final List<String> _genderOptions = ['Woman', 'Man', 'Non-binary', 'Other'];
  final List<String> _sexualInterestOptions = ['Women', 'Men', 'Non-binary people'];

  @override
  void initState() {
    super.initState();
    final p = widget.profile.onboardingProfile;

    // Initialize all state from the passed profile data
    _selectedGender = p?.gender ?? 'Woman';
    _pronounsController = TextEditingController(text: p?.pronouns ?? '');
    _openingQuestionController = TextEditingController(text: p?.openingQuestion ?? '');
    _dealbreakersController = TextEditingController(text: p?.dealbreakers ?? '');
    _selectedSexualInterests = p?.sexualOrientation.toSet() ?? {};
    _selectedGeneralInterests = p?.generalInterests.toSet() ?? {};
  }

  @override
  void dispose() {
    _pronounsController.dispose();
    _openingQuestionController.dispose();
    _dealbreakersController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return; // Don't proceed if form is invalid
    }

    setState(() => _isLoading = true);

    try {
      // The service method will return true on success
      bool success = await _authService.updateProfile(
        gender: _selectedGender,
        pronouns: _pronounsController.text,
        sexualOrientation: _selectedSexualInterests.toList(),
        generalInterests: _selectedGeneralInterests.toList(),
        openingQuestion: _openingQuestionController.text,
        dealbreakers: _dealbreakersController.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
        );
        // Pop the screen, returning 'true' to indicate success
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: GoogleFonts.montserrat(color: kAppBarTitleColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[100],
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('My Gender Identity'),
              _buildDropdown(_genderOptions, _selectedGender, (val) {
                setState(() => _selectedGender = val!);
              }),
              const SizedBox(height: 20),

              _buildSectionTitle('My Pronouns'),
              _buildTextFormField(_pronounsController, 'e.g., she/her, they/them'),
              const SizedBox(height: 20),

              _buildSectionTitle('I am interested in...'),
              _buildMultiSelectChip(_sexualInterestOptions, _selectedSexualInterests),
              const SizedBox(height: 20),

              _buildSectionTitle('My Interests'),
              _buildInterestInput(),
              const SizedBox(height: 20),

              _buildSectionTitle('My Opening Question'),
              _buildTextFormField(_openingQuestionController, 'Your captivating question...', maxLines: 3),
              const SizedBox(height: 20),

              _buildSectionTitle('My Dealbreakers'),
              _buildTextFormField(_dealbreakersController, 'e.g., Prefers cats over dogs...', maxLines: 4),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: kPrimaryPink))
              : ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryPink,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text('Save Changes', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 17.0, fontWeight: FontWeight.bold)),
                ),
        ),
      ),
    );
  }

  // --- Reusable Form Field Widgets ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: kBodyTextColor),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String currentValue, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kTextFieldBorderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentValue,
          isExpanded: true,
          items: items.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
  
  Widget _buildMultiSelectChip(List<String> options, Set<String> selected) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (bool newSelectedValue) {
            setState(() {
              if (newSelectedValue) {
                selected.add(option);
              } else {
                selected.remove(option);
              }
            });
          },
          selectedColor: kPrimaryPink.withOpacity(0.2),
          labelStyle: TextStyle(color: isSelected ? kPrimaryPink : kBodyTextColor, fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: isSelected ? kPrimaryPink : kTextFieldBorderColor),
          ),
          backgroundColor: Colors.white,
        );
      }).toList(),
    );
  }

  Widget _buildInterestInput() {
    // This is a simplified version. A real app might have a more complex tag input.
    final interestController = TextEditingController();
    return Column(
      children: [
        TextFormField(
          controller: interestController,
          decoration: InputDecoration(
            hintText: 'Type an interest and press enter',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle, color: kPrimaryPink),
              onPressed: () {
                if(interestController.text.isNotEmpty) {
                  setState(() {
                    _selectedGeneralInterests.add(interestController.text.trim());
                    interestController.clear();
                  });
                }
              },
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kTextFieldBorderColor)),
          ),
          onFieldSubmitted: (value) {
             if(value.isNotEmpty) {
                setState(() {
                  _selectedGeneralInterests.add(value.trim());
                  interestController.clear();
                });
              }
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _selectedGeneralInterests.map((interest) {
            return Chip(
              label: Text(interest),
              onDeleted: () {
                setState(() {
                  _selectedGeneralInterests.remove(interest);
                });
              },
              deleteIconColor: kPrimaryPink,
              backgroundColor: kPrimaryPink.withOpacity(0.1),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: kHintTextColor),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kTextFieldBorderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kTextFieldBorderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kPrimaryPink, width: 2)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field cannot be empty';
        }
        return null;
      },
    );
  }
}