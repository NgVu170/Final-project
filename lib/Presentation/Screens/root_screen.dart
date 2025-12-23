import 'package:flutter/material.dart';

class RootScreen extends StatelessWidget {
  final String uid;
  const RootScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logic Debug'),
      ),
      body: Center(
        child: Text('UI has been temporarily removed to focus on logic.\nUser ID: $uid'),
      ),
    );
  }
}
