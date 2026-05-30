import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:froggy_mobile/core/utils/utils.dart';
import 'package:froggy_mobile/core/widgets/button.dart';
import 'package:froggy_mobile/core/widgets/form_input.dart';
import 'package:froggy_mobile/features/auth/bloc/auth_bloc.dart';
import 'package:froggy_mobile/features/auth/presentation/widgets/auth_header.dart';

class LoginPage extends StatefulWidget {
  final bool isFirstPage;
  const LoginPage({super.key, this.isFirstPage = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/dashboard', (route) => false);
        } else if (state.status == AuthStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'An error occurred')),
          );
        }
      },
      child: Scaffold(
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
                const AuthHeader(label: 'Login'),

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
                      onPressed: () {
                        Navigator.of(context).pushNamed('/forgot-password');
                      },
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
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return GestureDetector(
                      onTap: state.status == AuthStatus.loading
                          ? null
                          : () {
                              context.read<AuthBloc>().add(
                                LoginRequested(
                                  emailController.text,
                                  passwordController.text,
                                ),
                              );
                            },
                      child: state.status == AuthStatus.loading
                          ? const CircularProgressIndicator()
                          : const Button(label: 'Login'),
                    );
                  },
                ),

                SizedBox(height: context.screenHeight * kSpacingL),

                if (widget.isFirstPage)
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
                          Navigator.of(context).pushNamed('/register');
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
      ),
    );
  }
}
