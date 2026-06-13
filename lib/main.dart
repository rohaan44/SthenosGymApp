import 'package:app/ui/helpers/font_size_helper.dart';
import 'package:app/providers/gym_provider.dart';
import 'package:app/screens/attendance_screen.dart';
import 'package:app/screens/classes_screen.dart';
import 'package:app/screens/dashboard_screen.dart';
import 'package:app/screens/members_screen.dart';
import 'package:app/screens/payments_screen.dart';
import 'package:app/screens/trainers_screen.dart';
import 'package:app/ui/helpers/app_layout_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GymProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // Sizer must wrap MaterialApp to provide .w / .h / .sp extensions
    return Sizer(
      builder: (context, orientation, screenType) => MaterialApp(
        title: 'GymManager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2563EB),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Lato',
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            color: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
        ),
        home: const MainScaffold(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main scaffold with 3-tier responsive navigation
// ─────────────────────────────────────────────────────────────────────────────
class MainNavigationProvider extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key});

  static const List<_NavItem> _navItems = [
    _NavItem(label: 'Dashboard',  icon: Icons.dashboard_outlined,     activeIcon: Icons.dashboard),
    _NavItem(label: 'Members',    icon: Icons.people_outlined,         activeIcon: Icons.people),
    _NavItem(label: 'Classes',    icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today),
    _NavItem(label: 'Trainers',   icon: Icons.fitness_center_outlined, activeIcon: Icons.fitness_center),
    _NavItem(label: 'Attendance', icon: Icons.fact_check_outlined,     activeIcon: Icons.fact_check),
    _NavItem(label: 'Payments',   icon: Icons.credit_card_outlined,    activeIcon: Icons.credit_card),
  ];

  static const List<Widget> _screens = [
    DashboardScreen(),
    MembersScreen(),
    ClassesScreen(),
    TrainersScreen(),
    AttendanceScreen(),
    PaymentsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MainNavigationProvider(),
      child: Consumer<MainNavigationProvider>(
        builder: (context, navProvider, child) {
          final width = screenWidth(context);

          // ── Desktop (≥1024px): full sidebar ──────────────────────────────────────
          if (width >= kDesktopBreak) {
            return Scaffold(
              backgroundColor: const Color(0xFFF9FAFB),
              body: Row(
                children: [
                  _SidebarNav(
                    navItems: _navItems,
                    selectedIndex: navProvider.selectedIndex,
                    onTap: navProvider.setSelectedIndex,
                  ),
                  Expanded(child: _screens[navProvider.selectedIndex]),
                ],
              ),
            );
          }

          // ── Tablet (600–1023px): NavigationRail ──────────────────────────────────
          if (width >= kPhoneBreak) {
            return Scaffold(
              backgroundColor: const Color(0xFFF9FAFB),
              body: Row(
                children: [
                  _RailNav(
                    navItems: _navItems,
                    selectedIndex: navProvider.selectedIndex,
                    onTap: navProvider.setSelectedIndex,
                  ),
                  Expanded(child: _screens[navProvider.selectedIndex]),
                ],
              ),
            );
          }

          // ── Phone (<600px): BottomNavigationBar ──────────────────────────────────
          return Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            body: _screens[navProvider.selectedIndex],
            bottomNavigationBar: NavigationBar(
              backgroundColor: Colors.white,
              selectedIndex: navProvider.selectedIndex,
              labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
              onDestinationSelected: navProvider.setSelectedIndex,
              destinations: _navItems
                  .map(
                    (item) => NavigationDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.activeIcon),
                      label: item.label,
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Full sidebar (desktop)
// ─────────────────────────────────────────────────────────────────────────────
class _SidebarNav extends StatelessWidget {
  const _SidebarNav({
    required this.navItems,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<_NavItem> navItems;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cw(82.5).clamp(200.0, 260.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ch(8.1)),
          // Logo / brand
          Padding(
            padding: EdgeInsets.all(cw(7.5)),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(cw(3.0)),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.fitness_center, color: Colors.white, size: cw(8.2).clamp(16.0, 22.0)),
                ),
                SizedBox(width: cw(3.8)),
                Expanded(
                  child: Text(
                    'SthenosGymApp',
                    style: TextStyle(
                      fontSize: AppFontSize.f13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          SizedBox(height: ch(6.5)),
          // Nav items
          ...navItems.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final isActive = i == selectedIndex;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: cw(4.5), vertical: ch(2.0)),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => onTap(i),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: cw(3.8), vertical: ch(8.9)),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFFEFF6FF) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isActive ? item.activeIcon : item.icon,
                        size: cw(6.8).clamp(16.0, 20.0),
                        color: isActive ? const Color(0xFF2563EB) : const Color(0xFF6B7280),
                      ),
                      SizedBox(width: cw(3.8)),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: AppFontSize.f12,
                          fontWeight: FontWeight.w500,
                          color: isActive ? const Color(0xFF2563EB) : const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Navigation Rail (tablet)
// ─────────────────────────────────────────────────────────────────────────────
class _RailNav extends StatelessWidget {
  const _RailNav({
    required this.navItems,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<_NavItem> navItems;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(height: ch(12.2)),
          // Mini logo
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.fitness_center, color: Colors.white, size: 22),
          ),
          SizedBox(height: ch(8.1)),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          SizedBox(height: ch(4.1)),
          Expanded(
            child: NavigationRail(
              backgroundColor: Colors.white,
              selectedIndex: selectedIndex,
              onDestinationSelected: onTap,
              labelType: NavigationRailLabelType.selected,
              selectedIconTheme: const IconThemeData(color: Color(0xFF2563EB), size: 22),
              unselectedIconTheme: const IconThemeData(color: Color(0xFF6B7280), size: 22),
              selectedLabelTextStyle: TextStyle(
                color: const Color(0xFF2563EB),
                fontSize: AppFontSize.f12,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: const Color(0xFF6B7280),
                fontSize: AppFontSize.f12,
              ),
              destinations: navItems
                  .map(
                    (item) => NavigationRailDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.activeIcon),
                      label: Text(item.label),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data class
// ─────────────────────────────────────────────────────────────────────────────
class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const _NavItem({required this.label, required this.icon, required this.activeIcon});
}