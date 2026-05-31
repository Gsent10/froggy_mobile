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
      activities:
          (json['recentTransactions'] as List? ??
                  json['activities'] as List? ??
                  [])
              .map((e) => Activity.fromJson(e))
              .toList(),
      userInfo: UserInfo.fromJson(json['customer'] ?? {}),
    );
  }
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

class Wallet {
  final int id;
  final String currencyCode;
  final String currencySymbol;
  final double balance;
  final String? cardNumber;

  Wallet({
    required this.id,
    required this.currencyCode,
    required this.currencySymbol,
    required this.balance,
    this.cardNumber,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    const currencySymbols = {
      'GBP': '£',
      'NGN': '₦',
      'USD': '\$',
      'GHS': 'GH₵',
      'KES': 'KSh',
    };

    final code = json['currency_code'] ?? 'NGN';

    return Wallet(
      id: json['id'] ?? 0,
      currencyCode: code,
      currencySymbol: currencySymbols[code] ?? '₦',
      balance: _parseDouble(json['balance']),
      cardNumber: json['card_number'],
    );
  }
}

class Activity {
  final int id;
  final String reference;
  final String type;
  final String status;
  final double amount;
  final String currencyCode;
  final String paymentMethod;
  final String? processedAt;
  final String createdAt;
  final bool isCredit;

  Activity({
    required this.id,
    required this.reference,
    required this.type,
    required this.status,
    required this.amount,
    required this.currencyCode,
    required this.paymentMethod,
    this.processedAt,
    required this.createdAt,
    required this.isCredit,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] ?? 0,
      reference: json['reference'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      amount: _parseDouble(json['amount']),
      currencyCode: json['currency_code'] ?? 'NGN',
      paymentMethod: json['payment_method'] ?? '',
      processedAt: json['processed_at'],
      createdAt: json['created_at'] ?? '',
      isCredit: json['type'] == 'topup',
    );
  }
}

class Log {
  final int id;
  final String type;
  final String status;
  final double amount;
  final String currencyCode;
  final String description;
  final String createdAt;
  final bool isCredit;

  Log({
    required this.id,
    required this.type,
    required this.status,
    required this.amount,
    required this.currencyCode,
    required this.description,
    required this.createdAt,
    required this.isCredit,
  });

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      amount: _parseDouble(json['amount']),
      currencyCode: json['currency_code'] ?? 'NGN',
      description: json['description'] ?? '',
      createdAt: json['created_at'] ?? '',
      isCredit: json['type'] == 'topup',
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
