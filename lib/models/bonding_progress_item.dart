// lib/models/bonding_progress_item.dart
import 'package:flutter/material.dart';

enum BondingStatus { unlocked, locked, percentage }

class BondingProgressItem {
  final String title;
  final BondingStatus status;
  final int? percentage; // Only used if status is percentage
  final IconData icon;
  final Color activeColor;
  final Color inactiveColor;

  BondingProgressItem({
    required this.title,
    required this.status,
    this.percentage,
    required this.icon,
    this.activeColor = const Color(0xFFE91E63), // Default Pink
    this.inactiveColor = const Color(0xFFBDBDBD), // Default Grey
  });
}

// lib/models/user_value.dart
class UserValue {
  final String name;
  UserValue({required this.name});
}

// Ensure UserInterestProfile model is still available from previous steps
// lib/models/user_interest_profile.dart
// class UserInterestProfile {
//   final String name;
//   final String weight;
//   final String role;
//   final IconData? icon;
//   UserInterestProfile({required this.name, required this.weight, required this.role, this.icon});
// }
