import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Singleton service that monitors real internet connectivity.
class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService _instance = ConnectivityService._();
  factory ConnectivityService() => _instance;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Starts as true so we don't flash a "No Internet" screen on startup
  /// before the first check completes.
  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(true);

  Future<void> initialize() async {
    // Perform an initial check
    await recheckNow();

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      // connectivity_plus 6.x returns a List<ConnectivityResult>
      if (results.contains(ConnectivityResult.none)) {
        isConnected.value = false;
      } else {
        // We have a network link, but need to verify actual internet access.
        recheckNow();
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
    isConnected.dispose();
  }

  /// Manually force a re-check of the actual internet connection.
  Future<void> recheckNow() async {
    final bool hasInternet = await _checkRealInternet();
    isConnected.value = hasInternet;
  }

  /// Performs an actual socket/HTTP request to confirm internet access,
  /// because ConnectivityResult only tells us if we're connected to a router/cell tower.
  Future<bool> _checkRealInternet() async {
    if (kIsWeb) {
      try {
        // On Web, use http.get to check against Firebase CDN.
        // This is the same URL Firebase tries to hit on startup.
        final response = await http.get(
          Uri.parse('https://www.gstatic.com/firebasejs/12.14.0/firebase-app.js'),
        ).timeout(const Duration(seconds: 2));
        
        return response.statusCode == 200;
      } catch (_) {
        return false;
      }
    } else {
      try {
        // On Android/iOS, doing a DNS lookup is fast and reliable.
        final result = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 2));
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } catch (_) {
        return false;
      }
    }
  }
}
