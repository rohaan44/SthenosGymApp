import 'package:app/auth/auth_providers/auth_provider.dart';
import 'package:app/main.dart';
import 'package:app/providers/main_dashboard_provider.dart';
import 'package:app/screens/dashboard_screen.dart';
import 'package:app/screens/member/members_screen.dart';
import 'package:app/screens/payments_screen.dart';
import 'package:app/service/inactivity_service.dart';
import 'package:app/ui/app_primary_button.dart';
import 'package:app/ui/custom_gradient.dart';
import 'package:app/ui/helpers/app_layout_helper.dart';
import 'package:app/ui/helpers/color_helper.dart';
import 'package:app/ui/helpers/font_size_helper.dart';
import 'package:app/ui/utils/app_gradient.dart';
import 'package:app/ui/utils/app_text.dart';
import 'package:app/ui/utils/asset_utils.dart';
import 'package:app/ui/utils/primary_textfield.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:universal_html/html.dart' as html;

// ─────────────────────────────────────────────────────────────────────────────
// Common tap handler used by all nav widgets (sidebar, rail, drawer)
// ─────────────────────────────────────────────────────────────────────────────
// void _handleNavTap(BuildContext context, int index, List<_NavItem> navItems) {
//   final item = navItems[index];

//   if (item.label == 'Change Password') {
//     // AuthProvider must be provided above this widget (e.g. in main.dart)
//     showChangePasswordDialog(context);
//     return;
//   }
//   if (item.label == 'Log Out') {
//     // AuthProvider must be provided above this widget (e.g. in main.dart)
//     // context.read<AuthProvider>().logout(context);

//     showLogoutDialog(context);
//     return;
//   }

//   context.read<MainDashboardProvider>().setSelectedIndex(index);
// }

void _handleNavTap(BuildContext context, int index, List<_NavItem> navItems) {
  final item = navItems[index];

  switch (item.label) {
    case 'Change Password':
      showChangePasswordDialog(context);
      return;

    case 'Log Out':
      showLogoutDialog(context);
      return;

    default:
      context.read<MainDashboardProvider>().setSelectedIndex(index);
  }
}

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
    _NavItem(
      label: 'Change Password',
      icon: Icons.lock_outlined,
      activeIcon: Icons.lock,
    ),
    _NavItem(
      label: 'Log Out',
      icon: Icons.logout,
      activeIcon: Icons.logout_outlined,
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
    // ── Inactivity detection wrapper ─────────────────────────────────────────
    // A single Listener at the authenticated root intercepts every pointer
    // event (tap, scroll, drag, swipe) app-wide and resets the inactivity
    // timer. HitTestBehavior.translucent ensures events reach child widgets
    // normally — the Listener is purely observational.
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => InactivityService().resetTimer(),
      onPointerMove: (_) => InactivityService().resetTimer(),
      onPointerUp: (_) => InactivityService().resetTimer(),
      child: ChangeNotifierProvider(
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
                        builder: (context, navProvider, _) {
                          // Guard: selectedIndex could point at "Log Out" (index 3)
                          // which has no matching screen, so clamp it.
                          final index =
                              navProvider.selectedIndex < _screens.length
                              ? navProvider.selectedIndex
                              : 0;
                          return _screens[index];
                        },
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
                        builder: (context, navProvider, _) {
                          final index =
                              navProvider.selectedIndex < _screens.length
                              ? navProvider.selectedIndex
                              : 0;
                          return _screens[index];
                        },
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
                  SizedBox(width: cw(8)),

                  Consumer<MainDashboardProvider>(
                    builder: (context, dashboardModel, _) {
                      return notificationButton(
                        context: context,
                        model: dashboardModel,
                        isWeb: false,
                      );
                    },
                  ),
                  SizedBox(width: cw(20)),
                ],
              ),
              drawer: const _MobileDrawer(navItems: _navItems),
              body: Consumer<MainDashboardProvider>(
                builder: (context, navProvider, _) {
                  final index = navProvider.selectedIndex < _screens.length
                      ? navProvider.selectedIndex
                      : 0;
                  return _screens[index];
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

final GlobalKey notificationKey = GlobalKey();
OverlayEntry? notificationOverlay;

OverlayEntry buildNotificationOverlay(
  BuildContext context,
  MainDashboardProvider model,
) {
  RenderBox box =
      notificationKey.currentContext!.findRenderObject() as RenderBox;

  Offset position = box.localToGlobal(Offset.zero);
  // int visibleCount = 10;

  // final List<Map<String, dynamic>> notifications = [
  //   {
  //     "color": Colors.amber,
  //     "icon": Icons.schedule,
  //     "title": "Membership expires in 3 days",
  //     "subtitle": "Ahmed Ali",
  //     "time": "Today",
  //   },
  //   {
  //     "color": Colors.red,
  //     "icon": Icons.warning,
  //     "title": "Membership expired today",
  //     "subtitle": "Ali Khan",
  //     "time": "Today",
  //   },
  //   {
  //     "color": Colors.orange,
  //     "icon": Icons.payment,
  //     "title": "1 Month Fee Pending",
  //     "subtitle": "Salman",
  //     "time": "Yesterday",
  //   },
  //   {
  //     "color": Colors.grey,
  //     "icon": Icons.person_off,
  //     "title": "Admission Expired",
  //     "subtitle": "Huzaifa",
  //     "time": "15 Jul",
  //   },

  //   /// Testing (20 items)
  //   ...List.generate(
  //     8,
  //     (index) => {
  //       "color": Colors.amber,
  //       "icon": Icons.schedule,
  //       "title": "Membership expires in 3 days",
  //       "subtitle": "Member ${index + 5}",
  //       "time": "Today",
  //     },
  //   ),
  // ];

  return OverlayEntry(
    builder: (_) {
      return Stack(
        children: [
          /// Close on outside tap
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                notificationOverlay?.remove();
                notificationOverlay = null;
              },
              child: Container(color: Colors.transparent),
            ),
          ),

          Positioned(
            top: position.dy + 48,
            left: position.dx - 80,
            // right: 150,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: cw(135),
                constraints: const BoxConstraints(maxHeight: 420),
                decoration: BoxDecoration(
                  color: AppColor.c252525,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColor.primary),
                  boxShadow: const [
                    BoxShadow(blurRadius: 15, color: Colors.black26),
                  ],
                ),
                child: Column(
                  children: [
                    /// Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: AppGradients.redGradient,
                            ),
                            child: Icon(
                              Icons.notifications_outlined,
                              color: AppColor.cFFFFFF,
                            ),
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: AppText(
                              txt: "Notifications",
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          // TextButton(
                          //   onPressed: () {},
                          //   child: AppText(
                          //     txt: "View All",
                          //     fontSize: AppFontSize.f12,
                          //   ),
                          // ),
                        ],
                      ),
                    ),

                    Divider(height: 1),
                    Expanded(
                      child: Skeletonizer(
                        enabled: false,

                        child: ListView.builder(
                          itemCount:
                              model.visibleCount > model.notifications.length
                              ? model.notifications.length
                              : model.visibleCount,
                          shrinkWrap: true,
                          primary: false,
                          padding: EdgeInsets.zero,

                          itemBuilder: (context, index) {
                            final item = model.notifications[index];

                            return Column(
                              children: [
                                NotificationTile(
                                  onNotificationTap: () {},
                                  sendReminder: () {
                                    final rawPhone =
                                        item["phone"]?.toString() ?? "";
                                    final phone = rawPhone.replaceAll(
                                      RegExp(r'\D'),
                                      '',
                                    );
                                    if (phone.isNotEmpty) {
                                      final message = Uri.encodeComponent(
                                        "your fees monthly has beeen expired kindly pay the fees",
                                      );
                                      final url =
                                          "https://wa.me/$phone?text=$message";
                                      html.window.open(url, '_blank');
                                    }
                                  },
                                  color: item["color"],
                                  icon: item["icon"],
                                  title: item["title"],
                                  subtitle: item["subtitle"],
                                  time: item["time"],
                                ),
                                // NotificationTile(
                                //   color: Colors.amber,
                                //   icon: Icons.schedule,
                                //   title: "Membership expires in 3 days",
                                //   subtitle: "Ahmed Ali",
                                //   time: "Today",
                                // ),

                                // NotificationTile(
                                //   color: Colors.red,
                                //   icon: Icons.warning,
                                //   title: "Membership expired today",
                                //   subtitle: "Ali Khan",
                                //   time: "Today",
                                // ),

                                // NotificationTile(
                                //   color: Colors.orange,
                                //   icon: Icons.payment,
                                //   title: "1 Month Fee Pending",
                                //   subtitle: "Salman",
                                //   time: "Yesterday",
                                // ),

                                // NotificationTile(
                                //   color: Colors.grey,
                                //   icon: Icons.person_off,
                                //   title: "Admission Expired",
                                //   subtitle: "Huzaifa",
                                //   time: "15 Jul",
                                // ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    if (model.notifications.length > model.visibleCount)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: ch(10)),
                        child: InkWell(
                          onTap: () {
                            model.setCount();
                            notificationOverlay?.markNeedsBuild();
                            // setState(() {
                            //   visibleCount += 10;
                            // });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: ch(12)),
                            child: Text(
                              "Load More",
                              style: TextStyle(
                                color: AppColor.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class NotificationTile extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final VoidCallback onNotificationTap;
  final VoidCallback sendReminder;

  const NotificationTile({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.sendReminder,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onNotificationTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(.15),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    txt: title,
                    fontSize: AppFontSize.f15 - 1.5,
                    fontWeight: FontWeight.w600,
                    color: AppColor.cFFFFFF,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    txt: "$subtitle • $time",
                    color: Colors.grey.shade400,
                    fontSize: AppFontSize.f14,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AppButton(
              width: 95,
              height: 28,
              borderRadius: 6,
              fontSize: 10,
              buttonColor: AppColor.primary,
              textColor: AppColor.cFFFFFF,
              text: "Send Reminder",
              onPressed: sendReminder,
            ),
          ],
        ),
      ),
    );
  }
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

    return SizedBox(
      width: cw(82.5).clamp(200.0, 260.0),
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
                onTap: () => _handleNavTap(context, i, navItems),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: cw(3.8),
                    vertical: ch(8.9),
                  ),
                  decoration: BoxDecoration(
                    gradient: isActive ? AppGradients.redGradient : null,
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
                      AppText(
                        txt: item.label,
                        fontSize: AppFontSize.f12,
                        fontWeight: FontWeight.w500,
                        color: isActive
                            ? AppColor.cFFFFFF
                            : const Color(0xFF374151),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Image.asset(AssetUtils.titleLogo1, width: cw(25))],
          ),
          SizedBox(height: ch(12)),
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

    return Container(
      color: AppColor.c151515,
      child: Column(
        children: [
          SizedBox(height: ch(12.2)),
          // Mini logo
          Image.asset(
            AssetUtils.tabletLogo,
            // color: AppColor.cFFFFFF,
            width: cw(60),
            height: ch(60),
            fit: BoxFit.contain,
          ),
          SizedBox(height: ch(8.1)),
          const Divider(height: 1, color: Color(0xFF2E2E2E)),
          SizedBox(height: ch(4.1)),
          Expanded(
            child: NavigationRail(
              backgroundColor: AppColor.c151515,
              indicatorColor: const Color(0xFFDB2016).withValues(alpha: 0.15),
              selectedIndex: selectedIndex < navItems.length
                  ? selectedIndex
                  : 0,
              onDestinationSelected: (index) =>
                  _handleNavTap(context, index, navItems),
              labelType: NavigationRailLabelType.selected,
              selectedIconTheme: const IconThemeData(
                color: Color(0xFFDB2016),
                size: 24,
              ),
              unselectedIconTheme: IconThemeData(
                color: AppColor.cFFFFFF.withValues(alpha: 0.5),
                size: 22,
              ),
              selectedLabelTextStyle: TextStyle(
                color: AppColor.cFFFFFF,
                fontSize: AppFontSize.f11,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: AppColor.cFFFFFF.withValues(alpha: 0.5),
                fontSize: AppFontSize.f11,
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
  final VoidCallback? onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.onTap,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Mobile drawer
// ─────────────────────────────────────────────────────────────────────────────
class _MobileDrawer extends StatelessWidget {
  const _MobileDrawer({required this.navItems});

  final List<_NavItem> navItems;

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<MainDashboardProvider>();
    final selectedIndex = navProvider.selectedIndex;

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
                          // Close the drawer first, then handle the action.
                          Navigator.pop(context);
                          _handleNavTap(context, index, navItems);
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
                    AssetUtils.titleLogo1,
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

Future<void> showChangePasswordDialog(BuildContext context) async {
  final model = context.read<AuthProvider>();

  model.currentPasswordCtrl.clear();
  model.newPasswordCtrl.clear();
  model.confirmPasswordCtrl.clear();

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xff151515),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFDB2016).withValues(alpha: .30),
              ),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1C1C1C), Color(0xff151515)],
              ),
            ),
            child: Consumer<AuthProvider>(
              builder: (context, model, child) {
                return SingleChildScrollView(
                  child: Form(
                    key: model.changePasswordFormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 65,
                          width: 65,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFDB2016), Color(0xFF790600)],
                            ),
                          ),
                          child: const Icon(
                            Icons.lock_reset_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          "Change Password",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Enter your current password and create a new password.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .60),
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 24),

                        primaryTextField(
                          controller: model.currentPasswordCtrl,
                          hintText: "Current Password",
                          obscureText: model.hideCurrentPassword,
                          fillColor: const Color(0xff151515),
                          suffixIcon: IconButton(
                            onPressed: model.toggleCurrentPassword,
                            icon: Icon(
                              model.hideCurrentPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white70,
                            ),
                          ),

                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Colors.white70,
                          ),
                          textInputAction: TextInputAction.next,

                          validator: model.currentPasswordValidator,
                        ),

                        const SizedBox(height: 16),

                        primaryTextField(
                          controller: model.newPasswordCtrl,
                          hintText: "New Password",
                          obscureText: model.hideNewPassword,
                          fillColor: const Color(0xff151515),
                          suffixIcon: IconButton(
                            onPressed: model.toggleNewPassword,
                            icon: Icon(
                              model.hideNewPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white70,
                            ),
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Colors.white70,
                          ),
                          textInputAction: TextInputAction.next,

                          validator: model.newPasswordValidator,
                        ),

                        const SizedBox(height: 16),

                        primaryTextField(
                          controller: model.confirmPasswordCtrl,
                          hintText: "Confirm Password",
                          obscureText: model.hideConfirmPassword,
                          fillColor: const Color(0xff151515),
                          suffixIcon: IconButton(
                            onPressed: model.toggleConfirmPassword,
                            icon: Icon(
                              model.hideConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white70,
                            ),
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Colors.white70,
                          ),
                          textInputAction: TextInputAction.done,
                          validator: model.confirmPasswordValidator,
                        ),

                        const SizedBox(height: 28),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: .25),
                                  ),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Cancel"),
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: AbsorbPointer(
                                absorbing: model.loading,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () async {
                                    FocusScope.of(context).unfocus();

                                    if (!model
                                        .changePasswordFormKey
                                        .currentState!
                                        .validate()) {
                                      return;
                                    }

                                    final msg = await model.changePassword(
                                      currentPassword: model
                                          .currentPasswordCtrl
                                          .text
                                          .trim(),
                                      newPassword: model.newPasswordCtrl.text
                                          .trim(),
                                    );

                                    if (!context.mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(msg)),
                                    );

                                    if (msg ==
                                        "Password changed successfully.") {
                                      model.currentPasswordCtrl.clear();
                                      model.newPasswordCtrl.clear();
                                      model.confirmPasswordCtrl.clear();

                                      Navigator.pop(context);
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    alignment: Alignment.center,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFDB2016),
                                          Color(0xFF790600),
                                        ],
                                      ),
                                    ),
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      child: model.loading
                                          ? const SizedBox(
                                              key: ValueKey("loading"),
                                              height: 22,
                                              width: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                          : const Text(
                                              "Change Password",
                                              key: ValueKey("text"),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

Future<void> showLogoutDialog(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 420,
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xff151515),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFDB2016).withValues(alpha: 0.25),
          ),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1C1C1C), Color(0xff151515)],
          ),
        ),
        child: Consumer<AuthProvider>(
          builder: (context, model, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 65,
                  width: 65,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFDB2016), Color(0xFF790600)],
                    ),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Are you sure you want to logout from your account?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: AbsorbPointer(
                        absorbing: model.loading,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () async {
                            await model.logoutContextFree(appNavigatorKey);
                          },
                          child: Container(
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFDB2016), Color(0xFF790600)],
                              ),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: model.loading
                                  ? const SizedBox(
                                      key: ValueKey("loading"),
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      "Logout",
                                      key: ValueKey("logout"),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}

// Widget notificationButton({
//   required BuildContext context,

//   required MainDashboardProvider model,
// }) {
//   return Stack(
//     clipBehavior: Clip.none,
//     children: [
//       GestureDetector(
//         key: notificationKey,
//         onTap: () {
//           if (notificationOverlay == null) {
//             notificationOverlay = buildNotificationOverlay(context, model);
//             Overlay.of(context).insert(notificationOverlay!);
//           } else {
//             notificationOverlay!.remove();
//             notificationOverlay = null;
//           }
//         },
//         child: Container(
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: AppColor.c252525,
//             border: Border.all(color: AppColor.c151515, width: 1.2),
//           ),
//           child: Icon(
//             Icons.notifications_outlined,
//             size: cw(16),
//             color: AppColor.cFFFFFF,
//           ),
//         ),
//       ),

//       /// Notification Count
//       if (model.notifications.isNotEmpty)
//         Positioned(
//           top: -8,
//           right: 0,
//           child: Container(
//             padding: EdgeInsets.all(cw(4)),
//             constraints: BoxConstraints(minWidth: cw(13), minHeight: ch(13)),
//             decoration: BoxDecoration(
//               gradient: AppGradients.redGradient,
//               shape: BoxShape.circle,
//               border: Border.all(color: AppColor.cFFFFFF, width: 1),
//             ),
//             child: Center(
//               child: Text(
//                 model.notifications.length > 99
//                     ? "99+"
//                     : model.notifications.length.toString(),
//                 style: TextStyle(
//                   fontSize: 9,
//                   fontWeight: FontWeight.bold,
//                   color: AppColor.cFFFFFF,
//                 ),
//               ),
//             ),
//           ),
//         ),
//     ],
//   );
// }

Widget notificationButton({
  required BuildContext context,
  required MainDashboardProvider model,
  bool isWeb = false,
}) {
  final double buttonSize = isWeb ? 42 : ch(42);
  final double iconSize = isWeb ? 18 : ch(18);
  final double badgeSize = isWeb ? 18 : ch(20);
  final double badgeFont = isWeb ? AppFontSize.f10 : 6;

  return Stack(
    clipBehavior: Clip.none,
    children: [
      GestureDetector(
        key: notificationKey,
        onTap: () {
          if (notificationOverlay == null) {
            notificationOverlay = buildNotificationOverlay(context, model);
            Overlay.of(context).insert(notificationOverlay!);
          } else {
            notificationOverlay!.remove();
            notificationOverlay = null;
          }
        },
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColor.c252525,
            border: Border.all(color: AppColor.primary, width: 1.2),
          ),
          child: Icon(
            Icons.notifications_outlined,
            size: iconSize,
            color: AppColor.cFFFFFF,
          ),
        ),
      ),

      if (model.notifications.isNotEmpty)
        Positioned(
          top: -5,
          right: -2,
          child: Container(
            width: badgeSize,
            height: badgeSize,
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              gradient: AppGradients.redGradient,
              shape: BoxShape.circle,
              border: Border.all(color: AppColor.cFFFFFF, width: 1),
            ),
            child: Center(
              child: AppText(
                txt: model.notifications.length > 99
                    ? "99+"
                    : model.notifications.length.toString(),
                fontSize: badgeFont,
                fontWeight: FontWeight.bold,
                color: AppColor.cFFFFFF,
              ),
            ),
          ),
        ),
    ],
  );
}
