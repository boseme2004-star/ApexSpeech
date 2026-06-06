import 'dart:convert';
import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';

class TranscriptionsDetailScreen extends StatefulWidget {
  final int transcriptionId;

  const TranscriptionsDetailScreen({super.key, required this.transcriptionId});

  @override
  State<TranscriptionsDetailScreen> createState() => _TranscriptionsDetailScreenState();
}

class _TranscriptionsDetailScreenState extends State<TranscriptionsDetailScreen> {
  Map<String, dynamic>? transcription;

  @override
  void initState() {
    super.initState();
    loadTranscription();
  }

  Future<void> loadTranscription() async {
    final data =
        await DatabaseHelper.instance.getRecordingById(widget.transcriptionId);
    setState(() {
      transcription = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (transcription == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    Map<String, int> frequentWords = {};
    if (transcription!['frequent_words'] != null) {
      final decoded = jsonDecode(transcription!['frequent_words']);
      frequentWords = Map<String, int>.from(decoded);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(transcription!['title'] ?? 'Transcription Detail'),
        backgroundColor: const Color.fromARGB(255, 204, 135, 195),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date
            Text(
              transcription!['date_created']?.substring(0, 16) ?? '',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Analysis Card
            Container(
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text('Word Count: ${transcription!['word_count'] ?? 0}'),
                  Text(
                      'Filler Words: ${transcription!['filler_word_count'] ?? 0}'),
                  Text(
                      'Repeated Words: ${transcription!['repeated_word_count'] ?? 0}'),
                  Text(
                      'Speaking Speed: ${(transcription!['speaking_speed'] ?? 0.0).toStringAsFixed(1)} WPM'),
                  if (frequentWords.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text(
                      'Overused Words:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...frequentWords.entries.map(
                      (e) => Text('  "${e.key}" — used ${e.value} times'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Transcript Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transcript',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    transcription!['transcript']?.isEmpty ?? true
                        ? 'No transcript available'
                        : transcription!['transcript'],
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // AI Feedback Card
            if (transcription!['ai_feedback'] != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Feedback',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      transcription!['ai_feedback'],
                      style:
                          const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}