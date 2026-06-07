import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../helpers/database_helper.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  Map<String, dynamic>? selectedRecording;
  List<Map<String, dynamic>> allRecordings = [];
  String feedback = '';
  bool isLoading = false;
  bool feedbackGenerated = false;
  bool recordingNotFound = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = ModalRoute.of(context)?.settings.arguments as int?;
      loadAllRecordings(preSelectId: id);
    });
  }

  Future<void> loadAllRecordings({int? preSelectId}) async {
    final data = await DatabaseHelper.instance.getAllRecordings();
    if (data.isEmpty) {
      setState(() => recordingNotFound = true);
      return;
    }

    setState(() {
      allRecordings = data;
      // Preselect passed ID or default to latest
      if (preSelectId != null) {
        selectedRecording = data.firstWhere(
          (r) => r['id'] == preSelectId,
          orElse: () => data.first,
        );
      } else {
        selectedRecording = data.first;
      }
      // Load existing feedback if any
      if (selectedRecording?['ai_feedback'] != null &&
          selectedRecording!['ai_feedback'].toString().isNotEmpty) {
        feedback = selectedRecording!['ai_feedback'];
        feedbackGenerated = true;
      }
    });
  }

  void onRecordingSelected(Map<String, dynamic> recording) {
    setState(() {
      selectedRecording = recording;
      feedback = '';
      feedbackGenerated = false;
      // Load existing feedback if already generated
      if (recording['ai_feedback'] != null &&
          recording['ai_feedback'].toString().isNotEmpty) {
        feedback = recording['ai_feedback'];
        feedbackGenerated = true;
      }
    });
  }

  Future<void> getFeedback() async {
    if (selectedRecording == null) return;

    final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      setState(() {
        feedback = 'API key not found. Check your .env file.';
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      feedback = '';
    });

    try {
      final prompt = '''
You are a professional speech coach. Analyze this speech and provide detailed feedback.

Speech Data:
- Transcript: ${selectedRecording!['transcript'] ?? 'No transcript'}
- Word Count: ${selectedRecording!['word_count'] ?? 0}
- Filler Words Used: ${selectedRecording!['filler_word_count'] ?? 0}
- Repeated Words: ${selectedRecording!['repeated_word_count'] ?? 0}
- Speaking Speed: ${(selectedRecording!['speaking_speed'] ?? 0.0).toStringAsFixed(1)} WPM
- Overused Words: ${selectedRecording!['frequent_words'] ?? 'None'}

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
          'Authorization': 'Bearer $apiKey',
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
          selectedRecording!['id'],
          {'ai_feedback': feedbackText},
        );

        setState(() {
          feedback = feedbackText;
          feedbackGenerated = true;
          isLoading = false;
        });
      } else {
        setState(() {
          feedback = 'Error: ${response.statusCode}. Check your API key.';
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

    if (selectedRecording == null) {
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
            // Recording picker
            const Text(
              'Select Recording',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepPurple),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: selectedRecording!['id'],
                  items: allRecordings.map((r) {
                    return DropdownMenuItem<int>(
                      value: r['id'],
                      child: Text(
                        '${r['title'] ?? 'Recording'} — ${r['date_created']?.substring(0, 10) ?? ''}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (id) {
                    if (id != null) {
                      final recording = allRecordings
                          .firstWhere((r) => r['id'] == id);
                      onRecordingSelected(recording);
                    }
                  },
                ),
              ),
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
                  Text('Words: ${selectedRecording!['word_count'] ?? 0}'),
                  Text('Filler Words: ${selectedRecording!['filler_word_count'] ?? 0}'),
                  Text('Repeated Words: ${selectedRecording!['repeated_word_count'] ?? 0}'),
                  Text(
                    'Speaking Speed: ${(selectedRecording!['speaking_speed'] ?? 0.0).toStringAsFixed(1)} WPM',
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