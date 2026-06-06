import 'package:flutter/material.dart';

class SpeechAnalysisSection extends StatelessWidget {
  const SpeechAnalysisSection({
    super.key,
    required this.wordCount,
    required this.fillerWordCount,
    required this.repeatedWordCount,
    required this.speakingSpeed,
    required this.frequentWords,
  });

  final int wordCount;
  final int fillerWordCount;
  final int repeatedWordCount;
  final double speakingSpeed;
  final Map<String, int> frequentWords;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 176, 159, 201),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Speech Analysis',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Text('Word Count: $wordCount'),
          Text('Filler Words: $fillerWordCount'),
          Text('Consecutive Repeated Words: $repeatedWordCount'),
          Text('Speaking Speed: ${speakingSpeed.toStringAsFixed(1)} WPM'),
          if (frequentWords.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'Overused Words:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            ...frequentWords.entries.map(
              (e) => Text('  "${e.key}" — used ${e.value} times'),
            ),
          ],
        ],
      ),
    );
  }
}