import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

import 'transcriptions_screen.dart';
import '../helpers/database_helper.dart';
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
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final SpeechToText speechToText = SpeechToText();

  bool isRecording = false;
  bool _recorderInitialized = false;
  String? audioPath;
  String recognizedText = '';
  int wordCount = 0;
  int fillerWordCount = 0;
  int repeatedWordCount = 0;
  double speakingSpeed = 0;
  Map<String, int> frequentWords = {};
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

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    try {
      await Permission.microphone.request();
      //await _recorder.openRecorder();
      setState(() {
        _recorderInitialized = true;
      });
      print('RECORDER INITIALIZED');
    } catch (e) {
      print('RECORDER INIT ERROR: $e');
    }
  }

  Future<void> startRecording() async {
    try {
      if (!_recorderInitialized) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recorder not ready, please wait')),
        );
        return;
      }

      // Step 1: Initialize STT
      bool speechEnabled = await speechToText.initialize(
        onStatus: (status) {
          print('STT STATUS: $status');
          if (status == 'done' && isRecording) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (isRecording && mounted) _startSTT();
            });
          }
        },
        onError: (error) {
          print('STT ERROR: ${error.errorMsg}');
          if (error.errorMsg != 'error_busy' && isRecording) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (isRecording && mounted) _startSTT();
            });
          }
        },
      );

      if (!speechEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition unavailable')),
        );
        return;
      }

      // Step 2: Start STT for live transcription
      await _startSTT();

      // Step 3: Small delay so STT fully owns mic before recorder opens
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 4: Start recorder
      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.aac';

      await _recorder.startRecorder(
        toFile: path,
        codec: Codec.aacADTS,
        bitRate: 128000,
        sampleRate: 44100,
      );

      recordingStartTime = DateTime.now();

      if (!mounted) return;

      setState(() {
        isRecording = true;
        audioPath = path;
        recognizedText = '';
        wordCount = 0;
        fillerWordCount = 0;
        repeatedWordCount = 0;
        speakingSpeed = 0;
        frequentWords = {};
      });

      print('RECORDING STARTED: $path');
    } catch (e) {
      print('START RECORDING ERROR: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recording Error: $e')),
      );
    }
  }

  Future<void> _startSTT() async {
    if (speechToText.isListening) return;
    await speechToText.listen(
      onResult: (result) {
        if (mounted) {
          setState(() {
            recognizedText = result.recognizedWords;
          });
          analyzeSpeech();
        }
      },
      listenOptions: SpeechListenOptions(
        listenFor: const Duration(minutes: 30),
        pauseFor: const Duration(seconds: 8),
        partialResults: true,
        cancelOnError: false,
      ),
    );
  }

  Future<void> stopRecording() async {
    try {
      // Step 1: Stop STT first
      await speechToText.stop();

      // Step 2: Small delay
      await Future.delayed(const Duration(milliseconds: 300));

      // Step 3: Stop recorder and save file
      final path = await _recorder.stopRecorder();
      calculateSpeakingSpeed();

      if (!mounted) return;

      setState(() {
        isRecording = false;
        //audioPath = path;
      });

      // Step 4: Save to database
      await DatabaseHelper.instance.insertRecording({
        'title': 'Recording ${DateTime.now().toString().substring(0, 16)}',
        //'audio_path': path ?? '',
        'transcript': recognizedText,
        'word_count': wordCount,
        'filler_word_count': fillerWordCount,
        'repeated_word_count': repeatedWordCount,
        'speaking_speed': speakingSpeed,
        'frequent_words': frequentWords.entries
            .map((e) => '${e.key}:${e.value}')
            .join(','),
        'date_created': DateTime.now().toIso8601String(),
      });

      print('RECORDING STOPPED: $audioPath');

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

    final wordFrequency = <String, int>{};
    for (final word in words) {
      if (word.isNotEmpty) {
        wordFrequency[word] = (wordFrequency[word] ?? 0) + 1;
      }
    }

    setState(() {
      frequentWords = Map.fromEntries(
        wordFrequency.entries
            .where((e) => e.value > 1)
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value)),
      );
    });
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
    _recorder.closeRecorder();
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
                  frequentWords: frequentWords,
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
                        builder: (context) => const TranscriptionsScreen(),
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