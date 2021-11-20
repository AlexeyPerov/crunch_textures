import 'package:flutter/material.dart';

class MiniButton extends StatelessWidget {
  final IconData icon;
  final Function pressed;
  final Color color;

  const MiniButton({Key key, this.icon, this.color, this.pressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: SizedBox(
          height: 25,
          width: 20,
          child: IconButton(
              icon: Icon(icon, size: 25), color: color, onPressed: pressed)),
    );
  }
}
