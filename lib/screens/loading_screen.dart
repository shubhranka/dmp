import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dmp/screens/find_your_spark_screen.dart'; // Import your initial app screen

// --- Color Constants (consistent with your app's theme) ---
const Color primaryAppColor = Color(0xFFE91E63); // Main pink
const Color appBarTitleColor = Colors.black87;

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    // Simulate a loading process, e.g., fetching user session, initial data
    await Future.delayed(const Duration(seconds: 3)); // Adjust delay as needed

    if (!mounted) return; // Check if the widget is still in the tree

    // Navigate to the main entry point of your app after loading
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const FindYourSparkScreen()),
    ); // Assuming FindYourSparkScreen is your next entry
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Or your app's preferred background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Your App Logo or a placeholder icon
            Icon(
              Icons.favorite, // Using a heart icon as a placeholder
              color: primaryAppColor,
              size: 80.0,
            ),
            const SizedBox(height: 24.0),

            // App Title
            Text(
              'Find Your Spark', // Your app's main title
              style: GoogleFonts.montserrat(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                color: appBarTitleColor,
              ),
            ),
            const SizedBox(height: 30.0),

            // Loading Indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryAppColor),
              strokeWidth: 4.0,
            ),
            const SizedBox(height: 80.0), // Spacing from bottom
          ],
        ),
      ),
    );
  }
}
