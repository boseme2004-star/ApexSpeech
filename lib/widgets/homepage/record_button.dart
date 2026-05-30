import 'package:flutter/material.dart';

class RecordingButton extends StatelessWidget {
  const RecordingButton({
    super.key,
    required this.isRecording,
    required this.onPressed,
  });

  final bool isRecording;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isRecording ? Colors.red : Colors.deepPurple,
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
        onPressed: onPressed,
        child: Text(
          isRecording ? 'Stop Recording' : 'Start Recording',
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
