import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../features/analytics/presentation/analytics_screen.dart';
import '../features/auth_guard/presentation/app_lock_screen.dart';
import '../features/auth_guard/providers/auth_state_provider.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/subscriptions/presentation/subscriptions_screen.dart';

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    AnalyticsScreen(),
    SubscriptionsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authGuardProvider);

    // If app is locked by PIN / Biometrics screen guard
    if (authState.isLocked) {
      return const AppLockScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.borderSubtle, width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.grid_view_outlined, Icons.grid_view_rounded, 'Dashboard'),
                _buildNavItem(1, Icons.pie_chart_outline, Icons.pie_chart, 'Analytics'),
                _buildNavItem(2, Icons.autorenew_outlined, Icons.autorenew, 'Forecast'),
                _buildNavItem(3, Icons.tune_outlined, Icons.tune, 'Settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData filledIcon, String label) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceElevated : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? filledIcon : outlineIcon,
              size: 20,
              color: isSelected ? AppColors.textPrimary : AppColors.textTertiary,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
