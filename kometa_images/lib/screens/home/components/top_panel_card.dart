import 'package:flutter/material.dart';

class TopPanelCard extends StatelessWidget {
  final IconData iconData;
  final Color color;
  final Function() onTap;

  const TopPanelCard({Key key, this.iconData, this.color, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 50,
        width: 50,
        child: IconButton(
            icon: Icon(iconData, size: 35), onPressed: () => onTap()));
  }
}
