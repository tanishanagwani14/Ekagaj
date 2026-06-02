import 'package:flutter/material.dart';

import '../../../src/screens/attendance/attendance_screen.dart';
import '../../../src/screens/chat/chat_screen.dart';
import '../../../src/screens/home/home_screen.dart';
import '../../../src/screens/profile/profile_screen.dart';
import '../../../src/screens/tasks/tasks_screen.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int index = 0;

  final screens = const [
    HomeScreen(),
    TasksScreen(),
    ChatScreen(),
    AttendanceScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: index, children: screens),
          Align(
            alignment: Alignment.bottomCenter,
            child: _DashboardBottomNav(
              index: index,
              onChanged: (i) => setState(() => index = i),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardBottomNav extends StatelessWidget {
  const _DashboardBottomNav({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    // Reuse the existing visual component by mapping it.
    // We keep the screen-level BottomNav usages for now; this shell is the new single source.
    return SafeArea(
      top: false,
      child: Container(
        color: Colors.transparent,
        child: Row(
          children: [
            const Expanded(child: SizedBox()),
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }
}

