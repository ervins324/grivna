import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../accounts/providers/account_providers.dart';
import '../../providers/analytics_providers.dart';

class IncomeExpenseBarChart extends ConsumerWidget {
  const IncomeExpenseBarChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendAsync = ref.watch(sixMonthTrendProvider);
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
                'INCOME VS EXPENSE',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.3,
                  color: AppColors.textTertiary,
                ),
              ),
              Row(
                children: [
                  _buildLegend(AppColors.neonGreen, 'Income'),
                  const SizedBox(width: 12),
                  _buildLegend(AppColors.negative, 'Expense'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          trendAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No data', style: TextStyle(color: AppColors.textTertiary)),
                  ),
                );
              }

              double maxY = 100.0;
              for (final item in items) {
                if (item.income > maxY) maxY = item.income;
                if (item.expense > maxY) maxY = item.expense;
              }
              maxY = maxY * 1.15;

              return SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final isIncome = rodIndex == 0;
                          return BarTooltipItem(
                            '${isIncome ? 'In' : 'Out'}: ${CurrencyFormatter.format(rod.toY, currency: baseCurrency, showDecimals: false)}',
                            TextStyle(
                              color: isIncome ? AppColors.neonGreen : AppColors.negative,
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
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 38,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const SizedBox.shrink();
                            return Text(
                              CurrencyFormatter.format(value, currency: baseCurrency, showDecimals: false)
                                  .replaceAll(' ', ''),
                              style: const TextStyle(fontSize: 8, color: AppColors.textTertiary),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx >= 0 && idx < items.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  items[idx].monthLabel,
                                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    gridData: const FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: _getGridLine,
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(items.length, (i) {
                      final item = items[i];
                      return BarChartGroupData(
                        x: i,
                        barsSpace: 4,
                        barRods: [
                          BarChartRodData(
                            toY: item.income,
                            color: AppColors.neonGreen,
                            width: 10,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                          BarChartRodData(
                            toY: item.expense,
                            color: AppColors.negative,
                            width: 10,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
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

  static FlLine _getGridLine(double value) => const FlLine(
        color: AppColors.borderSubtle,
        strokeWidth: 1,
      );

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: color == AppColors.neonGreen ? AppColors.neonGlow(blur: 6, color: color) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}
