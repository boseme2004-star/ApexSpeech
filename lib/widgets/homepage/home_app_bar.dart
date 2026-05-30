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
      backgroundColor: Colors.deepPurple,
    );
  }
}
