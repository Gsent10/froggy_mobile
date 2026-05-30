import 'package:flutter/material.dart';
import 'package:froggy_mobile/core/utils/utils.dart';
import 'package:froggy_mobile/core/widgets/button.dart';
import 'package:froggy_mobile/core/widgets/form_input.dart';
import 'package:froggy_mobile/features/auth/presentation/widgets/auth_header.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: context.screenWidth,
        height: context.screenHeight,
        padding: EdgeInsets.symmetric(
          horizontal: context.screenWidth * kHorizontalPadding,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AuthHeader(),

              // Form Items
              FormInput(
                textEditingController: emailController,
                title: 'Email Address',
                label: 'Enter your email',
                mail: true,
              ),
              FormInput(
                textEditingController: passwordController,
                title: 'Password',
                label: 'Enter your password',
                pass: true,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Forgot Password?',
                      style: SafeGoogleFont(
                        'Ubuntu',
                        fontSize: context.screenWidth * kFontS,
                        fontWeight: FontWeight.w600,
                        color: kPrimaryColor,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.screenHeight * kSpacingM),

              // Submit Button
              GestureDetector(
                onTap: () {},
                child: Button(label: 'Login'),
              ),

              SizedBox(height: context.screenHeight * kSpacingL),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Don't have an Account? ",
                    style: SafeGoogleFont(
                      'Ubuntu',
                      fontSize: context.screenWidth * kFontS,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to sign up screen
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      "Sign up here",
                      style: SafeGoogleFont(
                        'Ubuntu',
                        fontSize: context.screenWidth * kFontS,
                        fontWeight: FontWeight.w600,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
