import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../accounts/providers/account_providers.dart';
import '../../providers/subscription_providers.dart';

class FutureCostCalculator extends ConsumerWidget {
  const FutureCostCalculator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectionAsync = ref.watch(futureCostProjectionProvider);
    final horizonMonths = ref.watch(forecastHorizonMonthsProvider);
    final baseCurrency = ref.watch(selectedBaseCurrencyProvider);

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
                    child: const Icon(Icons.auto_graph, size: 14, color: AppColors.transfer),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'FUTURE COST PROJECTION',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Simulation',
                  style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Horizon Chips Selector (1m, 3m, 6m, 12m)
          Row(
            children: [1, 3, 6, 12].map((months) {
              final isSelected = horizonMonths == months;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    onTap: () => ref.read(forecastHorizonMonthsProvider.notifier).setMonths(months),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.textPrimary : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Text(
                          '$months ${months == 1 ? 'Month' : 'Months'}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.background : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Total Projection Banner
          projectionAsync.when(
            data: (proj) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Projected Spend ($horizonMonths mo)',
                              style: AppTypography.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.format(
                                proj.totalProjectedCost,
                                currency: baseCurrency,
                                showDecimals: true,
                              ),
                              style: AppTypography.monoAmount.copyWith(fontSize: 22),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.negative.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.trending_up, color: AppColors.negative, size: 20),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Note: Projections calculate expected recurring charges without deducting from your live balances.',
                    style: TextStyle(fontSize: 11, color: AppColors.textTertiary, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 16),

                  // Subscriptions Projected Breakdown
                  if (proj.items.isNotEmpty) ...[
                    Text(
                      'SUBSCRIPTION BREAKDOWN',
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: proj.items.length,
                      separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 12),
                      itemBuilder: (context, i) {
                        final item = proj.items[i];
                        return Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.subscription.name,
                                    style: AppTypography.titleMedium.copyWith(fontSize: 13),
                                  ),
                                  Text(
                                    '${item.occurrences} billing ${item.occurrences == 1 ? 'cycle' : 'cycles'} × ${CurrencyFormatter.format(item.singleCostBase, currency: baseCurrency, showDecimals: false)}',
                                    style: AppTypography.bodySmall.copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(
                                item.totalCostBase,
                                currency: baseCurrency,
                                showDecimals: false,
                              ),
                              style: AppTypography.monoAmount.copyWith(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary),
              ),
            ),
            error: (_, _) => const Text('Error calculating projection', style: TextStyle(color: AppColors.negative)),
          ),
        ],
      ),
    );
  }
}
