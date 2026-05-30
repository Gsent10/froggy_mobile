import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:froggy_mobile/features/auth/bloc/auth_bloc.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome to Froggy Mobile Dashboard!'),
      ),
    );
  }
}
