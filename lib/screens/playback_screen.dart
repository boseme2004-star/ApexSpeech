import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class PlaybackScreen extends StatefulWidget {
  const PlaybackScreen({super.key});

  @override
  State<PlaybackScreen> createState() => _PlaybackScreenState();
}

class _PlaybackScreenState extends State<PlaybackScreen> {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    audioPlayer.onDurationChanged.listen((d) {
      setState(() => duration = d);
    });
    audioPlayer.onPositionChanged.listen((p) {
      setState(() => position = p);
    });
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() => isPlaying = state == PlayerState.playing);
    });
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioPath =
        ModalRoute.of(context)!.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Playback'),
        backgroundColor: const Color.fromARGB(255, 204, 135, 195),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_circle_fill,
                size: 100,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 30),
              const Text(
                'Recorded Audio',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Progress slider
              Slider(
                min: 0,
                max: duration.inSeconds.toDouble(),
                value: position.inSeconds
                    .toDouble()
                    .clamp(0, duration.inSeconds.toDouble()),
                onChanged: (value) async {
                  await audioPlayer
                      .seek(Duration(seconds: value.toInt()));
                },
                activeColor: Colors.deepPurple,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(position)),
                  Text(_formatDuration(duration)),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color.fromARGB(255, 204, 135, 195),
                  padding: const EdgeInsets.all(15),
                ),
                onPressed: () async {
                  if (audioPath == null) return;
                  if (isPlaying) {
                    await audioPlayer.pause();
                  } else {
                    await audioPlayer.play(DeviceFileSource(audioPath));
                  }
                },
                child: Text(
                  isPlaying ? 'Pause' : 'Play Recording',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}