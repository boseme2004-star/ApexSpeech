import 'dart:io';
import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import 'transcriptions_detail_screen.dart';

class TranscriptionsScreen extends StatefulWidget {
  const TranscriptionsScreen({super.key});

  @override
  State<TranscriptionsScreen> createState() => _TranscriptionsScreenState();
}

class _TranscriptionsScreenState extends State<TranscriptionsScreen> {
  List<Map<String, dynamic>> transcriptions = [];

  @override
  void initState() {
    super.initState();
    loadTranscriptions();
  }

  Future<void> loadTranscriptions() async {
    final data = await DatabaseHelper.instance.getAllRecordings();
    setState(() {
      transcriptions = data;
    });
  }

  Future<void> deleteTranscription(int id, String audioPath) async {
    await DatabaseHelper.instance.deleteRecording(id);
    final file = File(audioPath);
    if (await file.exists()) await file.delete();
    loadTranscriptions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transcriptions'),
        backgroundColor: const Color.fromARGB(255, 204, 135, 195),
      ),
      body: transcriptions.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.transcribe, size: 60, color: Colors.grey),
                  SizedBox(height: 15),
                  Text(
                    'No transcriptions yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Record a speech to see it here',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: transcriptions.length,
              itemBuilder: (context, index) {
                final transcription = transcriptions[index];
                final transcript = transcription['transcript'] ?? '';
                final preview = transcript.isEmpty
                    ? 'No transcription available'
                    : transcript.length > 80
                        ? '${transcript.substring(0, 80)}...'
                        : transcript;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TranscriptionsDetailScreen(
                            transcriptionId: transcription['id'],
                          ),
                        ),
                      ).then((_) => loadTranscriptions());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                transcription['title'] ?? 'Transcription',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red, size: 20),
                                onPressed: () => deleteTranscription(
                                  transcription['id'],
                                  transcription['audio_path'],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            preview,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _statChip(
                                Icons.text_fields,
                                '${transcription['word_count'] ?? 0} words',
                              ),
                              const SizedBox(width: 8),
                              _statChip(
                                Icons.speed,
                                '${(transcription['speaking_speed'] ?? 0.0).toStringAsFixed(1)} WPM',
                              ),
                              const SizedBox(width: 8),
                              _statChip(
                                Icons.calendar_today,
                                transcription['date_created']
                                        ?.substring(0, 10) ??
                                    '',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _statChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 240, 225, 255),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.deepPurple),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.deepPurple),
          ),
        ],
      ),
    );
  }
}