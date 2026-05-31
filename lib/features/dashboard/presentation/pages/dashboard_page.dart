import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:froggy_mobile/core/utils/utils.dart';
import 'package:froggy_mobile/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:froggy_mobile/features/dashboard/presentation/widgets/home_page.dart';
import 'package:froggy_mobile/features/dashboard/presentation/widgets/rates_page.dart';
import 'package:froggy_mobile/features/dashboard/presentation/widgets/settings_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  final List<Widget> _pages = const [HomePage(), RatesPage(), SettingsPage()];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return Scaffold(
          body: _pages[state.currentIndex],
          bottomNavigationBar: Container(
            height: context.screenHeight * 0.09,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: BottomNavigationBar(
                  currentIndex: state.currentIndex,
                  onTap: (index) {
                    context.read<DashboardBloc>().add(TabChanged(index));
                  },
                  backgroundColor: kWhiteColor,
                  selectedItemColor: kPrimaryColor,
                  unselectedItemColor: Colors.grey,
                  type: BottomNavigationBarType.fixed,
                  elevation: 0,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home, size: 30),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.add_chart, size: 30),
                      label: 'Rates',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.settings, size: 30),
                      label: 'Settings',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
