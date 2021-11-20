import 'package:flutter/material.dart';
import 'package:kometa_images/screens/home/home_screen.dart';

class ErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFA87934),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 142),
              SizedBox(height: 30),
              TextButton(
                  child: Text(
                    "Back To Home".toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(fontWeight: FontWeight.bold)
                        .copyWith(color: Colors.black54),
                  ),
                  onPressed: () {
                    HomeScreenNavigation.navigate(context);
                  }),
            ],
          ),
        ));
  }
}
