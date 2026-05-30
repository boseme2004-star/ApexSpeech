import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'recordings_screen.dart';
import '../widgets/homepage/analysis_section.dart';
import '../widgets/homepage/home_actions.dart';
import '../widgets/homepage/home_app_bar.dart';
import '../widgets/homepage/record_button.dart';
import '../widgets/homepage/recording_status.dart';
import '../widgets/homepage/transcription_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioRecorder audioRecorder = AudioRecorder();
  final SpeechToText speechToText = SpeechToText();

  bool isRecording = false;
  String? audioPath;
  String recognizedText = '';
  int wordCount = 0;
  int fillerWordCount = 0;
  int repeatedWordCount = 0;
  double speakingSpeed = 0;
  DateTime? recordingStartTime;

  final List<String> fillerWords = [
    'um',
    'uh',
    'like',
    'you know',
    'basically',
    'actually',
    'literally',
  ];

  Future<void> _startListening() async {
    if (speechToText.isListening) return;
    await speechToText.listen(
      onResult: (result) {
        setState(() {
          recognizedText = result.recognizedWords;
          analyzeSpeech();
        });
        print('STT RESULT: ${result.recognizedWords}');
      },
      listenOptions: SpeechListenOptions(
        listenFor: const Duration(minutes: 30),
        pauseFor: const Duration(seconds: 10),
        partialResults: true,
        cancelOnError: false,
      ),
    );
  }

  Future<void> startRecording() async {
    try {
      bool permission = await audioRecorder.hasPermission();

      if (!permission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission denied')),
        );
        return;
      }

      bool speechEnabled = await speechToText.initialize(
        onStatus: (status) {
          print('STT STATUS: $status');
          if (status == 'done' && isRecording) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (isRecording && mounted) {
                _startListening();
              }
            });
          }
        },
        onError: (error) {
          print('STT ERROR: ${error.errorMsg}');
          if (error.errorMsg != 'error_busy' && isRecording) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (isRecording && mounted) {
                _startListening();
              }
            });
          }
        },
      );

      print('STT INITIALIZED: $speechEnabled');

      if (!speechEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition unavailable')),
        );
        return;
      }

      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';

      await audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      await _startListening();

      recordingStartTime = DateTime.now();

      if (!mounted) return;

      setState(() {
        isRecording = true;
        audioPath = path;
      });
    } catch (e) {
      print('START RECORDING ERROR: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recording Error: $e')),
      );
    }
  }

  Future<void> stopRecording() async {
    try {
      final path = await audioRecorder.stop();
      await speechToText.stop();
      calculateSpeakingSpeed();

      if (!mounted) return;

      setState(() {
        isRecording = false;
        audioPath = path;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recording Saved Successfully')),
      );
    } catch (e) {
      print('STOP RECORDING ERROR: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stop Recording Error: $e')),
      );
    }
  }

  void analyzeSpeech() {
    final words = recognizedText.toLowerCase().split(' ');
    wordCount = words.length;
    fillerWordCount = 0;

    for (final filler in fillerWords) {
      fillerWordCount += words.where((word) => word == filler).length;
    }

    repeatedWordCount = 0;
    for (var i = 1; i < words.length; i++) {
      if (words[i] == words[i - 1]) {
        repeatedWordCount++;
      }
    }
  }

  void calculateSpeakingSpeed() {
    if (recordingStartTime == null) return;

    final durationInMinutes =
        DateTime.now().difference(recordingStartTime!).inSeconds / 60;

    if (durationInMinutes > 0) {
      speakingSpeed = wordCount / durationInMinutes;
    }
  }

  @override
  void dispose() {
    audioRecorder.dispose();
    speechToText.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomePageAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                const SizedBox(height: 30),
                RecordingStatusIndicator(isRecording: isRecording),
                const SizedBox(height: 40),
                RecordingButton(
                  isRecording: isRecording,
                  onPressed: isRecording ? stopRecording : startRecording,
                ),
                const SizedBox(height: 30),
                TranscriptionPanel(recognizedText: recognizedText),
                const SizedBox(height: 30),
                SpeechAnalysisSection(
                  wordCount: wordCount,
                  fillerWordCount: fillerWordCount,
                  repeatedWordCount: repeatedWordCount,
                  speakingSpeed: speakingSpeed,
                ),
                const SizedBox(height: 20),
                HomeActionButtons(
                  audioPath: audioPath,
                  onPlayback: () {
                    if (audioPath != null) {
                      Navigator.pushNamed(
                        context,
                        '/playback',
                        arguments: audioPath,
                      );
                    }
                  },
                  onFeedback: () {
                    Navigator.pushNamed(context, '/feedback');
                  },
                  onViewRecordings: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecordingsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}