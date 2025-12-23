import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required String uid,
    required controller,
    required focusNode,
    required onSave,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Home Screen placeholder'),
    );
  }
}
