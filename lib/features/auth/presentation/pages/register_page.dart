import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:froggy_mobile/core/utils/utils.dart';
import 'package:froggy_mobile/core/widgets/button.dart';
import 'package:froggy_mobile/core/widgets/form_input.dart';
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
    {'code': 'GB', 'name': 'United Kingdom'},
    {'code': 'NG', 'name': 'Nigeria'},
    {'code': 'US', 'name': 'United States'},
    {'code': 'GH', 'name': 'Ghana'},
    {'code': 'KE', 'name': 'Kenya'},
  ];

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
        body: Container(
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Country',
                            style: SafeGoogleFont(
                              'Ubuntu',
                              fontSize: context.screenWidth * kFontS,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          DropdownButton<String>(
                            value: selectedCountryCode,
                            isExpanded: true,
                            items: countries.map((country) {
                              return DropdownMenuItem(
                                value: country['code'],
                                child: Text(country['code']!),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedCountryCode = val!;
                              });
                            },
                          ),
                        ],
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
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return GestureDetector(
                      onTap: state.status == AuthStatus.loading
                          ? null
                          : () {
                              context.read<AuthBloc>().add(
                                RegisterRequested({
                                  'full_name': fullNameController.text,
                                  'email': emailController.text,
                                  'phone_number': phoneController.text,
                                  'country_code': selectedCountryCode,
                                  'password': passwordController.text,
                                  'password_confirmation':
                                      passwordController.text,
                                }),
                              );
                            },
                      child: state.status == AuthStatus.loading
                          ? const CircularProgressIndicator()
                          : const Button(label: 'Register'),
                    );
                  },
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
      ),
    );
  }
}
