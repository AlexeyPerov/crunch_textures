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
    return SizedBox(
      height: 20,
      width: 20,
      child: IconButton(
        icon: Icon(icon, size: 18),
        color: color,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
        splashRadius: 12,
        onPressed: pressed,
      ),
    );
  }
}