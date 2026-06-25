import 'package:flutter/material.dart';
import 'package:pid_seeds/pid_seeds.dart';

class LoadingStateView extends StatelessWidget {
  const LoadingStateView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PidLoadingState(label: message),
    );
  }
}
