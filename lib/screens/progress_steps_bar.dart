// progress_steps_bar.dart
import 'package:flutter/material.dart';

// You can move these color constants to a shared app_colors.dart file later
const Color kPrimaryPinkColor = Color(0xFFE91E63);
const Color kInactiveProgressColor = Color(0xFFE0E0E0);

class ProgressStepsBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProgressStepsBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  }) : assert(
         currentStep > 0 && currentStep <= totalSteps,
         'Current step must be between 1 and totalSteps inclusive.',
       );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Row(
        children: List.generate(totalSteps, (index) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              height: 6.0,
              decoration: BoxDecoration(
                color: (index + 1) <= currentStep
                    ? kPrimaryPinkColor
                    : kInactiveProgressColor,
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
          );
        }),
      ),
    );
  }
}
