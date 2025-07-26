// lib/screens/record_audio_intro_screen.dart

import 'dart:async'; // For Timer
import 'package:dmp/screens/craft_opening_question_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import '../screens/progress_steps_bar.dart';

const Color primaryAppColor = Color(0xFFE91E63);
const Color lightPinkBackground = Color(0xFFFCE4EC);
const Color appBarTitleColor = Colors.black87;
const Color bodyTextColor = Colors.black87;
const Color subtitleTextColor = Color(0xFF616161);
const Color progressTrackColor = Color(0xFFF8BBD0);

enum AudioState { initial, recording, recorded, playing, paused }

class RecordAudioIntroScreen extends StatefulWidget {
  // Now accepts all data from the previous screens
  final String gender;
  final String pronouns;
  final List<String> sexualInterests;
  final List<String> generalInterests;

  const RecordAudioIntroScreen({
    super.key,
    required this.gender,
    required this.pronouns,
    required this.sexualInterests,
    required this.generalInterests,
  });

  @override
  State<RecordAudioIntroScreen> createState() => _RecordAudioIntroScreenState();
}

class _RecordAudioIntroScreenState extends State<RecordAudioIntroScreen> {
  AudioState _audioState = AudioState.initial;
  double _currentProgress = 0.0;
  int _currentSeconds = 0;
  int _recordedDuration = 0;
  final int _maxSeconds = 15;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startRecording() {
    _timer?.cancel();
    setState(() {
      _audioState = AudioState.recording;
      _currentProgress = 0.0;
      _currentSeconds = 0;
      _recordedDuration = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSeconds >= _maxSeconds - 1) {
        setState(() {
          _currentSeconds = _maxSeconds;
          _currentProgress = 1.0;
        });
        _stopRecording();
      } else {
        setState(() {
          _currentSeconds++;
          _currentProgress = _currentSeconds / _maxSeconds;
        });
      }
    });
  }

  void _stopRecording() {
    _timer?.cancel();
    setState(() {
      _audioState = AudioState.recorded;
      _recordedDuration = _currentSeconds;
      _currentProgress = 0.0;
      _currentSeconds = 0;
    });
  }

  void _startPlaying() {
    if (!(_audioState == AudioState.recorded ||
            _audioState == AudioState.paused) ||
        _recordedDuration == 0)
      return;

    _timer?.cancel();
    setState(() {
      _audioState = AudioState.playing;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSeconds >= _recordedDuration - 1) {
        _stopPlaying(playedToEnd: true);
      } else {
        setState(() {
          _currentSeconds++;
          _currentProgress = _recordedDuration > 0
              ? _currentSeconds / _recordedDuration
              : 0.0;
        });
      }
    });
  }

  void _pausePlaying() {
    _timer?.cancel();
    setState(() {
      _audioState = AudioState.paused;
    });
  }

  void _stopPlaying({bool playedToEnd = false}) {
    _timer?.cancel();
    setState(() {
      _audioState = AudioState.recorded;
      if (playedToEnd) {
        _currentSeconds = 0;
        _currentProgress = 0.0;
      }
    });
  }

  void _reRecord() {
    _timer?.cancel();
    setState(() {
      _audioState = AudioState.initial;
      _currentProgress = 0.0;
      _currentSeconds = 0;
      _recordedDuration = 0;
    });
  }

  void _navigateToNextScreen() {
    // Helper function to pass all data to the next screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CraftOpeningQuestionScreen(
          gender: widget.gender,
          pronouns: widget.pronouns,
          sexualInterests: widget.sexualInterests,
          generalInterests: widget.generalInterests,
        ),
      ),
    );
  }

  Widget _buildRecordingArea() {
    String timeLabel;
    IconData mainIconData;
    VoidCallback? mainIconAction;
    String recordButtonText = "Tap to record";
    double linearIndicatorProgress = _currentProgress;

    if (_audioState == AudioState.initial) {
      mainIconData = Icons.mic_none_outlined;
      mainIconAction = _startRecording;
      timeLabel = "00 / ${_maxSeconds.toString().padLeft(2, '0')}";
      linearIndicatorProgress = 0.0;
    } else if (_audioState == AudioState.recording) {
      mainIconData = Icons.stop_circle_outlined;
      mainIconAction = _stopRecording;
      recordButtonText = "Recording...";
      timeLabel =
          "${_currentSeconds.toString().padLeft(2, '0')} / ${_maxSeconds.toString().padLeft(2, '0')}";
      linearIndicatorProgress = _currentSeconds / _maxSeconds;
    } else {
      if (_audioState == AudioState.playing) {
        mainIconData = Icons.pause_circle_filled_outlined;
        mainIconAction = _pausePlaying;
      } else {
        mainIconData = Icons.play_circle_filled_outlined;
        mainIconAction = _startPlaying;
      }
      timeLabel =
          "${_currentSeconds.toString().padLeft(2, '0')} / ${_recordedDuration.toString().padLeft(2, '0')}";
      linearIndicatorProgress = _recordedDuration > 0
          ? _currentSeconds / _recordedDuration
          : 0.0;
    }
    if (linearIndicatorProgress.isNaN || linearIndicatorProgress.isInfinite) {
      linearIndicatorProgress = 0.0;
    }
    if (linearIndicatorProgress > 1.0) linearIndicatorProgress = 1.0;
    if (linearIndicatorProgress < 0.0) linearIndicatorProgress = 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: lightPinkBackground,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_audioState == AudioState.initial) ...[
            GestureDetector(
              onTap: mainIconAction,
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: primaryAppColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(mainIconData, color: primaryAppColor, size: 50),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              recordButtonText,
              style: GoogleFonts.montserrat(
                color: primaryAppColor,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(mainIconData, color: primaryAppColor, size: 50),
                  onPressed: mainIconAction,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: linearIndicatorProgress,
                        backgroundColor: progressTrackColor,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          primaryAppColor,
                        ),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        timeLabel,
                        style: GoogleFonts.montserrat(
                          color: bodyTextColor.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            TextButton(
              onPressed: _reRecord,
              child: Text(
                "Re-record",
                style: GoogleFonts.montserrat(
                  color: primaryAppColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: appBarTitleColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Audio Intro',
          style: GoogleFonts.montserrat(
            color: appBarTitleColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const ProgressStepsBar(
              currentStep: 4,
              totalSteps: kTotalAccountCreationSteps,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        'Record an Audio Intro',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 26.0,
                          fontWeight: FontWeight.bold,
                          color: bodyTextColor,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        'Share a short (10-15 sec) audio intro to give potential matches a glimpse of your personality before photos are revealed. This is optional, but recommended!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 15.0,
                          color: subtitleTextColor,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      _buildRecordingArea(),
                      const SizedBox(height: 60.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed:
                    (_audioState == AudioState.recorded &&
                            _recordedDuration > 0) ||
                        _audioState == AudioState.paused
                    ? _navigateToNextScreen
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryAppColor,
                  disabledBackgroundColor: primaryAppColor.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  'Continue',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              TextButton(
                onPressed: _navigateToNextScreen, // Also navigates on skip
                child: Text(
                  'Skip for now',
                  style: GoogleFonts.montserrat(
                    color: primaryAppColor,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
