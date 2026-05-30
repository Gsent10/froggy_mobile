import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:froggy_mobile/core/utils/utils.dart';
import 'package:froggy_mobile/core/widgets/button.dart';
import 'package:froggy_mobile/core/widgets/form_input.dart';
import 'package:froggy_mobile/features/auth/bloc/auth_bloc.dart';
import 'package:froggy_mobile/features/auth/presentation/widgets/auth_header.dart';

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset successful. Please login.'),
            ),
          );
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
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
                  label: 'New Password',
                  subtitle: 'Enter your new password',
                ),

                FormInput(
                  textEditingController: passwordController,
                  title: 'New Password',
                  label: 'Enter your new password',
                  pass: true,
                ),
                FormInput(
                  textEditingController: confirmPasswordController,
                  title: 'Confirm Password',
                  label: 'Confirm your new password',
                  pass: true,
                ),
                const SizedBox(height: 30),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return GestureDetector(
                      onTap: state.status == AuthStatus.loading
                          ? null
                          : () {
                              context.read<AuthBloc>().add(
                                ResetPasswordRequested(
                                  passwordController.text,
                                  confirmPasswordController.text,
                                ),
                              );
                            },
                      child: state.status == AuthStatus.loading
                          ? const CircularProgressIndicator()
                          : const Button(label: 'Reset Password'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
