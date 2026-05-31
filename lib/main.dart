import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:froggy_mobile/core/utils/user_simple_preferences.dart';
import 'package:froggy_mobile/features/auth/bloc/auth_bloc.dart';
import 'package:froggy_mobile/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:froggy_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:froggy_mobile/features/auth/presentation/pages/new_password_page.dart';
import 'package:froggy_mobile/features/auth/presentation/pages/register_page.dart';
import 'package:froggy_mobile/features/auth/presentation/pages/verify_otp_page.dart';
import 'package:froggy_mobile/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:froggy_mobile/features/topup/bloc/topup_bloc.dart';
import 'package:froggy_mobile/features/topup/presentation/pages/topup_result_page.dart';
import 'package:froggy_mobile/features/transfer/bloc/transfer_bloc.dart';
import 'package:froggy_mobile/features/transfer/presentation/pages/transfer_result_page.dart';
import 'package:froggy_mobile/features/wallet/bloc/wallet_bloc.dart';
import 'package:froggy_mobile/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:froggy_mobile/features/topup/presentation/pages/topup_page.dart';
import 'package:froggy_mobile/features/transfer/presentation/pages/transfer_page.dart';
import 'package:froggy_mobile/features/wallet/presentation/pages/wallet_details_page.dart';
import 'package:froggy_mobile/features/wallet/presentation/pages/wallet_list_page.dart';
import 'package:froggy_mobile/features/wallet/presentation/pages/add_wallet_page.dart';
import 'package:froggy_mobile/features/launch/bloc/launch_bloc.dart';
import 'package:froggy_mobile/features/launch/presentation/pages/launch_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserSimplePreferences.init();
  runApp(MyApp());
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
        BlocProvider(
          create: (context) => DashboardBloc()..add(FetchDashboardData()),
        ),
        BlocProvider(create: (context) => WalletBloc()),
        BlocProvider(create: (context) => TransferBloc()),
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
        onGenerateRoute: (settings) {
          if (settings.name == '/wallet-details') {
            final walletId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => WalletDetailsPage(walletId: walletId),
            );
          }
          return null;
        },
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/verify-otp': (context) => const VerifyOtpPage(),
          '/forgot-password': (context) => const ForgotPasswordPage(),
          '/new-password': (context) => const NewPasswordPage(),
          '/dashboard': (context) => const DashboardPage(),
          '/wallet-list': (context) => const WalletListPage(),
          '/transfer': (context) => BlocProvider(
            create: (_) => TransferBloc(),
            child: const TransferPage(),
          ),
          '/transfer-result': (context) => const TransferResultPage(),
          '/topup': (context) => BlocProvider(
            create: (_) => TopupBloc(),
            child: const TopupPage(),
          ),
          '/topup-result': (context) => const TopupResultPage(),
          '/add-wallet': (context) => const AddWalletPage(),
        },
      ),
    );
  }
}
