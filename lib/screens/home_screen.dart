import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'recordings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // Recorder object
  final AudioRecorder audioRecorder = AudioRecorder();

  // Recording state
  bool isRecording = false;

  // Saved audio path
  String? audioPath;

  // START RECORDING
  Future<void> startRecording() async {

    bool permission = await audioRecorder.hasPermission();

    print("Permission: $permission");

    if (permission) {

      // App storage directory
      final directory =
          await getApplicationDocumentsDirectory();

      // UNIQUE file name
      String path =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';

      print("Recording path: $path");

      // Start recording
      await audioRecorder.start(
        const RecordConfig(),
        path: path,
      );

      setState(() {
        isRecording = true;
      });

      print("Recording started");
    }
  }

  // STOP RECORDING
  Future<void> stopRecording() async {

    final path = await audioRecorder.stop();

    print("Recording stopped");
    print("Saved at: $path");

    setState(() {
      isRecording = false;
      audioPath = path;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Vocal Coach"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(

        child: Center(

          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(

              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [

                const SizedBox(height: 40),

                // MICROPHONE ICON
                Icon(
                  Icons.mic,
                  size: 100,
                  color: isRecording
                      ? Colors.red
                      : Colors.deepPurple,
                ),

                const SizedBox(height: 30),

                // STATUS TEXT
                Text(

                  isRecording
                      ? "Recording..."
                      : "Press to Record",

                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),

                // START / STOP BUTTON
                ElevatedButton(

                  style: ElevatedButton.styleFrom(

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 18,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15),
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

                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // RECORDING SUCCESS
                if (audioPath != null)

                  const Text(

                    "Recording Saved!",

                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                const SizedBox(height: 30),

                // PLAYBACK BUTTON
                ElevatedButton(

                  onPressed: audioPath == null
                      ? null
                      : () {

                          Navigator.pushNamed(
                            context,
                            '/playback',
                            arguments: audioPath,
                          );
                        },

                  child: const Padding(

                    padding: EdgeInsets.all(15),

                    child: Text(
                      "Playback",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // FEEDBACK BUTTON
                ElevatedButton(

                  onPressed: () {

                    Navigator.pushNamed(
                      context,
                      '/feedback',
                    );
                  },

                  child: const Padding(

                    padding: EdgeInsets.all(15),

                    child: Text(
                      "Feedback",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // VIEW RECORDINGS BUTTON
                ElevatedButton(

                  onPressed: () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(
                        builder: (context) =>
                            const RecordingsScreen(),
                      ),
                    );
                  },

                  child: const Padding(

                    padding: EdgeInsets.all(15),

                    child: Text(
                      "View Recordings",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
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