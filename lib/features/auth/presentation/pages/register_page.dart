import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:froggy_mobile/core/utils/utils.dart';
import 'package:froggy_mobile/core/widgets/button.dart';
import 'package:froggy_mobile/core/widgets/form_input.dart';
import 'package:froggy_mobile/core/widgets/loading.dart';
import 'package:froggy_mobile/features/auth/bloc/auth_bloc.dart';
import 'package:froggy_mobile/features/auth/presentation/widgets/auth_header.dart';

class RegisterPage extends StatefulWidget {
  final bool isFirstPage;
  const RegisterPage({super.key, this.isFirstPage = false});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  String selectedCountryCode = 'GB';
  final List<Map<String, String>> countries = [
    {'code': 'GB', 'name': 'United Kingdom', 'flag': 'assets/flags/GB.png'},
    {'code': 'NG', 'name': 'Nigeria', 'flag': 'assets/flags/NG.png'},
    {'code': 'US', 'name': 'United States', 'flag': 'assets/flags/US.png'},
    {'code': 'GH', 'name': 'Ghana', 'flag': 'assets/flags/GH.png'},
    {'code': 'KE', 'name': 'Kenya', 'flag': 'assets/flags/KE.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.otpRequired) {
          Navigator.of(context).pushNamed('/verify-otp');
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
                    AuthHeader(
                      label: 'Register',
                      subtitle: 'Create a new account',
                      isFirstPage: widget.isFirstPage,
                    ),
                    FormInput(
                      textEditingController: fullNameController,
                      title: 'Full Name',
                      label: 'Enter your full name',
                    ),
                    FormInput(
                      textEditingController: emailController,
                      title: 'Email Address',
                      label: 'Enter your email',
                      mail: true,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 55,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedCountryCode,
                                isExpanded: true,
                                items: countries.map((country) {
                                  return DropdownMenuItem(
                                    value: country['code'],
                                    child: Image.asset(
                                      country['flag']!,
                                      width: 32,
                                      height: 24,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    selectedCountryCode = val!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 5,
                          child: FormInput(
                            textEditingController: phoneController,
                            title: 'Phone Number',
                            label: 'Enter your phone number',
                          ),
                        ),
                      ],
                    ),
                    FormInput(
                      textEditingController: passwordController,
                      title: 'Password',
                      label: 'Enter your password',
                      pass: true,
                    ),

                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        context.read<AuthBloc>().add(
                          RegisterRequested({
                            'full_name': fullNameController.text,
                            'email': emailController.text,
                            'phone_number': phoneController.text,
                            'country_code': selectedCountryCode,
                            'password': passwordController.text,
                            'password_confirmation': passwordController.text,
                          }),
                        );
                      },
                      child: const Button(label: 'Register'),
                    ),

                    const SizedBox(height: 20),

                    if (widget.isFirstPage)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Already have an Account? ",
                            style: SafeGoogleFont(
                              'Ubuntu',
                              fontSize: context.screenWidth * kFontS,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/login');
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              "Sign in here",
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
