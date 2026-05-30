import 'package:flutter/material.dart';
import 'package:froggy_mobile/core/utils/utils.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: context.screenHeight * kBarHeight),

        // Title
        Text(
          'Login Page',
          style: SafeGoogleFont(
            'Ubuntu',
            fontSize: context.screenWidth * kFontL,
            fontWeight: FontWeight.w800,
            color: kBlackColor,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}
