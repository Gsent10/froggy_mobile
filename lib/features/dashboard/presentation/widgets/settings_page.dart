import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:froggy_mobile/core/utils/utils.dart';
import 'package:froggy_mobile/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:froggy_mobile/features/auth/bloc/auth_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return Container(
          width: context.screenWidth,
          height: context.screenHeight,
          padding: EdgeInsets.symmetric(
            horizontal: context.screenWidth * kHorizontalPadding,
          ),
          color: kBgColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: context.screenHeight * kBarHeight),

              CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xffE8EDF8),
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 70,
                  color: kPrimaryColor,
                ),
              ),

              SizedBox(height: 16),

              Text(
                'Godsent Agundu',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: context.screenHeight * kSpacingL),

              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    _settingsItem(context, 'Account Settings', Icons.settings),
                    _settingsItem(
                      context,
                      'Notifications',
                      Icons.notifications,
                    ),
                    _settingsItem(context, 'Privacy', Icons.lock),
                    _settingsItem(
                      context,
                      'Help & Support',
                      Icons.help_outline,
                    ),
                    GestureDetector(
                      onTap: () {
                        // Handle logout action
                        context.read<AuthBloc>().add(LogoutRequested());
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil('/login', (route) => false);
                      },
                      child: _settingsItem(context, 'Logout', Icons.logout),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _settingsItem(BuildContext context, String label, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, size: 20),
                SizedBox(width: 16),
                Text(
                  label,
                  style: SafeGoogleFont(
                    'Ubuntu',
                    fontSize: context.screenWidth * kFontM,
                    fontWeight: FontWeight.w400,
                    color: kBlackColor,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios, size: 15),
          ],
        ),
        Container(
          width: double.infinity,
          height: 0.5,
          color: Colors.black.withOpacity(0.2),
          margin: EdgeInsets.only(
            top: context.screenHeight * kSpacingS,
            bottom: context.screenHeight * kSpacingL,
          ),
        ),
      ],
    );
  }
}
