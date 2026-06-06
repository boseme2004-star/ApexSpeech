import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  final List<Map<String, String>> teamMembers = const [
    {
      'name': 'Alex Johnson',
      'role': 'Lead Developer',
      'bio': 'Responsible for core architecture and backend development.',
    },
    {
      'name': 'Sarah Williams',
      'role': 'UI/UX Designer',
      'bio': 'Designed the user interface and overall app experience.',
    },
    {
      'name': 'Michael Chen',
      'role': 'AI & NLP Engineer',
      'bio': 'Implemented speech analysis and AI feedback features.',
    },
    {
      'name': 'Emily Davis',
      'role': 'QA & Documentation',
      'bio': 'Handled testing, bug fixes, and technical documentation.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: const Color.fromARGB(255, 204, 135, 195),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // App logo / icon
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 176, 159, 201),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.record_voice_over,
                size: 55,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),

            // App name
            const Text(
              'Apex Speech',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),

            // App tagline
            const Text(
              'Your personal AI-powered speech coach.\nSpeak better, one session at a time.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 10),

            // Version
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 240, 225, 255),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Version 1.0.0',
                style: TextStyle(fontSize: 12, color: Colors.deepPurple),
              ),
            ),
            const SizedBox(height: 35),

            // Meet the team
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Meet the Team',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Team member cards
            ...teamMembers.map((member) => _TeamMemberCard(member: member)),

            const SizedBox(height: 30),

            // Footer
            const Text(
              '© 2025 Apex Speech. All rights reserved.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _TeamMemberCard extends StatelessWidget {
  final Map<String, String> member;

  const _TeamMemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: const Color.fromARGB(255, 220, 200, 240),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color.fromARGB(255, 176, 159, 201),
            child: Text(
              member['name']![0],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 15),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member['name']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  member['role']!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  member['bio']!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}