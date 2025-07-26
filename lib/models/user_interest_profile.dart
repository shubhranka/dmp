import 'package:flutter/material.dart'; // For IconData if you want icons here too

class UserInterestProfile {
  final String name;
  final String weight; // e.g., "High", "Medium"
  final String role; // e.g., "Cinephile", "Explorer"
  final IconData?
  icon; // Optional: if you want to display icons like in AddInterests

  UserInterestProfile({
    required this.name,
    required this.weight,
    required this.role,
    this.icon,
  });
}
