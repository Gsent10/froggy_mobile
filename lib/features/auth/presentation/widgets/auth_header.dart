import 'package:flutter/material.dart';
import 'package:froggy_mobile/core/utils/utils.dart';

class AuthHeader extends StatelessWidget {
  final String label;
  final String? subtitle;

  const AuthHeader({super.key, required this.label, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: context.screenHeight * kBarHeight),

        // Title
        Text(
          label,
          style: SafeGoogleFont(
            'Ubuntu',
            fontSize: context.screenWidth * kFontL,
            fontWeight: FontWeight.w800,
            color: kBlackColor,
            decoration: TextDecoration.none,
          ),
        ),

        if (subtitle != null)
          Text(
            subtitle!,
            style: SafeGoogleFont(
              'Ubuntu',
              fontSize: context.screenWidth * kFontS,
              fontWeight: FontWeight.w400,
              color: kBlackColor,
              decoration: TextDecoration.none,
            ),
          ),
        SizedBox(height: context.screenHeight * kSpacingXL),
      ],
    );
  }
}
