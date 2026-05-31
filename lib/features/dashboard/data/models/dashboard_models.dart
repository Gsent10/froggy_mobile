class DashboardData {
  final List<Wallet> wallets;
  final List<Activity> activities;
  final UserInfo userInfo;

  DashboardData({
    required this.wallets,
    required this.activities,
    required this.userInfo,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      wallets: (json['wallets'] as List? ?? [])
          .map((e) => Wallet.fromJson(e))
          .toList(),
      activities: (json['activities'] as List? ?? [])
          .map((e) => Activity.fromJson(e))
          .toList(),
      userInfo: UserInfo.fromJson(json['customer'] ?? {}),
    );
  }
}

class Wallet {
  final int id;
  final String currencyCode;
  final String currencySymbol;
  final double balance;
  final String? cardNumber; // If available

  Wallet({
    required this.id,
    required this.currencyCode,
    required this.currencySymbol,
    required this.balance,
    this.cardNumber,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] ?? 0,
      currencyCode: json['currency_code'] ?? 'NGN',
      currencySymbol: json['currency_symbol'] ?? '₦',
      balance: (json['balance'] ?? 0).toDouble(),
      cardNumber: json['card_number'],
    );
  }
}

class Activity {
  final int id;
  final String title;
  final String subtitle;
  final double amount;
  final String date;
  final bool isCredit;

  Activity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.isCredit,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown',
      subtitle: json['subtitle'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      date: json['date'] ?? '',
      isCredit: json['is_credit'] ?? false,
    );
  }
}

class UserInfo {
  final String fullName;
  final String? profileImage;

  UserInfo({required this.fullName, this.profileImage});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      fullName: json['full_name'] ?? 'User',
      profileImage: json['profile_image'],
    );
  }
}
