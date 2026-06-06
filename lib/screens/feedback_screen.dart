import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../helpers/database_helper.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  Map<String, dynamic>? recording;
  String feedback = '';
  bool isLoading = false;
  bool feedbackGenerated = false;
  bool recordingNotFound = false;

  // Move your API key to a config file or environment variable
  static const String _apiKey = 'YOUR_OPENAI_API_KEY_HERE';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = ModalRoute.of(context)?.settings.arguments as int?;
      if (id != null) {
        loadRecording(id);
      } else {
        // No ID passed — load the most recent recording
        loadLatestRecording();
      }
    });
  }

  Future<void> loadLatestRecording() async {
    final recordings = await DatabaseHelper.instance.getRecentRecordings(1);
    if (recordings.isNotEmpty) {
      setState(() {
        recording = recordings.first;
        if (recording?['ai_feedback'] != null &&
            recording!['ai_feedback'].toString().isNotEmpty) {
          feedback = recording!['ai_feedback'];
          feedbackGenerated = true;
        }
      });
    } else {
      setState(() {
        recordingNotFound = true;
      });
    }
  }

  Future<void> loadRecording(int id) async {
    final data = await DatabaseHelper.instance.getRecordingById(id);
    if (data != null) {
      setState(() {
        recording = data;
        if (data['ai_feedback'] != null &&
            data['ai_feedback'].toString().isNotEmpty) {
          feedback = data['ai_feedback'];
          feedbackGenerated = true;
        }
      });
    } else {
      setState(() {
        recordingNotFound = true;
      });
    }
  }

  Future<void> getFeedback() async {
    if (recording == null) return;

    setState(() {
      isLoading = true;
      feedback = '';
    });

    try {
      final prompt = '''
You are a professional speech coach. Analyze this speech and provide detailed feedback.

Speech Data:
- Transcript: ${recording!['transcript'] ?? 'No transcript'}
- Word Count: ${recording!['word_count'] ?? 0}
- Filler Words Used: ${recording!['filler_word_count'] ?? 0}
- Repeated Words: ${recording!['repeated_word_count'] ?? 0}
- Speaking Speed: ${(recording!['speaking_speed'] ?? 0.0).toStringAsFixed(1)} WPM
- Overused Words: ${recording!['frequent_words'] ?? 'None'}

Please provide:
1. Overall Score (out of 10)
2. What the speaker did well
3. Feedback on filler words
4. Feedback on speaking speed (ideal is 120-150 WPM)
5. Feedback on repeated words
6. 3 specific tips to improve

Keep feedback encouraging but honest.
''';

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': 800,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final feedbackText = data['choices'][0]['message']['content'];

        await DatabaseHelper.instance.updateRecording(
          recording!['id'],
          {'ai_feedback': feedbackText},
        );

        setState(() {
          feedback = feedbackText;
          feedbackGenerated = true;
          isLoading = false;
        });
      } else {
        setState(() {
          feedback = 'Error getting feedback. Check your API key and try again.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        feedback = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // No recording found at all
    if (recordingNotFound) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('AI Feedback'),
          backgroundColor: const Color.fromARGB(255, 204, 135, 195),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mic_off, size: 60, color: Colors.grey),
              SizedBox(height: 15),
              Text(
                'No recordings found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Record a speech first to get feedback',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Still loading recording
    if (recording == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Feedback'),
        backgroundColor: const Color.fromARGB(255, 204, 135, 195),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recording title
            Text(
              recording!['title'] ?? 'Recording',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              recording!['date_created']?.substring(0, 16) ?? '',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Summary card
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
                    'Recording Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Words: ${recording!['word_count'] ?? 0}'),
                  Text('Filler Words: ${recording!['filler_word_count'] ?? 0}'),
                  Text('Repeated Words: ${recording!['repeated_word_count'] ?? 0}'),
                  Text(
                    'Speaking Speed: ${(recording!['speaking_speed'] ?? 0.0).toStringAsFixed(1)} WPM',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Get feedback button
            if (!feedbackGenerated)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 204, 135, 195),
                    padding: const EdgeInsets.all(15),
                  ),
                  onPressed: isLoading ? null : getFeedback,
                  child: isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Getting feedback...',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Get AI Feedback',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

            const SizedBox(height: 20),

            // Feedback display
            if (feedback.isNotEmpty)
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
                      'Your Feedback',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      feedback,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    if (feedbackGenerated) ...[
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.all(12),
                          ),
                          onPressed: isLoading ? null : getFeedback,
                          child: const Text(
                            'Regenerate Feedback',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}