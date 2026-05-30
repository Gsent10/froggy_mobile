import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:froggy_mobile/core/utils/utils.dart';
import 'package:froggy_mobile/core/widgets/button.dart';
import 'package:froggy_mobile/core/widgets/form_input.dart';
import 'package:froggy_mobile/core/widgets/loading.dart';
import 'package:froggy_mobile/features/auth/bloc/auth_bloc.dart';
import 'package:froggy_mobile/features/auth/presentation/widgets/auth_header.dart';

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final passwordController = TextEditingController();

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
        } else if (state.status == AuthStatus.failed) {
          Fluttertoast.showToast(
            msg: state.errorMessage ?? 'Request failed. Please try again.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            textColor: kWhiteColor,
            fontSize: 17,
            backgroundColor: Colors.red,
          );
        }
      },
      child: Scaffold(
        backgroundColor: kBgColor,
        body: Stack(
          children: [
            Container(
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
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        context.read<AuthBloc>().add(
                          ResetPasswordRequested(
                            passwordController.text,
                            passwordController.text,
                          ),
                        );
                      },
                      child: const Button(label: 'Reset Password'),
                    ),
                  ],
                ),
              ),
            ),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state.status == AuthStatus.loading) {
                  return const Loading();
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
