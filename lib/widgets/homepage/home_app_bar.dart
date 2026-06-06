import 'package:flutter/material.dart';

class HomePageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomePageAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Apex Speech'),
      centerTitle: true,
      backgroundColor: const Color.fromARGB(255, 185, 169, 214),
      actions: [
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
      ],
    );
  }
}