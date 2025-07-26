// lib/services/auth_service.dart

import 'dart:convert';
import 'package:dmp/constants/api_constants.dart';
import 'package:dmp/models/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

// Helper class to hold the result of our sync operation
class SyncResult {
  final User user;
  final bool isOnboardingComplete;

  SyncResult({required this.user, required this.isOnboardingComplete});
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // This function now returns our custom SyncResult object
  Future<SyncResult?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user != null) {
        final String? idToken = await user.getIdToken(true);
        if (idToken != null) {
          print("Firebase User signed in: ${user.displayName}");
          // The sync function now returns the onboarding status
          final bool? onboardingComplete = await _syncUserWithBackend(idToken);

          if (onboardingComplete != null) {
            return SyncResult(
              user: user,
              isOnboardingComplete: onboardingComplete,
            );
          } else {
            await signOut();
            return null;
          }
        }
      }
    } catch (e) {
      print("An unexpected error occurred during sign in: $e");
      return null;
    }
    return null;
  }

  // This function now returns a bool? (nullable boolean) for the onboarding status
  Future<bool?> _syncUserWithBackend(String token) async {
    final url = Uri.parse('$kApiBaseUrl/v1/auth/sync');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("User synced successfully. Status: ${response.statusCode}");
        final responseBody = json.decode(response.body);
        // Parse the boolean from the response
        return responseBody['is_onboarding_complete'] as bool;
      } else {
        print("Failed to sync user. Status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error calling backend for sync: $e");
      return null;
    }
  }

  Future<UserProfile> getMyProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Not authenticated. Cannot fetch profile.');
    }

    final idToken = await user.getIdToken();
    final url = Uri.parse('$kApiBaseUrl/v1/me');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        return UserProfile.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching profile: $e');
    }
  }

  Future<bool> updateProfile({
    required String gender,
    required String pronouns,
    required List<String> sexualOrientation,
    required List<String> generalInterests,
    required String openingQuestion,
    required String dealbreakers,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in.');
    }
    final idToken = await user.getIdToken();

    final url = Uri.parse('$kApiBaseUrl/v1/onboarding');
    final body = json.encode({
      'gender': gender,
      'pronouns': pronouns,
      'sexual_orientation': sexualOrientation,
      'general_interests': generalInterests,
      'opening_question': openingQuestion,
      'dealbreakers': dealbreakers,
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

      if (response.statusCode == 200) {
        print('Profile updated successfully.');
        return true;
      } else {
        print('Failed to update profile. Status: ${response.statusCode}');
        print('Response: ${response.body}');
        final error =
            json.decode(response.body)['error'] ?? 'Unknown server error';
        throw Exception(error);
      }
    } catch (e) {
      print('An error occurred during profile update: $e');
      throw Exception('Could not connect to the server.');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
