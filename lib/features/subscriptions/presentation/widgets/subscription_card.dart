import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../accounts/providers/account_providers.dart';

class SubscriptionCard extends ConsumerWidget {
  final SubscriptionsTableData subscription;

  const SubscriptionCard({
    super.key,
    required this.subscription,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curr = AppCurrency.fromCode(subscription.currency);
    final daysRemaining = DateTimeUtils.formatDaysRemaining(subscription.nextBillingDate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Logo / Indicator
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: subscription.colorHex != null
                  ? Color(subscription.colorHex!).withValues(alpha: 0.15)
                  : AppColors.surfaceElevated,
              shape: BoxShape.circle,
              border: Border.all(
                color: subscription.colorHex != null
                    ? Color(subscription.colorHex!)
                    : AppColors.border,
              ),
            ),
            child: Center(
              child: Text(
                subscription.name.isNotEmpty ? subscription.name[0].toUpperCase() : 'S',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: subscription.colorHex != null
                      ? Color(subscription.colorHex!)
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        subscription.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleMedium.copyWith(fontSize: 15),
                      ),
                    ),
                    // Billing Cycle Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        subscription.billingCycle.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Renews $daysRemaining',
                      style: TextStyle(
                        fontSize: 12,
                        color: subscription.nextBillingDate.difference(DateTime.now()).inDays <= 3
                            ? AppColors.negative
                            : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(subscription.amount, currency: curr),
                      style: AppTypography.monoAmount.copyWith(fontSize: 15),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Active / Inactive Switch
          Switch(
            value: subscription.isActive,
            activeThumbColor: AppColors.textPrimary,
            activeTrackColor: AppColors.surfaceHighlight,
            inactiveThumbColor: AppColors.textTertiary,
            inactiveTrackColor: AppColors.surfaceElevated,
            onChanged: (val) {
              ref.read(accountRepositoryProvider).toggleSubscription(subscription.id, val);
            },
          ),
        ],
      ),
    );
  }
}
