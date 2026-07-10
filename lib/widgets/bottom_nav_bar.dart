import 'package:bookdr/views/Doctors/doctors_view.dart';
import 'package:bookdr/views/appointments/appointments_view.dart';
import 'package:bookdr/views/home/home_view.dart';
import 'package:bookdr/views/search/search_view.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';
import '../views/dm_view/dm_list_view.dart';   // ← CHANGED: was dm_view.dart
import '../views/profile/profile_view.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // ── Screens ───────────────────────────────────────────────────────────────
  final List<Widget> _screens = [
    const HomeView(),
    const DmListView(),   // ← CHANGED: was const DmView() — that's now a
                           //   chat-room screen that requires a doctorId,
                           //   so it can't live directly in the bottom nav.
    const SearchView(),
    const DoctorsView(),
    const AppointmentsView(),
    const EditProfileView(),
  ];

  // ── Nav metadata ──────────────────────────────────────────────────────────
  static const _navItems = [
    _NavMeta(Icons.home_rounded, 'Home'),
    _NavMeta(Icons.message_rounded, 'Messages'),
    _NavMeta(Icons.search_rounded, 'Search'),
    _NavMeta(Icons.groups_rounded, 'Doctors'),
    _NavMeta(Icons.calendar_month_rounded, 'Schedule'),
    _NavMeta(Icons.person_rounded, 'Profile'),
  ];

  // ── Colors (UNCHANGED) ────────────────────────────────────────────────────
  static const Color _barColor = Color(0xFFD35400);
  static const Color _buttonColor = Color(0xFFE67E22);
  static const Color _bgColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      body: IndexedStack(index: _currentIndex, children: _screens),

      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 60, // 🔥 reduced height (fix spacing)
        color: _barColor,
        backgroundColor: _bgColor,
        buttonBackgroundColor: _buttonColor,
        animationDuration: const Duration(milliseconds: 320),
        animationCurve: Curves.easeInOutCubic,

        items: _navItems
            .map((n) => _CurvedNavIcon(icon: n.icon, label: n.label))
            .toList(),

        onTap: (index) {
          HapticFeedback.selectionClick();
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}

// ── FIXED NAV ICON (LESS SPACE, CLEAN LOOK) ────────────────────────────────
class _CurvedNavIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CurvedNavIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0), // 🔥 reduce bottom gap
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24), // slightly smaller

          const SizedBox(height: 1), // tight spacing

          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 7,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── DATA CLASS ─────────────────────────────────────────────────────────────
class _NavMeta {
  final IconData icon;
  final String label;
  const _NavMeta(this.icon, this.label);
}