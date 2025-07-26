// lib/screens/home_screen.dart

import 'package:dmp/services/auth_service.dart';
import 'package:dmp/screens/find_your_spark_screen.dart'; // To navigate on sign out
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color primaryAppColor = Color(0xFFE91E63);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current user to display their name
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        // actions: [
        //   // Add a sign out button for easy testing
        //   IconButton(
        //     icon: const Icon(Icons.logout, color: Colors.black87),
        //     onPressed: () async {
        //       await AuthService().signOut();
        //       if (context.mounted) {
        //         // Navigate back to the login screen and remove all previous routes
        //         Navigator.of(context).pushAndRemoveUntil(
        //           MaterialPageRoute(
        //             builder: (context) => const FindYourSparkScreen(),
        //           ),
        //           (Route<dynamic> route) => false,
        //         );
        //       }
        //     },
        //   ),
        // ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite, size: 80, color: primaryAppColor),
              const SizedBox(height: 24),
              Text(
                'Welcome to Spark, ${user?.displayName ?? 'User'}!',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Navigate to the Discover tab to find your spark.',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
