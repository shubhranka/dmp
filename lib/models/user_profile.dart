// This represents the onboarding data
class OnboardingProfile {
  final String gender;
  final String pronouns;
  final List<String> sexualOrientation;
  final List<String> generalInterests;
  final String openingQuestion;
  final String? dealbreakers;

  OnboardingProfile({
    required this.gender,
    required this.pronouns,
    required this.sexualOrientation,
    required this.generalInterests,
    required this.openingQuestion,
    required this.dealbreakers,
  });

  factory OnboardingProfile.fromJson(Map<String, dynamic> json) {
    return OnboardingProfile(
      gender: json['gender'] ?? '',
      pronouns: json['pronouns'] ?? '',
      sexualOrientation: List<String>.from(json['sexual_orientation'] ?? []),
      generalInterests: List<String>.from(json['general_interests'] ?? []),
      openingQuestion: json['opening_question'] ?? '',
      dealbreakers: json['dealbreakers'] ?? '',
    );
  }
}

// This represents the full user profile object from /v1/me
class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final OnboardingProfile? onboardingProfile; // Nullable

  UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.onboardingProfile,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: "eamil",
      displayName: json['display_name'],
      // Check if onboarding_profile is not null before parsing
      onboardingProfile: json['onboarding_profile'] != null
          ? OnboardingProfile.fromJson(json['onboarding_profile'])
          : null,
    );
  }
}