import 'package:flutter/material.dart';

class TopPanelCard extends StatelessWidget {
  final IconData iconData;
  final Color color;
  final VoidCallback onTap;

  const TopPanelCard({
    super.key,
    required this.iconData,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 50,
      child: IconButton(
        icon: Icon(iconData, size: 35),
        onPressed: onTap,
      ),
    );
  }
}