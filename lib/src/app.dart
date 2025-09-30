import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:locker_app/src/core/services/safe_service.dart';
import 'package:locker_app/src/features/lockscreen/lock_screen.dart';
import 'package:locker_app/src/features/safe_home/safe_home_screen.dart';

class ServicesApp extends StatefulWidget {
  const ServicesApp({super.key});

  @override
  State<ServicesApp> createState() => _ServicesAppState();
}

class _ServicesAppState extends State<ServicesApp> with WidgetsBindingObserver {
  final ValueNotifier<bool> _isLocked = ValueNotifier<bool>(true);
  StreamSubscription? _shareStreamSub;
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();
  final SafeService _safeService = SafeService();

  void _openSafe(int safeId) {
    _navKey.currentState!.pushReplacement(
      MaterialPageRoute(
        builder: (_) => SafeHomeScreen(
          safeId: safeId,
          onLock: _goToLockScreen,
          safeService: _safeService,
        ),
      ),
    );
  }

  void _goToLockScreen() {
    _isLocked.value = true;
    _navKey.currentState!.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => LockScreen(
          onUnlocked: (id) {
            _isLocked.value = false;
            _openSafe(id);
          },
        ),
      ),
      (r) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _safeService.listenForShares();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _shareStreamSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _isLocked.value = true; // Auto-lock on background
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navKey,
      title: 'Services',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: ValueListenableBuilder<bool>(
        valueListenable: _isLocked,
        builder: (context, locked, _) {
          if (locked) {
            return LockScreen(
              onUnlocked: (int safeId) {
                _isLocked.value = false;
                _openSafe(safeId);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
