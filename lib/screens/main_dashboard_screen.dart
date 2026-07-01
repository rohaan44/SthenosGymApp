import 'package:app/providers/main_dashboard_provider.dart';
import 'package:app/screens/dashboard_screen.dart';
import 'package:app/screens/member/members_screen.dart';
import 'package:app/screens/payments_screen.dart';
import 'package:app/ui/custom_gradient.dart';
import 'package:app/ui/helpers/app_layout_helper.dart';
import 'package:app/ui/helpers/color_helper.dart';
import 'package:app/ui/helpers/font_size_helper.dart';
import 'package:app/ui/utils/app_gradient.dart';
import 'package:app/ui/utils/app_text.dart';
import 'package:app/ui/utils/asset_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainDashboardScreen extends StatelessWidget {
  const MainDashboardScreen({super.key});

  static const List<_NavItem> _navItems = [
    _NavItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
    ),
    _NavItem(
      label: 'Members',
      icon: Icons.people_outlined,
      activeIcon: Icons.people,
    ),

    _NavItem(
      label: 'Payments',
      icon: Icons.credit_card_outlined,
      activeIcon: Icons.credit_card,
    ),
    // _NavItem(
    //   label: 'Classes',
    //   icon: Icons.calendar_today_outlined,
    //   activeIcon: Icons.calendar_today,
    // ),
    // _NavItem(
    //   label: 'Trainers',
    //   icon: Icons.fitness_center_outlined,
    //   activeIcon: Icons.fitness_center,
    // ),
    // _NavItem(
    //   label: 'Attendance',
    //   icon: Icons.fact_check_outlined,
    //   activeIcon: Icons.fact_check,
    // ),
  ];

  static const List<Widget> _screens = [
    DashboardScreen(),
    MembersScreen(),
    // ClassesScreen(),
    // TrainersScreen(),
    // AttendanceScreen(),
    PaymentsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MainDashboardProvider(),
      child: Builder(
        builder: (context) {
          final width = screenWidth(context);

          // DESKTOP
          if (width >= kDesktopBreak) {
            return Scaffold(
              body: Row(
                children: [
                  const _SidebarNav(navItems: _navItems),
                  Expanded(
                    child: Consumer<MainDashboardProvider>(
                      builder: (context, navProvider, _) =>
                          _screens[navProvider.selectedIndex],
                    ),
                  ),
                ],
              ),
            );
          }

          // TABLET
          if (width >= kPhoneBreak) {
            return Scaffold(
              body: Row(
                children: [
                  const _RailNav(navItems: _navItems),
                  Expanded(
                    child: Consumer<MainDashboardProvider>(
                      builder: (context, navProvider, _) =>
                          _screens[navProvider.selectedIndex],
                    ),
                  ),
                ],
              ),
            );
          }

          // MOBILE
          return Scaffold(
            appBar: AppBar(
              actions: [
                Image.asset(
                  AssetUtils.reciptLogo,
                  width: cw(50),
                  color: AppColor.cFFFFFF,
                  fit: BoxFit.contain,
                ),
                AppText(txt: "Sthenos Gym"),
                SizedBox(width: cw(20)),
              ],
            ),
            drawer: const _MobileDrawer(navItems: _navItems),
            body: Consumer<MainDashboardProvider>(
              builder: (context, navProvider, _) =>
                  _screens[navProvider.selectedIndex],
            ),
          );
        },
      ),
    );
  }

  // Widget build(BuildContext context) {
  //   return ChangeNotifierProvider(
  //     create: (_) => MainDashboardProvider(),
  //     child: Consumer<MainDashboardProvider>(
  //       builder: (context, navProvider, child) {
  //         final width = screenWidth(context);

  //         // ── Desktop (≥1024px): full sidebar ──────────────────────────────────────
  //         if (width >= kDesktopBreak) {
  //           return Scaffold(
  //             backgroundColor: const Color(0xFFF9FAFB),
  //             body: Row(
  //               children: [
  //                 _SidebarNav(
  //                   navItems: _navItems,
  //                   selectedIndex: navProvider.selectedIndex,
  //                   onTap: navProvider.setSelectedIndex,
  //                 ),
  //                 Expanded(child: _screens[navProvider.selectedIndex]),
  //               ],
  //             ),
  //           );
  //         }

  //         // ── Tablet (600–1023px): NavigationRail ──────────────────────────────────
  //         if (width >= kPhoneBreak) {
  //           return Scaffold(
  //             backgroundColor: const Color(0xFFF9FAFB),
  //             body: Row(
  //               children: [
  //                 _RailNav(
  //                   navItems: _navItems,
  //                   selectedIndex: navProvider.selectedIndex,
  //                   onTap: navProvider.setSelectedIndex,
  //                 ),
  //                 Expanded(child: _screens[navProvider.selectedIndex]),
  //               ],
  //             ),
  //           );
  //         }

  //         // ── Phone (<600px): BottomNavigationBar ──────────────────────────────────
  //         return Scaffold(
  //           backgroundColor: const Color(0xFFF9FAFB),
  //           body: _screens[navProvider.selectedIndex],
  //           bottomNavigationBar: NavigationBar(
  //             backgroundColor: Colors.white,
  //             selectedIndex: navProvider.selectedIndex,
  //             labelBehavior:
  //                 NavigationDestinationLabelBehavior.onlyShowSelected,
  //             onDestinationSelected: navProvider.setSelectedIndex,
  //             destinations: _navItems
  //                 .map(
  //                   (item) => NavigationDestination(
  //                     icon: Icon(item.icon),
  //                     selectedIcon: Icon(item.activeIcon),
  //                     label: item.label,
  //                   ),
  //                 )
  //                 .toList(),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }
}

// ─────────────────────────────────────────────────────────────────────────────
// Full sidebar (desktop)
// ─────────────────────────────────────────────────────────────────────────────
class _SidebarNav extends StatelessWidget {
  const _SidebarNav({required this.navItems});

  final List<_NavItem> navItems;

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<MainDashboardProvider>();
    final selectedIndex = navProvider.selectedIndex;
    final onTap = navProvider.setSelectedIndex;
    return SizedBox(
      width: cw(82.5).clamp(200.0, 260.0),
      // color: Colors.white,
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
                  height: 40,
                  width: 40,
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    gradient: AppGradients.redGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Image.asset(
                      AssetUtils.reciptLogo,
                      color: AppColor.cFFFFFF,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(width: cw(3.8)),

                CustomGradientAnimationText(
                  text: "Sthenos Gym",
                  colors: [
                    Color(0xFFDB2016),
                    AppColor.cFFFFFF,

                    Color(0xFF790600),
                  ],
                  duration: Duration(seconds: 5),
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
              padding: EdgeInsets.symmetric(
                horizontal: cw(4.5),
                vertical: ch(2.0),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => onTap(i),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: cw(3.8),
                    vertical: ch(8.9),
                  ),
                  decoration: BoxDecoration(
                    gradient: isActive ? AppGradients.redGradient : null,
                    // color: isActive
                    //     ?
                    //     : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isActive ? item.activeIcon : item.icon,
                        size: cw(6.8).clamp(16.0, 20.0),
                        color: isActive
                            ? AppColor.cFFFFFF
                            : const Color(0xFF6B7280),
                      ),
                      SizedBox(width: cw(3.8)),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: AppFontSize.f12,
                          fontWeight: FontWeight.w500,
                          color: isActive
                              ? AppColor.cFFFFFF
                              : const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          // Spacer(),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [],
          // ),
          // SizedBox(height: ch(12)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Navigation Rail (tablet)
// ─────────────────────────────────────────────────────────────────────────────
class _RailNav extends StatelessWidget {
  const _RailNav({required this.navItems});

  final List<_NavItem> navItems;

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<MainDashboardProvider>();
    final selectedIndex = navProvider.selectedIndex;
    final onTap = navProvider.setSelectedIndex;
    return Container(
      color: Colors.red,
      child: Column(
        children: [
          SizedBox(height: ch(12.2)),
          // Mini logo
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColor.cFFFFFF,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Colors.white,
              size: 22,
            ),
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
              selectedIconTheme: const IconThemeData(
                color: Color(0xFF2563EB),
                size: 22,
              ),
              unselectedIconTheme: const IconThemeData(
                color: Color(0xFF6B7280),
                size: 22,
              ),
              selectedLabelTextStyle: TextStyle(
                color: AppColor.cFFFFFF,
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
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

class _MobileDrawer extends StatelessWidget {
  const _MobileDrawer({required this.navItems});

  final List<_NavItem> navItems;

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<MainDashboardProvider>();
    final selectedIndex = navProvider.selectedIndex;
    final onTap = navProvider.setSelectedIndex;
    return Drawer(
      child: SafeArea(
        child: Container(
          color: AppColor.c151515,

          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(gradient: AppGradients.redGradient),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          AssetUtils.reciptLogo,
                          color: AppColor.cFFFFFF,
                          width: 100,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Sthenos Gym",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, index) => SizedBox(height: ch(6)),

                  itemCount: navItems.length,
                  padding: EdgeInsets.symmetric(horizontal: 16),

                  itemBuilder: (context, index) {
                    final item = navItems[index];
                    final isSelected = selectedIndex == index;
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: AppGradients.redGradient,
                      ),
                      child: ListTile(
                        leading: Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected
                              ? AppColor.cFFFFFF
                              : AppColor.cFFFFFF.withValues(alpha: 0.5),
                        ),
                        title: Text(
                          item.label,
                          style: TextStyle(
                            color: isSelected
                                ? AppColor.cFFFFFF
                                : AppColor.cFFFFFF.withValues(alpha: 0.5),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        selected: isSelected,
                        onTap: () {
                          onTap(index);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    AssetUtils.reciptLogo,
                    color: AppColor.cFFFFFF,
                    width: cw(100),
                  ),
                ],
              ),
              SizedBox(height: ch(12)),
            ],
          ),
        ),
      ),
    );
  }
}
