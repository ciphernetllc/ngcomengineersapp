import 'package:flutter/material.dart';
import 'logout_btn.dart';

class MenuItems extends StatelessWidget {
  const MenuItems({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LogoutButton(),
        // Add more menu items here if needed
      ],
    );
  }
}
