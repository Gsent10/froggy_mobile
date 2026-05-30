import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:froggy_mobile/core/utils/utils.dart';
import 'package:froggy_mobile/core/widgets/button.dart';
import 'package:froggy_mobile/core/widgets/loading.dart';
import 'package:froggy_mobile/features/auth/bloc/auth_bloc.dart';
import 'package:froggy_mobile/features/auth/presentation/widgets/auth_header.dart';
import 'package:pinput/pinput.dart';

class VerifyOtpPage extends StatefulWidget {
  const VerifyOtpPage({super.key});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/dashboard', (route) => false);
        } else if (state.status == AuthStatus.otpVerified) {
          Navigator.of(context).pushReplacementNamed('/new-password');
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
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return AuthHeader(
                          label: 'Verify OTP',
                          subtitle:
                              'Enter the OTP sent to your email ${state.email ?? ''}',
                        );
                      },
                    ),
                    Pinput(
                      length: 6,
                      controller: otpController,
                      defaultPinTheme: PinTheme(
                        width: 56,
                        height: 56,
                        textStyle: const TextStyle(
                          fontSize: 20,
                          color: Color.fromRGBO(30, 60, 87, 1),
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromRGBO(234, 239, 243, 1),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onCompleted: (pin) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                    ),
                    const SizedBox(height: 40),
                    GestureDetector(
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        final state = context.read<AuthBloc>().state;
                        context.read<AuthBloc>().add(
                          VerifyOtpRequested(
                            email: state.email ?? '',
                            otp: otpController.text,
                            isFromRegister: state.isFromRegister,
                          ),
                        );
                      },
                      child: const Button(label: 'Verify OTP'),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        final state = context.read<AuthBloc>().state;
                        if (state.email != null) {
                          context.read<AuthBloc>().add(
                            ResendOtpRequested(state.email!),
                          );
                        }
                      },
                      child: const Text('Resend OTP'),
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
