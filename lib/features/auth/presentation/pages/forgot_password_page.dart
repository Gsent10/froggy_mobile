import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:froggy_mobile/core/utils/utils.dart';
import 'package:froggy_mobile/core/widgets/button.dart';
import 'package:froggy_mobile/core/widgets/form_input.dart';
import 'package:froggy_mobile/features/auth/bloc/auth_bloc.dart';
import 'package:froggy_mobile/features/auth/presentation/widgets/auth_header.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.otpRequired) {
          Navigator.of(context).pushNamed('/verify-otp');
        } else if (state.status == AuthStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'An error occurred')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: kBgColor,
        body: Container(
          width: context.screenWidth,
          height: context.screenHeight,
          padding: EdgeInsets.symmetric(
            horizontal: context.screenWidth * kHorizontalPadding,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const AuthHeader(
                  label: 'Forgot Password',
                  subtitle: 'Enter your email to receive an OTP',
                ),

                FormInput(
                  textEditingController: emailController,
                  title: 'Email Address',
                  label: 'Enter your email',
                  mail: true,
                ),
                const SizedBox(height: 30),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return GestureDetector(
                      onTap: state.status == AuthStatus.loading
                          ? null
                          : () {
                              context.read<AuthBloc>().add(
                                ForgotPasswordRequested(emailController.text),
                              );
                            },
                      child: state.status == AuthStatus.loading
                          ? const CircularProgressIndicator()
                          : const Button(label: 'Send OTP'),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
