import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:froggy_mobile/core/utils/user_simple_preferences.dart';
import 'package:froggy_mobile/features/launch/bloc/launch_bloc.dart';
import 'package:froggy_mobile/features/launch/presentation/pages/launch_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserSimplePreferences.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LaunchBloc()..add(CheckLaunchStatus()),
      child: MaterialApp(
        title: 'Froggy Mobile',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const LaunchScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
