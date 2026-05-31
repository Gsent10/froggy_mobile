import 'package:flutter/material.dart';
import 'package:froggy_mobile/core/utils/utils.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.screenWidth,
      height: context.screenHeight,
      decoration: BoxDecoration(color: kWhiteColor),
      child: Center(child: Image.asset('assets/loading.gif', width: 100)),
    );
  }
}
