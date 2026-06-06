import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../helpers/database_helper.dart';

class ProgressDashboardScreen extends StatefulWidget {
  const ProgressDashboardScreen({super.key});

  @override
  State<ProgressDashboardScreen> createState() =>
      _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState
    extends State<ProgressDashboardScreen> {
  Map<String, dynamic> stats = {};
  List<Map<String, dynamic>> recentRecordings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    final s = await DatabaseHelper.instance.getProgressStats();
    final r = await DatabaseHelper.instance.getRecentRecordings(7);
    setState(() {
      stats = s;
      recentRecordings = r;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Dashboard'),
        backgroundColor: const Color.fromARGB(255, 204, 135, 195),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  Row(
                    children: [
                      _StatCard(
                        title: 'Total\nRecordings',
                        value:
                            '${stats['total_recordings'] ?? 0}',
                        icon: Icons.mic,
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        title: 'Avg\nSpeed',
                        value:
                            '${(stats['avg_speaking_speed'] ?? 0.0).toStringAsFixed(0)} WPM',
                        icon: Icons.speed,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _StatCard(
                        title: 'Avg Filler\nWords',
                        value:
                            '${(stats['avg_filler_words'] ?? 0.0).toStringAsFixed(1)}',
                        icon: Icons.warning_amber,
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        title: 'Avg Word\nCount',
                        value:
                            '${(stats['avg_word_count'] ?? 0.0).toStringAsFixed(0)}',
                        icon: Icons.text_fields,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Speaking speed chart
                  if (recentRecordings.isNotEmpty) ...[
                    const Text(
                      'Speaking Speed (last 7 recordings)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '${value.toInt() + 1}',
                                    style: const TextStyle(fontSize: 12),
                                  );
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots: recentRecordings
                                  .reversed
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((e) => FlSpot(
                                        e.key.toDouble(),
                                        (e.value['speaking_speed'] ?? 0.0)
                                            .toDouble(),
                                      ))
                                  .toList(),
                              isCurved: true,
                              color: Colors.deepPurple,
                              barWidth: 3,
                              dotData: const FlDotData(show: true),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Filler words chart
                    const Text(
                      'Filler Words (last 7 recordings)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          gridData: const FlGridData(show: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '${value.toInt() + 1}',
                                    style: const TextStyle(fontSize: 12),
                                  );
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: true),
                          barGroups: recentRecordings
                              .reversed
                              .toList()
                              .asMap()
                              .entries
                              .map((e) => BarChartGroupData(
                                    x: e.key,
                                    barRods: [
                                      BarChartRodData(
                                        toY: (e.value['filler_word_count'] ??
                                                0)
                                            .toDouble(),
                                        color: const Color.fromARGB(
                                            255, 204, 135, 195),
                                        width: 16,
                                      ),
                                    ],
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ] else
                    const Center(
                      child: Text(
                        'No recordings yet.\nStart recording to see your progress!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 176, 159, 201),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.deepPurple),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}