import 'package:bookdr/views/Doctors/doctors_view.dart';
import 'package:bookdr/views/appointments/appointments_view.dart';
import 'package:bookdr/views/home/home_view.dart';
import 'package:bookdr/views/search/search_view.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';
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
    const SearchView(),
    const DoctorsView(),
    const AppointmentsView(),
    const ProfileView(),
  ];

  // ── Nav metadata ──────────────────────────────────────────────────────────
  static const _navItems = [
    _NavMeta(Icons.home_rounded, 'Home'),
    _NavMeta(Icons.search_rounded, 'Search'),
    _NavMeta(Icons.groups_rounded, 'Doctors'),
    _NavMeta(Icons.calendar_month_rounded, 'Schedule'),
    _NavMeta(Icons.person_rounded, 'Profile'),
  ];

  // ── Colors — orange theme matching CareSync Dr exactly ────────────────────
  static const Color _barColor = Color(
    0xFFD35400,
  ); // AppColors.primaryDark  (dark orange)
  static const Color _buttonColor = Color(
    0xFFE67E22,
  ); // AppColors.primary      (main orange)
  static const Color _bgColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    // Keep status bar icons light over the dark bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      // IndexedStack keeps every screen alive — scroll positions &
      // form data are preserved when switching tabs
      body: IndexedStack(index: _currentIndex, children: _screens),

      // ── Curved Navigation Bar ─────────────────────────────────────────────
      // Scaffold.bottomNavigationBar reserves space automatically,
      // so screens end above the bar — zero overlap with buttons / forms
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 65,

        // The bar background strip
        color: _barColor,

        // The colour of the area that "shows through" behind the curve dip
        backgroundColor: _bgColor,

        // The raised circle behind the active icon
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

// ── Icon + label widget supplied to CurvedNavigationBar.items ─────────────────
// The bar automatically lifts the active item into the raised circle;
// we just style the icon and tiny label below it.
class _CurvedNavIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CurvedNavIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 26),
        // Label is tiny and optional — remove if you prefer icon-only
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 8,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// Simple data class
class _NavMeta {
  final IconData icon;
  final String label;
  const _NavMeta(this.icon, this.label);
}
