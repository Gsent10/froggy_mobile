// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:froggy_mobile/core/utils/utils.dart';

class Button extends StatelessWidget {
  final String label;

  const Button({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      padding: EdgeInsets.symmetric(vertical: context.screenHeight * kSpacingM),
      child: Center(
        child: Text(
          label,
          style: SafeGoogleFont(
            'Ubuntu',
            fontSize: context.screenWidth * kFontS,
            fontWeight: FontWeight.w500,
            color: kWhiteColor,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
