import 'dart:async';

import 'package:app/auth/auth_providers/auth_provider.dart';
import 'package:app/ui/app_primary_button.dart';
import 'package:app/ui/helpers/color_helper.dart';
import 'package:app/ui/helpers/font_size_helper.dart';
import 'package:app/ui/utils/app_gradient.dart';
import 'package:app/ui/utils/app_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// InactivityService — singleton
//
// Responsibilities:
//   • Dual timer: 8-min warning popup, 10-min auto-logout
//   • Listener wrapper in MainDashboardScreen calls [resetTimer] on every
//     pointer event (tap / scroll / drag)
//   • HardwareKeyboard handler for Web keypresses
//   • WidgetsBindingObserver for app pause/resume:
//       – paused  → cancel timers, record pause timestamp
//       – resumed → if elapsed ≥ 10 min → show expiry dialog then logout
//                   else              → restart timers fresh
//
// Wiring:
//   • start() called from AuthGate when user logs in
//   • stop()  called from AuthGate when user logs out (or is null)
//   • resetTimer() called from the Listener wrapper in MainDashboardScreen
// ─────────────────────────────────────────────────────────────────────────────
class InactivityService with WidgetsBindingObserver {
  // ── Singleton ─────────────────────────────────────────────────
  static final InactivityService _instance = InactivityService._internal();
  factory InactivityService() => _instance;
  InactivityService._internal();

  // ── Durations ─────────────────────────────────────────────────
  static const Duration _warningAt = Duration(minutes: 8);
  static const Duration _logoutAt = Duration(minutes: 10);

  // ── State ─────────────────────────────────────────────────────
  Timer? _warningTimer;
  Timer? _logoutTimer;
  bool _warningShown = false;
  bool _isRunning = false;
  DateTime? _pausedAt;
  bool _keyboardHandlerAdded = false;

  GlobalKey<NavigatorState>? _navKey;
  AuthProvider? _authProvider;

  // ─────────────────────────────────────────────────────────────
  // Public API
  // ─────────────────────────────────────────────────────────────

  /// Call after successful login.
  void start(GlobalKey<NavigatorState> navKey, AuthProvider authProvider) {
    if (_isRunning) return;
    _navKey = navKey;
    _authProvider = authProvider;
    _isRunning = true;
    WidgetsBinding.instance.addObserver(this);
    _addKeyboardHandler();
    _resetTimer();
    debugPrint('⏱️  InactivityService started');
  }

  /// Call on logout (manual or auto).
  void stop() {
    if (!_isRunning) return;
    _isRunning = false;
    _cancelTimers();
    _warningShown = false;
    _pausedAt = null;
    WidgetsBinding.instance.removeObserver(this);
    _removeKeyboardHandler();
    _navKey = null;
    _authProvider = null;
    debugPrint('⏱️  InactivityService stopped');
  }

  /// Called on every qualifying pointer event from the Listener wrapper.
  void resetTimer() {
    if (!_isRunning) return;
    _resetTimer();
  }

  // ─────────────────────────────────────────────────────────────
  // Timer management
  // ─────────────────────────────────────────────────────────────

  void _resetTimer() {
    _cancelTimers();
    _warningShown = false;
    _warningTimer = Timer(_warningAt, _showWarningDialog);
    _logoutTimer = Timer(_logoutAt, _performLogout);
  }

  void _cancelTimers() {
    _warningTimer?.cancel();
    _logoutTimer?.cancel();
    _warningTimer = null;
    _logoutTimer = null;
  }

  // ─────────────────────────────────────────────────────────────
  // App lifecycle — WidgetsBindingObserver
  // ─────────────────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isRunning) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      // App went to background — pause the timers.
      _pausedAt = DateTime.now();
      _cancelTimers();
      debugPrint('⏱️  InactivityService: app paused, timers cancelled');
    } else if (state == AppLifecycleState.resumed) {
      final paused = _pausedAt;
      _pausedAt = null;

      if (paused != null) {
        final elapsed = DateTime.now().difference(paused);
        debugPrint('⏱️  InactivityService: resumed after ${elapsed.inSeconds}s');

        if (elapsed >= _logoutAt) {
          // Session has expired while in background — show expiry dialog
          // then auto-logout (Option A — confirmed by user).
          _showExpiredDialog();
        } else {
          // Still within session window — restart fresh.
          _resetTimer();
        }
      } else {
        _resetTimer();
      }
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Web keyboard handler
  // ─────────────────────────────────────────────────────────────

  /// Returns false so the event propagates normally.
  bool _onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      resetTimer();
    }
    return false;
  }

  void _addKeyboardHandler() {
    if (kIsWeb && !_keyboardHandlerAdded) {
      HardwareKeyboard.instance.addHandler(_onKeyEvent);
      _keyboardHandlerAdded = true;
    }
  }

  void _removeKeyboardHandler() {
    if (_keyboardHandlerAdded) {
      HardwareKeyboard.instance.removeHandler(_onKeyEvent);
      _keyboardHandlerAdded = false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Dialogs
  // ─────────────────────────────────────────────────────────────

  /// Shown at the 8-minute mark — 2-minute warning before auto-logout.
  void _showWarningDialog() {
    if (_warningShown) return;
    final context = _navKey?.currentContext;
    if (context == null) return;
    _warningShown = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SessionWarningDialog(
        onStayLoggedIn: () {
          // Dismiss and reset — counts this tap as activity.
          Navigator.of(context, rootNavigator: true).pop();
          _resetTimer();
        },
        onLogout: () {
          Navigator.of(context, rootNavigator: true).pop();
          _performLogout();
        },
      ),
    );
  }

  /// Shown when the app returns from background after ≥10 min (Option A).
  void _showExpiredDialog() {
    final context = _navKey?.currentContext;
    if (context == null) {
      // No context available — logout silently.
      _performLogout();
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SessionExpiredDialog(
        onOk: () {
          Navigator.of(context, rootNavigator: true).pop();
          _performLogout();
        },
      ),
    );
  }

  /// Shown on the login screen after a successful auto-logout navigation.
  void _showInactivityNotice(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const _InactivityNoticeDialog(),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Logout
  // ─────────────────────────────────────────────────────────────

  Future<void> _performLogout() async {
    _cancelTimers();
    _warningShown = false;

    // Capture local references before stop() clears them.
    final navKey = _navKey;
    final authProv = _authProvider;
    if (navKey == null || authProv == null) return;

    // Dismiss any open dialog/route above the first route.
    final navState = navKey.currentState;
    if (navState != null && navState.canPop()) {
      navState.popUntil((route) => route.isFirst);
    }

    // Delegate to the existing context-free logout (signOut + navigate).
    await authProv.logoutContextFree(navKey);

    // Give the navigator a frame to settle onto AdminSignIn.
    await Future.delayed(const Duration(milliseconds: 400));

    final ctx = navKey.currentContext;
    if (ctx != null && ctx.mounted) {
      _showInactivityNotice(ctx);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SessionWarningDialog
// Shown at 8 minutes — 2-minute warning. Matches the existing _forgotPassword
// AlertDialog style: AppColor.c252525 background, AppText, AppButton, TextButton.
// ─────────────────────────────────────────────────────────────────────────────
class _SessionWarningDialog extends StatefulWidget {
  const _SessionWarningDialog({
    required this.onStayLoggedIn,
    required this.onLogout,
  });

  final VoidCallback onStayLoggedIn;
  final VoidCallback onLogout;

  @override
  State<_SessionWarningDialog> createState() => _SessionWarningDialogState();
}

class _SessionWarningDialogState extends State<_SessionWarningDialog> {
  // Counts down the remaining 2 minutes visually.
  static const int _totalSeconds = 120;
  int _remaining = _totalSeconds;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_remaining > 0) _remaining--;
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String get _timeLabel {
    final m = _remaining ~/ 60;
    final s = _remaining % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColor.c252525,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppGradients.redGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.access_time_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          AppText(
            txt: 'Session Expiring Soon',
            fontSize: AppFontSize.f18,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            txt:
                "You've been inactive for a while. Your session will expire in:",
            fontSize: AppFontSize.f14,
            color: AppColor.c5B4B4B4,
            height: 1.5,
          ),
          const SizedBox(height: 20),
          // Countdown display
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppGradients.redGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _timeLabel,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: AppFontSize.f32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          AppText(
            txt: 'Tap "Stay Logged In" to continue your session.',
            fontSize: AppFontSize.f13,
            color: AppColor.c5B4B4B4,
            height: 1.4,
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Row(
            children: [
              TextButton(
                onPressed: widget.onLogout,
                child: AppText(
                  txt: 'Logout',
                  fontSize: AppFontSize.f14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.red,
                ),
              ),
              const Spacer(),
              AppButton(
                text: 'Stay Logged In',
                onPressed: widget.onStayLoggedIn,
                width: 150,
                buttonStyle: BoxDecoration(
                  gradient: AppGradients.redGradient,
                  borderRadius: BorderRadius.circular(50),
                ),
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SessionExpiredDialog
// Shown when the app returns from background after ≥10 min (Option A).
// ─────────────────────────────────────────────────────────────────────────────
class _SessionExpiredDialog extends StatelessWidget {
  const _SessionExpiredDialog({required this.onOk});

  final VoidCallback onOk;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColor.c252525,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppGradients.redGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.lock_clock_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          AppText(
            txt: 'Session Expired',
            fontSize: AppFontSize.f18,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
      content: AppText(
        txt:
            'Your session has expired due to inactivity. Please log in again to continue.',
        fontSize: AppFontSize.f14,
        color: AppColor.c5B4B4B4,
        height: 1.5,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: AppButton(
            text: 'OK',
            onPressed: onOk,
            buttonStyle: BoxDecoration(
              gradient: AppGradients.redGradient,
              borderRadius: BorderRadius.circular(50),
            ),
            textColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _InactivityNoticeDialog
// Shown on the login screen after auto-logout navigation completes.
// ─────────────────────────────────────────────────────────────────────────────
class _InactivityNoticeDialog extends StatelessWidget {
  const _InactivityNoticeDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColor.c252525,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppGradients.redGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          AppText(
            txt: 'Logged Out',
            fontSize: AppFontSize.f18,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
      content: AppText(
        txt: 'You have been logged out due to inactivity.',
        fontSize: AppFontSize.f14,
        color: AppColor.c5B4B4B4,
        height: 1.5,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: AppButton(
            text: 'OK',
            onPressed: () => Navigator.of(context).pop(),
            buttonStyle: BoxDecoration(
              gradient: AppGradients.redGradient,
              borderRadius: BorderRadius.circular(50),
            ),
            textColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
