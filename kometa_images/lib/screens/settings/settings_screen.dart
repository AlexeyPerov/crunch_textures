import 'package:flutter/material.dart';
import 'package:kometa_images/app/app.dart';
import 'package:kometa_images/app/options/app_options.dart';
import 'package:kometa_images/app/repositories/settings_repository.dart';
import 'package:kometa_images/app/theme/theme_constants.dart';
import 'package:kometa_images/app/theme/themes.dart';
import 'package:kometa_images/screens/home/components/top_panel_card.dart';
import 'package:kometa_images/screens/home/home_screen.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
        body: Column(
          children: [
            SizedBox(height: 20),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5.0, bottom: 10.0),
                  child: TopPanelCard(
                      iconData: Icons.arrow_back_rounded,
                      color: Theme.of(context).cardColor,
                      onTap: () {
                        HomeScreenNavigation.navigate(context);
                      }),
                ),
                Spacer()
              ],
            ),
            Spacer(),
            Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.settings, size: 142),
                    SizedBox(height: 30),
                    Row(
                      children: [
                        Spacer(),
                        drawThemeModeCard(context, Icons.sync, ThemeMode.system),
                        drawThemeModeCard(
                            context, Icons.lightbulb_outline, ThemeMode.light),
                        drawThemeModeCard(context, Icons.lightbulb, ThemeMode.dark),
                        Spacer()
                      ],
                    ),
                    SizedBox(height: 40),
                    Text(
                      "Kometa.Games".toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontWeight: FontWeight.bold),
                    )
                  ],
            ),
            Spacer()
          ],
        ));
  }
}

Widget drawThemeModeCard(
    BuildContext context, IconData icon, ThemeMode themeMode) {
  var width = MediaQuery.of(context).size.width;
  final limitedView = width <= 1024;
  var selected = AppOptions.of(context).themeMode == themeMode;

  return GestureDetector(
    onTap: () {
      AppOptions.update(
          context, AppOptions.of(context).copyWith(themeMode: themeMode));
      getIt.get<SettingsRepository>().putInt("theme_mode", themeMode.index);
    },
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      height: 120.0,
      width: limitedView ? 200 : 250.0,
      decoration: BoxDecoration(
        color: selected ? kPrimaryColor : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [selected ? commonBoxShadow() : slightBoxShadow()],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 25.0, top: 30.0),
            child: Text(
                themeMode.toString().replaceAll("ThemeMode.", "").toUpperCase(),
                overflow: TextOverflow.fade,
                maxLines: 2),
          ),
          Padding(
              padding: EdgeInsets.only(left: 25.0, bottom: 30.0),
              child: Icon(icon, size: 20))
        ],
      ),
    ),
  );
}
