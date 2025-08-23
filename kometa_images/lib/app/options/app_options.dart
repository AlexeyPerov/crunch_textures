import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:kometa_images/app/theme/theme_constants.dart';

class AppOptions {
  const AppOptions({
    this.themeMode = ThemeMode.system,
    double textScaleFactor = systemTextScaleFactorOption,
    this.timeDilation = 1.0,
    // this.platform = defaultTargetPlatform,
    this.isTestMode = false,
  })  : _textScaleFactor = textScaleFactor;

  final ThemeMode themeMode;
  final double _textScaleFactor;
  final double timeDilation;
  //final TargetPlatform platform;
  final bool isTestMode;

  double textScaleFactor(BuildContext context, {bool useSentinel = false}) {
    if (_textScaleFactor == systemTextScaleFactorOption) {
      return useSentinel
          ? systemTextScaleFactorOption
          : MediaQuery.of(context).textScaleFactor;
    } else {
      return _textScaleFactor;
    }
  }

  SystemUiOverlayStyle resolvedSystemUiOverlayStyle() {
    Brightness brightness;
    switch (themeMode) {
      case ThemeMode.light:
        brightness = Brightness.light;
        break;
      case ThemeMode.dark:
        brightness = Brightness.dark;
        break;
      default:
        brightness = WidgetsBinding.instance.window.platformBrightness;
    }

    final overlayStyle = brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return overlayStyle;
  }

  AppOptions copyWith({
    ThemeMode themeMode = ThemeMode.system,
    double textScaleFactor = systemTextScaleFactorOption,
    Locale locale = const Locale('en', 'US'),
    double timeDilation = 1.0,
    //TargetPlatform platform = defaultTargetPlatform,
    bool isTestMode = false,
  }) {
    return AppOptions(
      themeMode: themeMode ?? this.themeMode,
      textScaleFactor: textScaleFactor ?? _textScaleFactor,
      timeDilation: timeDilation ?? this.timeDilation,
      //platform: platform ?? this.platform,
      isTestMode: isTestMode ?? this.isTestMode,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppOptions &&
          themeMode == other.themeMode &&
          _textScaleFactor == other._textScaleFactor &&
          timeDilation == other.timeDilation &&
          //platform == other.platform &&
          isTestMode == other.isTestMode;

  @override
  int get hashCode => Object.hash(
    themeMode,
    _textScaleFactor,
    timeDilation,
    //platform,
    isTestMode,
  );

  static AppOptions of(BuildContext context) {
    final scope =
    context.dependOnInheritedWidgetOfExactType<_ModelBindingScope>();
    return scope!.modelBindingState.currentModel;
  }

  static void update(BuildContext context, AppOptions newModel) {
    final scope =
    context.dependOnInheritedWidgetOfExactType<_ModelBindingScope>();
    scope!.modelBindingState.updateModel(newModel);
  }
}

class ApplyTextOptions extends StatelessWidget {
  const ApplyTextOptions({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final options = AppOptions.of(context);
    final textScaleFactor = options.textScaleFactor(context);

    Widget widget = MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: textScaleFactor,
      ),
      child: child,
    );
    return widget;
  }
}

class _ModelBindingScope extends InheritedWidget {
  _ModelBindingScope({
    Key key = const Key('ModelBindingScope'),
    required this.modelBindingState,
    required Widget child,
  })  : assert(modelBindingState != null),
        super(key: key, child: child);

  final _ModelBindingState modelBindingState;

  @override
  bool updateShouldNotify(_ModelBindingScope oldWidget) => true;
}

class ModelBinding extends StatefulWidget {
  ModelBinding({
    Key key = const Key('ModelBinding'),
    this.initialModel = const AppOptions(),
    required this.child,
  })  : assert(initialModel != null),
        super(key: key);

  final AppOptions initialModel;
  final Widget child;

  @override
  _ModelBindingState createState() => _ModelBindingState();
}

class _ModelBindingState extends State<ModelBinding> {
  late AppOptions currentModel;
  late Timer? _timeDilationTimer;

  @override
  void initState() {
    super.initState();
    currentModel = widget.initialModel;
  }

  @override
  void dispose() {
    _timeDilationTimer?.cancel();
    _timeDilationTimer = null;
    super.dispose();
  }

  void handleTimeDilation(AppOptions newModel) {
    if (currentModel.timeDilation != newModel.timeDilation) {
      _timeDilationTimer?.cancel();
      _timeDilationTimer = null;
      if (newModel.timeDilation > 1) {
        _timeDilationTimer = Timer(const Duration(milliseconds: 150), () {
          timeDilation = newModel.timeDilation;
        });
      } else {
        timeDilation = newModel.timeDilation;
      }
    }
  }

  void updateModel(AppOptions newModel) {
    if (newModel != currentModel) {
      handleTimeDilation(newModel);
      setState(() {
        currentModel = newModel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ModelBindingScope(
      modelBindingState: this,
      child: widget.child,
    );
  }
}
