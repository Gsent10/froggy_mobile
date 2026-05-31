import 'package:flutter/material.dart';
import 'package:froggy_mobile/core/utils/utils.dart';

class WithdrawPage extends StatelessWidget {
  const WithdrawPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: kBgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: kBlackColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Withdraw'),
      ),
      body: const Center(child: Text('Withdraw Feature Coming Soon')),
    );
  }
}
