// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
}

const kBgColor = Color.fromARGB(255, 255, 246, 246);
const kPrimaryColor = Color(0xff1443C3);
const kSecondaryColor = Color(0xff6C757D);
const kBlackColor = Colors.black;
const kWhiteColor = Colors.white;

const kHorizontalPadding = 0.06;
const kVerticalPadding = 0.03;
const kBarHeight = 0.1;

// Spacing Constants (Percentage of screen height/width)
const kSpacingXL = 0.06;
const kSpacingL = 0.04;
const kSpacingM = 0.02;
const kSpacingS = 0.01;

// Font Size Constants (Percentage of screen width)
const kFontXL = 0.07;
const kFontL = 0.06;
const kFontM = 0.05;
const kFontS = 0.04;
const kFontXS = 0.03;

const kAppBarHeight = 0.2;

TextStyle SafeGoogleFont(
  String fontFamily, {
  TextStyle? textStyle,
  Color? color,
  Color? backgroundColor,
  double? fontSize,
  FontWeight? fontWeight,
  FontStyle? fontStyle,
  double? letterSpacing,
  double? wordSpacing,
  TextBaseline? textBaseline,
  double? height,
  Locale? locale,
  Paint? foreground,
  Paint? background,
  List<Shadow>? shadows,
  List<FontFeature>? fontFeatures,
  TextDecoration? decoration,
  Color? decorationColor,
  TextDecorationStyle? decorationStyle,
  double? decorationThickness,
}) {
  const fixedFallback = ['Roboto', 'Arial'];

  try {
    return GoogleFonts.getFont(
      fontFamily,
      textStyle: textStyle,
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
    ).copyWith(
      fontFamilyFallback: fixedFallback, // ✅ applied here
    );
  } catch (ex) {
    return GoogleFonts.getFont(
      "Heebo",
      textStyle: textStyle,
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
    ).copyWith(
      fontFamilyFallback: fixedFallback, // ✅ applied here too
    );
  }
}
