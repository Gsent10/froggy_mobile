import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:froggy_mobile/core/utils/utils.dart';
import 'package:froggy_mobile/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:froggy_mobile/features/dashboard/data/models/dashboard_models.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state.status == DashboardStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == DashboardStatus.error) {
            return Center(
              child: Text(state.errorMessage ?? 'An error occurred'),
            );
          }

          if (state.data == null) {
            return const Center(child: Text('No data available'));
          }

          final data = state.data!;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(FetchDashboardData());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.screenWidth * kHorizontalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.menu, color: Colors.grey),
                        Text(
                          'Dashboard',
                          style: SafeGoogleFont(
                            'Ubuntu',
                            fontSize: context.screenWidth * kFontM,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey,
                          ),
                        ),
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: data.userInfo.profileImage != null
                              ? NetworkImage(data.userInfo.profileImage!)
                              : null,
                          child: data.userInfo.profileImage == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Cards Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cards',
                          style: SafeGoogleFont(
                            'Ubuntu',
                            fontSize: context.screenWidth * kFontL,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ADD NEW +',
                          style: SafeGoogleFont(
                            'Ubuntu',
                            fontSize: context.screenWidth * kFontS,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Wallets horizontal list
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: data.wallets.length,
                        itemBuilder: (context, index) {
                          return _WalletCard(
                            wallet: data.wallets[index],
                            ownerName: data.userInfo.fullName,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),
                    // Page Indicator Placeholder
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          data.wallets.length,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == 0
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Recent Activity Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Activity',
                          style: SafeGoogleFont(
                            'Ubuntu',
                            fontSize: context.screenWidth * kFontL,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(Icons.more_horiz, color: Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Activity List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: data.activities.length,
                      itemBuilder: (context, index) {
                        return _ActivityItem(activity: data.activities[index]);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final Wallet wallet;
  final String ownerName;

  const _WalletCard({required this.wallet, required this.ownerName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.screenWidth * 0.85,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          colors: [Color(0xFF00C6FF), Color(0xFF0072FF), Color(0xFF9D50BB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'VISA',
                style: SafeGoogleFont(
                  'Ubuntu',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const Icon(Icons.more_horiz, color: Colors.white),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            wallet.cardNumber ?? '**** **** **** ****',
            style: SafeGoogleFont(
              'Ubuntu',
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Card Holder',
                    style: SafeGoogleFont(
                      'Ubuntu',
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    ownerName,
                    style: SafeGoogleFont(
                      'Ubuntu',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Balance',
                    style: SafeGoogleFont(
                      'Ubuntu',
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    '${wallet.currencySymbol}${wallet.balance.toStringAsFixed(2)}',
                    style: SafeGoogleFont(
                      'Ubuntu',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final Activity activity;

  const _ActivityItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              activity.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: activity.isCredit ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: SafeGoogleFont(
                    'Ubuntu',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  activity.subtitle,
                  style: SafeGoogleFont(
                    'Ubuntu',
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${activity.isCredit ? "+" : "-"} \$${activity.amount.toStringAsFixed(2)}',
                style: SafeGoogleFont(
                  'Ubuntu',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: activity.isCredit ? Colors.green : Colors.red,
                ),
              ),
              Text(
                activity.date,
                style: SafeGoogleFont(
                  'Ubuntu',
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
