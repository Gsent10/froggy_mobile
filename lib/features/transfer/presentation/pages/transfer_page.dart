import 'package:flutter/material.dart';
import 'package:froggy_mobile/core/utils/utils.dart';

class TransferPage extends StatelessWidget {
  const TransferPage({super.key});

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
        title: const Text('Transfer'),
      ),
      body: const Center(child: Text('Transfer Feature Coming Soon')),
    );
  }
}
