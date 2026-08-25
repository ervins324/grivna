import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../providers/subscription_providers.dart';

class UpcomingTimelineWidget extends ConsumerWidget {
  const UpcomingTimelineWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingAsync = ref.watch(upcomingPaymentsProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceElevated,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_active_outlined, size: 14, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'PAYMENT REMINDERS TIMELINE',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.schedule, size: 16, color: AppColors.textTertiary),
            ],
          ),
          const SizedBox(height: 16),

          upcomingAsync.when(
            data: (subs) {
              if (subs.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No upcoming payments', style: TextStyle(color: AppColors.textTertiary)),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: subs.length,
                itemBuilder: (context, index) {
                  final sub = subs[index];
                  final daysDiff = sub.nextBillingDate.difference(DateTime.now()).inDays;
                  final isImminent = daysDiff <= 3;
                  final curr = AppCurrency.fromCode(sub.currency);

                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timeline Line & Dot
                        Column(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: isImminent ? AppColors.negative : AppColors.textPrimary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            if (index < subs.length - 1)
                              Expanded(
                                child: Container(
                                  width: 1.5,
                                  color: AppColors.border,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 14),

                        // Info
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      sub.name,
                                      style: AppTypography.titleMedium.copyWith(fontSize: 14),
                                    ),
                                    Text(
                                      CurrencyFormatter.format(sub.amount, currency: curr),
                                      style: AppTypography.monoAmount.copyWith(fontSize: 13),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateTimeUtils.formatShortDate(sub.nextBillingDate),
                                      style: AppTypography.bodySmall,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isImminent
                                            ? AppColors.negativeMuted.withValues(alpha: 0.3)
                                            : AppColors.surfaceElevated,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        DateTimeUtils.formatDaysRemaining(sub.nextBillingDate),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: isImminent ? AppColors.negative : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary),
              ),
            ),
            error: (_, _) => const Text('Error loading timeline', style: TextStyle(color: AppColors.negative)),
          ),
        ],
      ),
    );
  }
}
