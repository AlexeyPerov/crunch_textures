import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'app/app.dart';
import 'app/options/app_options.dart';
import 'app/repositories/settings_repository.dart';
import 'app/theme/theme_constants.dart';
import 'app/theme/themes.dart';
import 'screens/error/error_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'common/utilities/routing/routing_extensions.dart';

void main() async {
  getIt.registerSingleton<SettingsRepository>(HiveSettingsRepository());

  await getIt.get<SettingsRepository>().initialize();

  runApp(AppWidget());
}

class AppWidget extends StatelessWidget {
  final Future _appInitialization;

  AppWidget() : _appInitialization = App.initializeApp();

  @override
  Widget build(BuildContext context) => ModelBinding(
    initialModel: AppOptions(
      themeMode: ThemeMode.values[getIt
          .get<SettingsRepository>()
          .getInt("theme_mode", defaultValue: ThemeMode.system.index)],
      textScaleFactor: systemTextScaleFactorOption,
      timeDilation: timeDilation,
      platform: defaultTargetPlatform,
      isTestMode: false,
    ),
    child: Builder(
      builder: (context) {
        return _createApp(context);
      },
    ),
  );

  MaterialApp _createApp(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kometa.Images',
      themeMode: AppOptions.of(context).themeMode,
      theme: AppThemeData.lightThemeData.copyWith(
        platform: AppOptions.of(context).platform,
      ),
      darkTheme: AppThemeData.darkThemeData.copyWith(
        platform: AppOptions.of(context).platform,
      ),
      onGenerateRoute: _generateRoute,
    );
  }

  FutureBuilder _redirectOnAppInit(RouteToWidget routeTo) {
    return FutureBuilder(
      future: _appInitialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorScreen();
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return routeTo();
        }

        return SplashScreen();
      },
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    var routingData = settings.name.getRoutingData;
    switch (routingData.route) {
      case '/settings':
        return MaterialPageRoute(
            builder: (context) => _redirectOnAppInit(() => SettingsScreen()));
        break;
      case '/splash':
        return MaterialPageRoute(
            builder: (context) => _redirectOnAppInit(() => SplashScreen()));
        break;
      case '/error':
        return MaterialPageRoute(
            builder: (context) => _redirectOnAppInit(() => ErrorScreen()));
        break;
    }
    return MaterialPageRoute(
      builder: (context) => _redirectOnAppInit(() => HomeScreen()),
    );
  }
}

typedef Widget RouteToWidget();
