import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'recordings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

  // AUDIO RECORDER
  final AudioRecorder audioRecorder =
      AudioRecorder();

  // SPEECH TO TEXT
  final SpeechToText speechToText =
      SpeechToText();

  // RECORDING STATE
  bool isRecording = false;

  // AUDIO PATH
  String? audioPath;

  // TRANSCRIBED TEXT
  String recognizedText = "";

  // ANALYSIS VARIABLES
  int wordCount = 0;

  int fillerWordCount = 0;

  int repeatedWordCount = 0;

  double speakingSpeed = 0;

  DateTime? recordingStartTime;

  // LIST OF FILLER WORDS
  final List<String> fillerWords = [
    "um",
    "uh",
    "like",
    "you know",
    "basically",
    "actually",
    "literally",
  ];

  // START RECORDING
  Future<void> startRecording() async {

    try {

      bool permission =
          await audioRecorder.hasPermission();

      print(
        "Microphone Permission: $permission",
      );

      if (!permission) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            content: Text(
              "Microphone permission denied",
            ),
          ),
        );

        return;
      }

      // INITIALIZE SPEECH RECOGNITION
      bool speechEnabled =
          await speechToText.initialize(

        onStatus: (status) {

          print(
            "Speech Status: $status",
          );
        },

        onError: (error) {

          print(
            "Speech Error: $error",
          );
        },
      );

      print(
        "Speech Available: $speechEnabled",
      );

      if (!speechEnabled) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            content: Text(
              "Speech recognition unavailable",
            ),
          ),
        );

        return;
      }

      // APP DIRECTORY
      final directory =
          await getApplicationDocumentsDirectory();

      // UNIQUE FILE NAME
      final path =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';

      // START AUDIO RECORDING
      await audioRecorder.start(

        const RecordConfig(

          encoder: AudioEncoder.aacLc,

          bitRate: 128000,

          sampleRate: 44100,
        ),

        path: path,
      );

      // START SPEECH LISTENING
      await speechToText.listen(

        onResult: (result) {

          setState(() {

            recognizedText =
                result.recognizedWords;

            analyzeSpeech();
          });
        },
      );

      recordingStartTime =
          DateTime.now();

      if (!mounted) return;

      setState(() {

        isRecording = true;

        audioPath = path;
      });

    } catch (e) {

      print(
        "Recording Error: $e",
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            "Recording Error: $e",
          ),
        ),
      );
    }
  }

  // STOP RECORDING
  Future<void> stopRecording() async {

    try {

      final path =
          await audioRecorder.stop();

      await speechToText.stop();

      calculateSpeakingSpeed();

      if (!mounted) return;

      setState(() {

        isRecording = false;

        audioPath = path;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Recording Saved Successfully",
          ),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            "Stop Recording Error: $e",
          ),
        ),
      );
    }
  }

  // ANALYZE SPEECH
  void analyzeSpeech() {

    List<String> words =
        recognizedText
            .toLowerCase()
            .split(" ");

    // WORD COUNT
    wordCount = words.length;

    // FILLER WORD COUNT
    fillerWordCount = 0;

    for (String filler in fillerWords) {

      fillerWordCount += words
          .where(
            (word) => word == filler,
          )
          .length;
    }

    // REPEATED WORD COUNT
    repeatedWordCount = 0;

    for (
        int i = 1;
        i < words.length;
        i++
    ) {

      if (words[i] ==
          words[i - 1]) {

        repeatedWordCount++;
      }
    }
  }

  // SPEAKING SPEED
  void calculateSpeakingSpeed() {

    if (recordingStartTime ==
        null) return;

    final durationInMinutes =

        DateTime.now()
                .difference(
                  recordingStartTime!,
                )
                .inSeconds /
            60;

    if (durationInMinutes > 0) {

      speakingSpeed =
          wordCount /
              durationInMinutes;
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

      appBar: AppBar(

        title: const Text(
          "Apex Speech",
        ),

        centerTitle: true,

        backgroundColor:
            Colors.deepPurple,
      ),

      body: SafeArea(

        child: SingleChildScrollView(

          child: Padding(

            padding:
                const EdgeInsets.all(25),

            child: Column(

              children: [

                const SizedBox(
                  height: 30,
                ),

                // MIC ICON
                AnimatedContainer(

                  duration:
                      const Duration(
                    milliseconds: 300,
                  ),

                  padding:
                      const EdgeInsets.all(
                    25,
                  ),

                  decoration:
                      BoxDecoration(

                    color: isRecording
                        ? Colors.red
                            .shade100
                        : Colors
                            .deepPurple
                            .shade100,

                    shape:
                        BoxShape.circle,
                  ),

                  child: Icon(

                    Icons.mic,

                    size: 90,

                    color: isRecording
                        ? Colors.red
                        : Colors
                            .deepPurple,
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                Text(

                  isRecording
                      ? "Recording..."
                      : "Ready to Record",

                  style:
                      const TextStyle(

                    fontSize: 28,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 40,
                ),

                // RECORD BUTTON
                SizedBox(

                  width:
                      double.infinity,

                  child:
                      ElevatedButton(

                    style:
                        ElevatedButton
                            .styleFrom(

                      backgroundColor:
                          isRecording
                              ? Colors.red
                              : Colors
                                  .deepPurple,

                      padding:
                          const EdgeInsets
                              .symmetric(
                        vertical: 18,
                      ),
                    ),

                    onPressed: () {

                      if (isRecording) {

                        stopRecording();

                      } else {

                        startRecording();
                      }
                    },

                    child: Text(

                      isRecording
                          ? "Stop Recording"
                          : "Start Recording",

                      style:
                          const TextStyle(

                        fontSize: 18,

                        color:
                            Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                // LIVE TRANSCRIPTION
                const Align(

                  alignment:
                      Alignment
                          .centerLeft,

                  child: Text(

                    "Speech Text",

                    style: TextStyle(

                      fontSize: 20,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Container(

                  width:
                      double.infinity,

                  padding:
                      const EdgeInsets
                          .all(15),

                  decoration:
                      BoxDecoration(

                    border: Border.all(
                      color:
                          Colors.grey,
                    ),

                    borderRadius:
                        BorderRadius
                            .circular(
                      12,
                    ),
                  ),

                  child: Text(

                    recognizedText
                            .isEmpty
                        ? "Speech will appear here..."
                        : recognizedText,

                    style:
                        const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                // ANALYSIS SECTION
                Container(

                  width:
                      double.infinity,

                  padding:
                      const EdgeInsets
                          .all(20),

                  decoration:
                      BoxDecoration(

                    color: Colors
                        .deepPurple
                        .shade50,

                    borderRadius:
                        BorderRadius
                            .circular(
                      15,
                    ),
                  ),

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      const Text(

                        "Speech Analysis",

                        style:
                            TextStyle(

                          fontSize: 22,

                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      Text(
                        "Word Count: $wordCount",
                      ),

                      Text(
                        "Filler Words: $fillerWordCount",
                      ),

                      Text(
                        "Repeated Words: $repeatedWordCount",
                      ),

                      Text(
                        "Speaking Speed: ${speakingSpeed.toStringAsFixed(1)} WPM",
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                // PLAYBACK BUTTON
                SizedBox(

                  width:
                      double.infinity,

                  child:
                      ElevatedButton(

                    onPressed:
                        audioPath == null
                            ? null
                            : () {

                                Navigator
                                    .pushNamed(

                                  context,

                                  '/playback',

                                  arguments:
                                      audioPath,
                                );
                              },

                    child:
                        const Padding(

                      padding:
                          EdgeInsets.all(
                        15,
                      ),

                      child: Text(

                        "Playback",

                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                // FEEDBACK BUTTON
                SizedBox(

                  width:
                      double.infinity,

                  child:
                      ElevatedButton(

                    onPressed: () {

                      Navigator
                          .pushNamed(

                        context,

                        '/feedback',
                      );
                    },

                    child:
                        const Padding(

                      padding:
                          EdgeInsets.all(
                        15,
                      ),

                      child: Text(

                        "Feedback",

                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                // VIEW RECORDINGS BUTTON
                SizedBox(

                  width:
                      double.infinity,

                  child:
                      ElevatedButton(

                    onPressed: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder:
                              (context) =>
                                  const RecordingsScreen(),
                        ),
                      );
                    },

                    child:
                        const Padding(

                      padding:
                          EdgeInsets.all(
                        15,
                      ),

                      child: Text(

                        "View Recordings",

                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}