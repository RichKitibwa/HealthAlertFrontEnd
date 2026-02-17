import 'package:flutter/material.dart';
import '../../features/auth/current_user_session.dart';

/// Intercepts the system back button (hardware/gesture) and handles it the same
/// way as the AppBar back button. Prevents the Activity from being finished
/// unexpectedly when the user expects in-app navigation.
///
/// Use this to wrap screens that have a back button in the top nav bar.
/// Both the AppBar back button and system back will behave identically:
/// - If the navigator can pop: pops the route
/// - Otherwise: navigates to the appropriate dashboard for the current role
class BackHandlingPopScope extends StatelessWidget {
  /// The widget to wrap (typically a Scaffold).
  final Widget child;

  /// Optional dashboard route when Navigator cannot pop.
  /// If null, uses role-based default from [CurrentUserSession].
  final String? dashboardRoute;

  const BackHandlingPopScope({
    super.key,
    required this.child,
    this.dashboardRoute,
  });

  String _getDashboardRoute() {
    if (dashboardRoute != null && dashboardRoute!.isNotEmpty) {
      return dashboardRoute!;
    }
    final role = CurrentUserSession.role?.toLowerCase() ?? '';
    if (role == 'admin') return '/admin-dashboard';
    if (role == 'vht') return '/vht-dashboard';
    if (role.contains('clinic')) return '/clinic-dashboard';
    if (role.contains('ambulance')) return '/ambulance-dashboard';
    return '/login';
  }

  void _handleBack(BuildContext context) {
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      // Defer navigation to next frame so we don't mutate the navigator
      // during the system back callback (prevents crash on some devices).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
          _getDashboardRoute(),
          (route) => false,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.mounted) {
          _handleBack(context);
        }
      },
      child: child,
    );
  }
}
