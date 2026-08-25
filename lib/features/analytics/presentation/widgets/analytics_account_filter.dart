import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../accounts/providers/account_providers.dart';
import '../../providers/analytics_providers.dart';

class AnalyticsAccountFilter extends ConsumerWidget {
  const AnalyticsAccountFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsStreamProvider).value ?? [];
    final selectedFilter = ref.watch(selectedAccountFilterProvider);
    final timeframe = ref.watch(analyticsTimeframeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeframe selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: AnalyticsTimeframe.values.map((tf) {
              final isSelected = timeframe == tf;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => ref.read(analyticsTimeframeProvider.notifier).setTimeframe(tf),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.textPrimary : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      tf.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.background : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),

        // Accounts Filter Pill list
        SizedBox(
          height: 32,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildFilterChip(
                label: 'All Accounts',
                isSelected: selectedFilter == null,
                onTap: () => ref.read(selectedAccountFilterProvider.notifier).setFilter(null),
              ),
              ...accounts.map((acc) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _buildFilterChip(
                    label: acc.name,
                    isSelected: selectedFilter == acc.id,
                    onTap: () => ref.read(selectedAccountFilterProvider.notifier).setFilter(acc.id),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceElevated : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.textPrimary : AppColors.borderSubtle,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.textPrimary : AppColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}
