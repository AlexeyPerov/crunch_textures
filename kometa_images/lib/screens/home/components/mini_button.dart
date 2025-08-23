import 'package:flutter/material.dart';

class MiniButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback pressed;
  final Color color;

  const MiniButton({
    super.key,
    required this.icon,
    required this.color,
    required this.pressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: SizedBox(
        height: 25,
        width: 20,
        child: IconButton(
          icon: Icon(icon, size: 25),
          color: color,
          onPressed: pressed,
        ),
      ),
    );
  }
}