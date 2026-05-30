import 'package:flutter/material.dart';

class TranscriptionPanel extends StatelessWidget {
  const TranscriptionPanel({
    super.key,
    required this.recognizedText,
  });

  final String recognizedText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Speech Text',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            recognizedText.isEmpty ? 'Speech will appear here...' : recognizedText,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
