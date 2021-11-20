import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const double kMinWebContainerWidth = 1250;
const double systemTextScaleFactorOption = -1;
const kPrimaryColor = Color(0xFF34A8B3);
const kPrimaryLightColor = Color(0xFFFFECDF);
const kPrimaryGradientColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFFECDF), Color(0xFF64B5F6)],
);
const kSecondaryColor = Color(0xFF979797);
const kTextColor = Color(0xFF757575);
const kAnimationDuration = Duration(milliseconds: 200);
const defaultDuration = Duration(milliseconds: 250);

final DateFormat dateFormatter = DateFormat('dd MMM');
final DateFormat timeFormatter = DateFormat('h:mm');
