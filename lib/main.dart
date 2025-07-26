// main.dart
import 'package:dmp/screens/loading_screen.dart'; // Import the new loading screen
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dating App',
      theme: ThemeData(
        // Set the default font family for the entire app
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme, // Use current theme as base
        ),
        // You might want to define your primary color here too for consistency
        // primarySwatch: Colors.pink, // Or create a MaterialColor from your primaryColor
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEEA6B7), // Your primary pink
          primary: const Color(0xFFEEA6B7),
        ),
        appBarTheme: AppBarTheme(
          // Apply font to AppBar titles if not inherited
          titleTextStyle: GoogleFonts.montserrat(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          iconTheme: const IconThemeData(
            color: Colors.black87,
          ), // For back arrow
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: GoogleFonts.montserrat(
              // Font for ElevatedButton text
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        scaffoldBackgroundColor: Colors.white, // Default scaffold background
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoadingScreen(), // Set LoadingScreen as the initial screen
      // home: const CreateAccountGenderScreen(), // Or this one if testing directly
      debugShowCheckedModeBanner: false,
    );
  }
}
