import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../accounts/providers/account_providers.dart';
import '../../providers/analytics_providers.dart';

class DailySpendingBarChart extends ConsumerWidget {
  const DailySpendingBarChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyDataAsync = ref.watch(dailySpendingProvider);
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
              Text(
                'DAILY SPENDING (THIS MONTH)',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.3,
                  color: AppColors.textTertiary,
                ),
              ),
              const Icon(Icons.bar_chart, size: 16, color: AppColors.textTertiary),
            ],
          ),
          const SizedBox(height: 24),

          dailyDataAsync.when(
            data: (days) {
              if (days.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No daily data', style: TextStyle(color: AppColors.textTertiary)),
                  ),
                );
              }

              double maxY = 50.0;
              for (final d in days) {
                if (d.amount > maxY) maxY = d.amount;
              }
              maxY = maxY * 1.15;

              return SizedBox(
                height: 140,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceBetween,
                    maxY: maxY,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final dayNum = days[groupIndex].day;
                          return BarTooltipItem(
                            'Day $dayNum: ${CurrencyFormatter.format(rod.toY, currency: baseCurrency, showDecimals: false)}',
                            TextStyle(
                              color: AppColors.neonGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 5,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx >= 0 && idx < days.length) {
                              final day = days[idx].day;
                              if (day == 1 || day % 5 == 0) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '$day',
                                    style: const TextStyle(fontSize: 9, color: AppColors.textTertiary),
                                  ),
                                );
                              }
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(days.length, (i) {
                      final item = days[i];
                      final isZero = item.amount == 0;
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: isZero ? (maxY * 0.02) : item.amount,
                            color: isZero
                                ? AppColors.surfaceElevated
                                : (i % 2 == 0 ? AppColors.neonGreen : AppColors.textPrimary),
                            width: 5,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              );
            },
            loading: () => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.neonGreen),
              ),
            ),
            error: (e, _) => const Center(
              child: Text('Error loading chart', style: TextStyle(color: AppColors.negative)),
            ),
          ),
        ],
      ),
    );
  }
}
