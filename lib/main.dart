import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:froggy_mobile/core/utils/user_simple_preferences.dart';
import 'package:froggy_mobile/features/auth/bloc/auth_bloc.dart';
import 'package:froggy_mobile/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:froggy_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:froggy_mobile/features/auth/presentation/pages/new_password_page.dart';
import 'package:froggy_mobile/features/auth/presentation/pages/register_page.dart';
import 'package:froggy_mobile/features/auth/presentation/pages/verify_otp_page.dart';
import 'package:froggy_mobile/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:froggy_mobile/features/launch/bloc/launch_bloc.dart';
import 'package:froggy_mobile/features/launch/presentation/pages/launch_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserSimplePreferences.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LaunchBloc()..add(CheckLaunchStatus()),
        ),
        BlocProvider(create: (context) => AuthBloc()),
      ],
      child: MaterialApp(
        title: 'Froggy Mobile',
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff5D5FEF)),
          useMaterial3: true,
        ),
        home: const LaunchScreen(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/verify-otp': (context) => const VerifyOtpPage(),
          '/forgot-password': (context) => const ForgotPasswordPage(),
          '/new-password': (context) => const NewPasswordPage(),
          '/dashboard': (context) => const DashboardPage(),
        },
      ),
    );
  }
}
