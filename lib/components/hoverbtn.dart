import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'menu_items.dart';

class HoverBtn extends StatelessWidget {
  const HoverBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPopover(
        context: context,
        bodyBuilder: (context) => const MenuItems(),
        width: 150,
        height: 60, // Adjusted height to fit the LogoutButton properly
        backgroundColor: Colors.deepOrangeAccent,
      ),
      child: const Icon(Icons.more_horiz),
    );
  }
}
