import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlaybackScreen extends StatefulWidget {

  @override
  State<PlaybackScreen> createState() =>
      _PlaybackScreenState();
}

class _PlaybackScreenState
    extends State<PlaybackScreen> {

  // Audio player object
  final AudioPlayer audioPlayer = AudioPlayer();

  // Tracks whether audio is playing
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {

    // Receive recording path from HomeScreen
    final audioPath =
        ModalRoute.of(context)!
            .settings
            .arguments as String?;

    return Scaffold(

      appBar: AppBar(
        title: Text("Playback"),
      ),

      body: Center(

        child: Padding(
          padding: EdgeInsets.all(20),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              // Playback icon
              Icon(
                Icons.play_circle_fill,
                size: 100,
                color: Colors.deepPurple,
              ),

              SizedBox(height: 30),

              // Title
              Text(
                "Recorded Audio",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 40),

              // Play / Stop Button
              ElevatedButton(

                onPressed: () async {

                  // No recording available
                  if (audioPath == null) {

                    print("No recording found");

                    return;
                  }

                  // Stop audio if already playing
                  if (isPlaying) {

                    await audioPlayer.stop();

                    setState(() {
                      isPlaying = false;
                    });

                  } else {

                    // Load audio file
                    await audioPlayer.setFilePath(
                      audioPath,
                    );

                    // Play audio
                    await audioPlayer.play();

                    setState(() {
                      isPlaying = true;
                    });
                  }
                },

                child: Padding(
                  padding: EdgeInsets.all(15),

                  child: Text(

                    isPlaying
                        ? "Stop Audio"
                        : "Play Recording",

                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}