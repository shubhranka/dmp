import 'dart:convert';
import 'package:dmp/constants/api_constants.dart';
import 'package:dmp/models/match_profile.dart'; // We'll update this model slightly
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class MatchService {
  // Fetches the list of potential matches for the currently logged-in user
  Future<List<MatchProfile>> getPotentialMatches() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // If no user is logged in, they can't have matches.
      throw Exception('User not logged in. Cannot fetch matches.');
    }

    final idToken = await user.getIdToken();
    if (idToken == null) {
      throw Exception('Could not retrieve auth token.');
    }

    final url = Uri.parse('$kApiBaseUrl/v1/matches');
    print('Fetching matches from: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        // The API returns a list of JSON objects. We need to decode it.
        List<dynamic> responseBody = json.decode(response.body);

        // Convert the list of JSON maps into a list of MatchProfile objects.
        List<MatchProfile> matches = responseBody
            .map((data) => MatchProfile.fromJson(data))
            .toList();

        print('Successfully fetched ${matches.length} matches.');
        return matches;
      } else {
        // Handle server errors
        print('Failed to fetch matches. Status: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('Failed to load matches from server.');
      }
    } catch (e) {
      // Handle network errors
      print('An error occurred while fetching matches: $e');
      throw Exception('An error occurred while fetching matches: $e');
    }
  }
}
