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
                    decoration: BoxDecoration(
                      color: AppColors.neonGreenSubtle,
                      shape: BoxShape.circle,
                      boxShadow: AppColors.neonGlow(blur: 8, color: AppColors.neonGreenGlow),
                    ),
                    child: const Icon(Icons.auto_graph, size: 14, color: AppColors.neonGreen),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'FUTURE COST PROJECTION',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.3,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.neonGreenSubtle,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.neonBorder.withValues(alpha: 0.3)),
                ),
                child: const Text(
                  'Simulation',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.neonGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Horizon Chips Selector (1m, 3m, 6m, 12m, Custom)
          Row(
            children: [
              ...[1, 3, 6, 12].map((months) {
                final isSelected = horizonMonths == months && (ref.watch(forecastHorizonDaysProvider) == months * 30 || (months == 12 && ref.watch(forecastHorizonDaysProvider) == 365));
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: InkWell(
                      onTap: () => ref.read(forecastHorizonDaysProvider.notifier).setMonths(months),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.textPrimary : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.neonBorder.withValues(alpha: 0.6) : AppColors.border,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    blurRadius: 10,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '${months}m',
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
              }),
              // Custom Period Chip
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: InkWell(
                    onTap: () => _showCustomPeriodDialog(context, ref),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: ![30, 90, 180, 360, 365].contains(ref.watch(forecastHorizonDaysProvider))
                            ? AppColors.neonGreen
                            : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ![30, 90, 180, 360, 365].contains(ref.watch(forecastHorizonDaysProvider))
                              ? AppColors.neonGreen
                              : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          ![30, 90, 180, 360, 365].contains(ref.watch(forecastHorizonDaysProvider))
                              ? '${ref.watch(forecastHorizonDaysProvider)}d'
                              : 'Custom',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: ![30, 90, 180, 360, 365].contains(ref.watch(forecastHorizonDaysProvider))
                                ? Colors.black
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Total Projection Banner
          projectionAsync.when(
            data: (proj) {
              final label = proj.days >= 30 && proj.days % 30 == 0
                  ? '${(proj.days / 30).round()} months'
                  : '${proj.days} days';

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
                              'Total Projected Spend ($label)',
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
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.neonGreen),
              ),
            ),
            error: (_, _) => const Text('Error calculating projection', style: TextStyle(color: AppColors.negative)),
          ),
        ],
      ),
    );
  }

  void _showCustomPeriodDialog(BuildContext context, WidgetRef ref) {
    final currentDays = ref.read(forecastHorizonDaysProvider);
    final controller = TextEditingController(text: currentDays.toString());
    bool isMonths = currentDays >= 30 && currentDays % 30 == 0;
    if (isMonths) {
      controller.text = (currentDays ~/ 30).toString();
    }

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.neonGreenSubtle,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.tune, color: AppColors.neonGreen, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text('Custom Forecast Period', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Enter duration to calculate total recurring subscription costs:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: isMonths ? 'Number of Months' : 'Number of Days',
                            filled: true,
                            fillColor: AppColors.surfaceElevated,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => setState(() => isMonths = true),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                                decoration: BoxDecoration(
                                  color: isMonths ? AppColors.textPrimary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text('Mo', style: TextStyle(fontWeight: FontWeight.bold, color: isMonths ? AppColors.background : AppColors.textSecondary)),
                              ),
                            ),
                            InkWell(
                              onTap: () => setState(() => isMonths = false),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                                decoration: BoxDecoration(
                                  color: !isMonths ? AppColors.textPrimary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text('Days', style: TextStyle(fontWeight: FontWeight.bold, color: !isMonths ? AppColors.background : AppColors.textSecondary)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final val = int.tryParse(controller.text.trim()) ?? 1;
                    if (isMonths) {
                      ref.read(forecastHorizonDaysProvider.notifier).setMonths(val);
                    } else {
                      ref.read(forecastHorizonDaysProvider.notifier).setDays(val);
                    }
                    Navigator.pop(dialogCtx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Apply Projection'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
