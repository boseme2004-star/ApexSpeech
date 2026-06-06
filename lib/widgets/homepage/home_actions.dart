import 'package:flutter/material.dart';

class HomeActionButtons extends StatelessWidget {
  const HomeActionButtons({
    super.key,
    required this.audioPath,
    required this.onPlayback,
    required this.onFeedback,
    required this.onViewRecordings,
  });

  final String? audioPath;
  final VoidCallback onPlayback;
  final VoidCallback onFeedback;
  final VoidCallback onViewRecordings;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: audioPath == null ? null : onPlayback,
            child: const Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                'Playback',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onFeedback,
            child: const Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                'Feedback',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onViewRecordings,
            child: const Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                'View Transcripts',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
