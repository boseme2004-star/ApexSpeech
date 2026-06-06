import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import 'about_us_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final goalController = TextEditingController();
  final aboutController = TextEditingController();
  int? profileId;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final profile = await DatabaseHelper.instance.getProfile();
    if (profile != null) {
      setState(() {
        profileId = profile['id'];
        nameController.text = profile['name'] ?? '';
        emailController.text = profile['email'] ?? '';
        goalController.text = profile['goal'] ?? '';
        aboutController.text = profile['about'] ?? '';
      });
    }
  }

  Future<void> saveProfile() async {
    setState(() => isSaving = true);

    final data = {
      'name': nameController.text,
      'email': emailController.text,
      'goal': goalController.text,
      'about': aboutController.text,
    };

    if (profileId != null) {
      await DatabaseHelper.instance.updateProfile(profileId!, data);
    } else {
      final id = await DatabaseHelper.instance.insertProfile(data);
      setState(() => profileId = id);
    }

    setState(() => isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved successfully')),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    goalController.dispose();
    aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color.fromARGB(255, 204, 135, 195),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Avatar
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Color.fromARGB(255, 176, 159, 201),
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),

            // Profile Info Section
            const Text(
              'Profile Info',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // About You Section
            const Text(
              'About You',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              'Help us personalise your experience',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: aboutController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'About Yourself',
                hintText:
                    'e.g. I am a student who wants to improve public speaking...',
                prefixIcon: const Icon(Icons.info_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: goalController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'My Speech Goal',
                hintText:
                    'e.g. Reduce filler words, speak more confidently...',
                prefixIcon: const Icon(Icons.flag),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // About Us Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.group_outlined),
                label: const Text(
                  'About Us',
                  style: TextStyle(fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  side: const BorderSide(color: Colors.deepPurple),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutUsScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 15),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color.fromARGB(255, 204, 135, 195),
                  padding: const EdgeInsets.all(15),
                ),
                onPressed: isSaving ? null : saveProfile,
                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Profile',
                        style:
                            TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}