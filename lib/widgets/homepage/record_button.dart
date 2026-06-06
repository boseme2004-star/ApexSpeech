import 'package:flutter/material.dart';

class RecordingButton extends StatelessWidget {
  const RecordingButton({
    super.key,
    required this.isRecording,
    required this.onPressed,
    this.isDisabled = false,
  });

  final bool isRecording;
  final VoidCallback? onPressed;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? Colors.grey
              : isRecording
                  ? Colors.red
                  : const Color.fromARGB(255, 204, 135, 195),
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
        onPressed: onPressed,
        child: Text(
          isDisabled
              ? 'Transcribing...'
              : isRecording
                  ? 'Stop Recording'
                  : 'Start Recording',
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}