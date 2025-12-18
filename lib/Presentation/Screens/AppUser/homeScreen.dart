import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../SharedLayout/immersive_layout.dart';

class RootScreen extends StatefulWidget {
  final String uid;
  const RootScreen({super.key, required this.uid});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _buildHomeContent(),
      Center(child: Text("Folder Screen")),
      Center(child: Text("Add Action")),
      Center(child: Text("Archive Screen")),
      Center(child: Text("Profile Screen")),
    ];
  }

  Widget _buildHomeContent() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
      child: const TextField(
        maxLines: null,
        expands: true,
        decoration: InputDecoration(
          hintText: "Viết gì đó đi...",
          border: InputBorder.none,
        ),
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ImmersiveLayout(
      currentIndex: _currentIndex,
      onTabTapped: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      onSearch: (keyword) {
        print("Search ở tab $_currentIndex: $keyword");
      },
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
    );
  }
}