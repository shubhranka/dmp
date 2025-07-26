// lib/screens/find_your_spark_screen.dart

import 'package:dmp/screens/create_account_gender_screen.dart';
import 'package:dmp/screens/discover_screen.dart'; // Import the matches screen
import 'package:dmp/screens/main_screen.dart';
import 'package:dmp/services/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFFE91E63);
const Color googleButtonBackgroundColor = Color(0xFFF5F5F5);

class FindYourSparkScreen extends StatefulWidget {
  const FindYourSparkScreen({super.key});

  @override
  State<FindYourSparkScreen> createState() => _FindYourSparkScreenState();
}

class _FindYourSparkScreenState extends State<FindYourSparkScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // The auth service now returns our custom SyncResult object
      final SyncResult? result = await _authService.signInWithGoogle();

      if (result != null && mounted) {
        if (result.isOnboardingComplete) {
          // If onboarding is complete, go directly to the MAIN screen
          print("Onboarding complete. Navigating to MainScreen.");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainScreen(),
            ), // <-- CHANGE HERE
          );
        } else {
          // Otherwise, start the onboarding flow
          print(
            "User is new or onboarding is incomplete. Navigating to CreateAccountGenderScreen.",
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateAccountGenderScreen(),
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Sign-In failed. Please try again.'),
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
    // The UI of this screen remains exactly the same as before
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Spacer(),
              const Icon(Icons.favorite, color: primaryColor, size: 80.0),
              const SizedBox(height: 24.0),
              const Text(
                'Find Your Spark',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                'Meaningful connections start here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
              ),
              const SizedBox(height: 60.0),

              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                )
              else
                ElevatedButton.icon(
                  icon: Image.asset(
                    'assets/google_logo.png',
                    height: 24.0,
                    width: 24.0,
                  ),
                  label: const Text(
                    'Continue with Google',
                    style: TextStyle(fontSize: 16.0, color: Colors.black87),
                  ),
                  onPressed: _handleGoogleSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: googleButtonBackgroundColor,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    elevation: 1,
                  ),
                ),
              const Spacer(),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
                  children: <TextSpan>[
                    const TextSpan(text: 'By continuing, you agree to our '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: const TextStyle(
                        color: primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          /* Handle tap */
                        },
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: const TextStyle(
                        color: primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          /* Handle tap */
                        },
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
