// lib/models/match_profile.dart
class MatchProfile {
  final String id; // This will now be the user_id from the backend
  final String displayName; // e.g., "Female", "Male"
  final String avatarAssetPath; // Path to a local asset for the avatar
  final String matchReason;
  final String openingQuestion;
  // We'll keep these for the UI, but they won't come from the V1 backend
  final bool hasAudioIntro;
  final bool? customIconFlag;

  MatchProfile({
    required this.id,
    required this.displayName,
    required this.avatarAssetPath,
    required this.matchReason,
    required this.openingQuestion,
    required this.hasAudioIntro,
    this.customIconFlag,
  });

  // *** FACTORY CONSTRUCTOR TO PARSE JSON ***
  // This allows us to create a MatchProfile object from a map (decoded JSON)
  factory MatchProfile.fromJson(Map<String, dynamic> json) {
    // We can add logic here to choose an avatar based on gender
    String avatar;
    if (json['display_name'].toString().toLowerCase() == 'woman') {
      avatar = 'assets/avatars/girl-1.png'; // Default female avatar
    } else if (json['display_name'].toString().toLowerCase() == 'man') {
      avatar = 'assets/avatars/boy-1.png'; // Default male avatar
    } else {
      avatar = 'assets/avatars/avatar_placeholder.png'; // A generic placeholder
    }

    return MatchProfile(
      id: json['user_id'] ?? 'unknown_id',
      displayName: json['display_name'] ?? 'Unknown',
      avatarAssetPath: avatar,
      matchReason: json['match_reason'] ?? 'Compatible interests.',
      openingQuestion: json['opening_question'] ?? 'No opening question set.',
      // For now, these are hardcoded as we don't get them from the backend yet
      hasAudioIntro: true,
      customIconFlag: false,
    );
  }
}
