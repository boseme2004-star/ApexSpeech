import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';

class RecordingsScreen extends StatefulWidget {
  const RecordingsScreen({super.key});

  @override
  State<RecordingsScreen> createState() => _RecordingsScreenState();
}

class _RecordingsScreenState extends State<RecordingsScreen> {
  List<FileSystemEntity> recordings = [];
  final AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    loadRecordings();
  }

  Future<void> loadRecordings() async {
    final directory = await getApplicationDocumentsDirectory();

    final files = directory
        .listSync()
        .where((file) => file.path.endsWith(".m4a"))
        .toList();

    setState(() {
      recordings = files;
    });
  }

  Future<void> playAudio(String path) async {
    await player.setFilePath(path);
    player.play();
  }

  Future<void> deleteAudio(File file) async {
    await file.delete();

    loadRecordings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Recordings"),
      ),
      body: recordings.isEmpty
          ? const Center(
              child: Text("No recordings found"),
            )
          : ListView.builder(
              itemCount: recordings.length,
              itemBuilder: (context, index) {
                final file = recordings[index];

                return Card(
                  child: ListTile(
                    title: Text(file.path.split('/').last),
                    leading: IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () {
                        playAudio(file.path);
                      },
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        deleteAudio(File(file.path));
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}