import 'package:app/service/connectivity_service.dart';
import 'package:app/ui/helpers/color_helper.dart';
import 'package:app/ui/helpers/font_size_helper.dart';
import 'package:app/ui/utils/app_text.dart';
import 'package:flutter/material.dart';

/// Wraps the entire app and shows a full-screen "No Internet" overlay
/// when the connection drops, preserving the underlying screen state.
class NoInternetOverlay extends StatelessWidget {
  final Widget child;

  const NoInternetOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ConnectivityService().isConnected,
      builder: (context, isConnected, _) {
        return Stack(
          children: [
            // Always render the child (the actual app), but block interaction if offline
            IgnorePointer(
              ignoring: !isConnected,
              child: child,
            ),

            // If disconnected, render the blocking overlay on top
            if (!isConnected)
              Positioned.fill(
                child: Container(
                  color: AppColor.c151515.withValues(alpha: 0.95), // dark overlay
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColor.c252525,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.wifi_off_rounded,
                            size: 64,
                            color: AppColor.red,
                          ),
                        ),
                        const SizedBox(height: 32),
                        AppText(
                          txt: 'No Internet Connection',
                          fontSize: AppFontSize.f24,
                          fontWeight: FontWeight.bold,
                          color: AppColor.cFFFFFF,
                        ),
                        const SizedBox(height: 16),
                        AppText(
                          txt: 'Please check your connection and try again.',
                          fontSize: AppFontSize.f16,
                          color: AppColor.cFFFFFF.withValues(alpha: 0.7),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Manually re-trigger the check
                            ConnectivityService().recheckNow();
                          },
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: const Text(
                            'Retry',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.red,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
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
}
