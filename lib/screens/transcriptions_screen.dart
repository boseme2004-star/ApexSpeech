import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../helpers/database_helper.dart';
import 'transcriptions_detail_screen.dart';

class TranscriptionsScreen extends StatefulWidget {
  const TranscriptionsScreen({super.key});

  @override
  State<TranscriptionsScreen> createState() => _TranscriptionsScreenState();
}

class _TranscriptionsScreenState extends State<TranscriptionsScreen> {
  List<Map<String, dynamic>> recordings = [];
  List<Map<String, dynamic>> filteredRecordings = [];
  final TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  String selectedFilter = 'All';

  final List<String> filterOptions = ['All', 'Today', 'This Week', 'This Month'];

  @override
  void initState() {
    super.initState();
    loadRecordings();
    searchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadRecordings() async {
    setState(() => isLoading = true);
    final data = await DatabaseHelper.instance.getAllRecordings();
    setState(() {
      recordings = data;
      filteredRecordings = data;
      isLoading = false;
    });
  }

  void onSearchChanged() async {
    final query = searchController.text.trim();
    if (query.isEmpty) {
      applyFilter(selectedFilter);
      return;
    }
    final results = await DatabaseHelper.instance.searchRecordings(query);
    setState(() => filteredRecordings = results);
  }

  void applyFilter(String filter) {
    setState(() => selectedFilter = filter);
    final now = DateTime.now();
    List<Map<String, dynamic>> result;

    switch (filter) {
      case 'Today':
        result = recordings.where((r) {
          final date = DateTime.tryParse(r['date_created'] ?? '');
          return date != null &&
              date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        }).toList();
        break;
      case 'This Week':
        final weekAgo = now.subtract(const Duration(days: 7));
        result = recordings.where((r) {
          final date = DateTime.tryParse(r['date_created'] ?? '');
          return date != null && date.isAfter(weekAgo);
        }).toList();
        break;
      case 'This Month':
        result = recordings.where((r) {
          final date = DateTime.tryParse(r['date_created'] ?? '');
          return date != null &&
              date.year == now.year &&
              date.month == now.month;
        }).toList();
        break;
      default:
        result = recordings;
    }

    setState(() => filteredRecordings = result);
  }

  Future<void> deleteRecording(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transcription'),
        content: const Text(
          'Are you sure you want to delete this transcription? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteRecording(id);
      loadRecordings();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transcription deleted')),
      );
    }
  }

  Future<void> renameRecording(int id, String currentTitle) async {
    final controller = TextEditingController(text: currentTitle);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Recording'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newTitle != null && newTitle.isNotEmpty) {
      await DatabaseHelper.instance.renameRecording(id, newTitle);
      loadRecordings();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recording renamed')),
      );
    }
  }

  Future<void> exportTranscription(int id, String title) async {
    final text = await DatabaseHelper.instance.exportTranscriptionAsText(id);
    if (text.isEmpty) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          '${title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to ${file.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transcriptions'),
        backgroundColor: const Color.fromARGB(255, 204, 135, 195),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadRecordings,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 8),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search transcriptions...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                                applyFilter(selectedFilter);
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),

                // Filter chips
                SizedBox(
                  height: 45,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: filterOptions.length,
                    itemBuilder: (context, index) {
                      final filter = filterOptions[index];
                      final isSelected = selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (_) => applyFilter(filter),
                          selectedColor:
                              const Color.fromARGB(255, 204, 135, 195),
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // Count
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${filteredRecordings.length} transcription${filteredRecordings.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // List
                Expanded(
                  child: filteredRecordings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.transcribe,
                                  size: 60, color: Colors.grey),
                              const SizedBox(height: 15),
                              Text(
                                searchController.text.isNotEmpty
                                    ? 'No results for "${searchController.text}"'
                                    : 'No transcriptions yet',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Record a speech to see it here',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          itemCount: filteredRecordings.length,
                          itemBuilder: (context, index) {
                            final recording = filteredRecordings[index];
                            final transcript =
                                recording['transcript'] ?? '';
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
                                      builder: (context) =>
                                          TranscriptionsScreen(
                                        //recordingId: recording['id'],
                                      ),
                                    ),
                                  ).then((_) => loadRecordings());
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Title and menu
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              recording['title'] ??
                                                  'Recording',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                              overflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            onSelected: (value) {
                                              if (value == 'rename') {
                                                renameRecording(
                                                  recording['id'],
                                                  recording['title'] ??
                                                      'Recording',
                                                );
                                              } else if (value ==
                                                  'export') {
                                                exportTranscription(
                                                  recording['id'],
                                                  recording['title'] ??
                                                      'Recording',
                                                );
                                              } else if (value ==
                                                  'delete') {
                                                deleteRecording(
                                                    recording['id']);
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'rename',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit,
                                                        size: 18),
                                                    SizedBox(width: 8),
                                                    Text('Rename'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'export',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.download,
                                                        size: 18),
                                                    SizedBox(width: 8),
                                                    Text('Export'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete,
                                                        color: Colors.red,
                                                        size: 18),
                                                    SizedBox(width: 8),
                                                    Text('Delete',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.red)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 6),

                                      // Transcript preview
                                      Text(
                                        preview,
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 13,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      // Stats chips
                                      Wrap(
                                        spacing: 6,
                                        children: [
                                          _statChip(
                                            Icons.text_fields,
                                            '${recording['word_count'] ?? 0} words',
                                          ),
                                          _statChip(
                                            Icons.speed,
                                            '${(recording['speaking_speed'] ?? 0.0).toStringAsFixed(1)} WPM',
                                          ),
                                          _statChip(
                                            Icons.calendar_today,
                                            recording['date_created']
                                                    ?.substring(0, 10) ??
                                                '',
                                          ),
                                          if (recording['ai_feedback'] !=
                                                  null &&
                                              recording['ai_feedback']
                                                  .toString()
                                                  .isNotEmpty)
                                            _statChip(
                                              Icons.psychology,
                                              'Has feedback',
                                              color: Colors.green,
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
                ),
              ],
            ),
    );
  }

  Widget _statChip(IconData icon, String label, {Color? color}) {
    final chipColor = color ?? Colors.deepPurple;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: chipColor),
          ),
        ],
      ),
    );
  }
}