import 'dart:convert';
import 'package:dmp/constants/api_constants.dart';
import 'package:dmp/models/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserProfile> getProfileById(String userId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Not authenticated.');
    }

    final idToken = await user.getIdToken();
    final url = Uri.parse('$kApiBaseUrl/v1/users/$userId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        // We can reuse the same UserProfile model!
        return  UserProfile.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching profile: $e');
    }
  }
}