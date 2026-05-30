import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:froggy_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:froggy_mobile/features/auth/presentation/pages/register_page.dart';
import 'package:froggy_mobile/features/launch/bloc/launch_bloc.dart';

class LaunchScreen extends StatelessWidget {
  const LaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LaunchBloc, LaunchState>(
      listener: (context, state) {
        if (state.status == LaunchStatus.toLogin) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        } else if (state.status == LaunchStatus.toRegister) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const RegisterPage()),
          );
        }
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
