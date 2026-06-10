import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/main_bottom_nav.dart';
import '../history/history_view.dart';
import '../home/home_view.dart';
import '../settings/settings_view.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tabIndex = 0;

  final _pages = const [HomeView(), HistoryView(), SettingsView()];

  void _onNavTap(int navIndex) {
    switch (navIndex) {
      case 0:
        setState(() => _tabIndex = 0);
        break;
      case 1:
        Navigator.pushNamed(context, AppConstants.realtimeRoute);
        break;
      case 2:
        setState(() => _tabIndex = 1);
        break;
      case 3:
        setState(() => _tabIndex = 2);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mapping tabIndex (0=Home,1=History,2=Settings) -> navIndex (0,2,3)
    final navIndex = switch (_tabIndex) {
      0 => 0,
      1 => 2,
      _ => 3,
    };

    return Scaffold(
      body: IndexedStack(index: _tabIndex, children: _pages),
      bottomNavigationBar: MainBottomNav(
        currentIndex: navIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
