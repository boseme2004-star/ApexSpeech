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
  String? audioPath;

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

    // Load audio path after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final path =
          ModalRoute.of(context)?.settings.arguments as String?;
      setState(() => audioPath = path);
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
    // No audio path passed
    if (audioPath == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Playback'),
          backgroundColor: const Color.fromARGB(255, 204, 135, 195),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.music_off, size: 60, color: Colors.grey),
              SizedBox(height: 15),
              Text(
                'No audio file found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Record a speech first to play it back',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

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
              // Icon
              Icon(
                isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_fill,
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

              const SizedBox(height: 8),

              // Audio file name
              Text(
                audioPath!.split('/').last,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 30),

              // Progress slider
              Slider(
                min: 0,
                max: duration.inSeconds.toDouble() > 0
                    ? duration.inSeconds.toDouble()
                    : 1,
                value: position.inSeconds
                    .toDouble()
                    .clamp(
                      0,
                      duration.inSeconds.toDouble() > 0
                          ? duration.inSeconds.toDouble()
                          : 1,
                    ),
                onChanged: (value) async {
                  await audioPlayer
                      .seek(Duration(seconds: value.toInt()));
                },
                activeColor: Colors.deepPurple,
              ),

              // Time labels
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(position)),
                    Text(_formatDuration(duration)),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Play/Pause button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 204, 135, 195),
                    padding: const EdgeInsets.all(15),
                  ),
                  onPressed: () async {
                    if (isPlaying) {
                      await audioPlayer.pause();
                    } else {
                      await audioPlayer
                          .play(DeviceFileSource(audioPath!));
                    }
                  },
                  child: Text(
                    isPlaying ? 'Pause' : 'Play Recording',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Stop button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(15),
                    side: const BorderSide(color: Colors.deepPurple),
                  ),
                  onPressed: () async {
                    await audioPlayer.stop();
                    setState(() => position = Duration.zero);
                  },
                  child: const Text(
                    'Stop',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.deepPurple,
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