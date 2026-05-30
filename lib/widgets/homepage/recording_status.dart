import 'package:flutter/material.dart';

class RecordingStatusIndicator extends StatelessWidget {
  const RecordingStatusIndicator({
    super.key,
    required this.isRecording,
  });

  final bool isRecording;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: isRecording ? Colors.red.shade100 : Colors.deepPurple.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mic,
            size: 90,
            color: isRecording ? Colors.red : Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 30),
        Text(
          isRecording ? 'Recording...' : 'Ready to Record',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
