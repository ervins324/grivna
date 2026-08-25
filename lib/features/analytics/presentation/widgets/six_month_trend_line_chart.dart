import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../accounts/providers/account_providers.dart';
import '../../providers/analytics_providers.dart';

class SixMonthTrendLineChart extends ConsumerWidget {
  const SixMonthTrendLineChart({super.key});

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
                '6-MONTH SPENDING TREND',
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
                    child: Text('No historical data', style: TextStyle(color: AppColors.textTertiary)),
                  ),
                );
              }

              // Compute max Y for chart bounds
              double maxY = 100.0;
              for (final item in items) {
                if (item.income > maxY) maxY = item.income;
                if (item.expense > maxY) maxY = item.expense;
              }
              maxY = maxY * 1.15; // 15% top padding

              final incomeSpots = List.generate(items.length, (i) {
                return FlSpot(i.toDouble(), items[i].income);
              });

              final expenseSpots = List.generate(items.length, (i) {
                return FlSpot(i.toDouble(), items[i].expense);
              });

              return SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxY / 4,
                      getDrawingHorizontalLine: (value) => const FlLine(
                        color: AppColors.borderSubtle,
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 42,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const SizedBox.shrink();
                            return Text(
                              CurrencyFormatter.format(value, currency: baseCurrency, showDecimals: false)
                                  .replaceAll(' ', ''),
                              style: const TextStyle(fontSize: 9, color: AppColors.textTertiary),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 26,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx >= 0 && idx < items.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  items[idx].monthLabel,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: (items.length - 1).toDouble(),
                    minY: 0,
                    maxY: maxY,
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final isIncome = spot.barIndex == 0;
                            return LineTooltipItem(
                              '${isIncome ? 'Income' : 'Expense'}: ${CurrencyFormatter.format(spot.y, currency: baseCurrency, showDecimals: false)}',
                              TextStyle(
                                color: isIncome ? AppColors.neonGreen : AppColors.negative,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    lineBarsData: [
                      // Income Line (Soft neon green with diffuse glowing fill)
                      LineChartBarData(
                        spots: incomeSpots,
                        isCurved: true,
                        curveSmoothness: 0.35,
                        color: AppColors.neonGreen,
                        barWidth: 2.8,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.neonGreen.withValues(alpha: 0.22),
                              AppColors.neonGreen.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                      // Expense Line
                      LineChartBarData(
                        spots: expenseSpots,
                        isCurved: true,
                        curveSmoothness: 0.35,
                        color: AppColors.negative,
                        barWidth: 2.2,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.negative.withValues(alpha: 0.15),
                              AppColors.negative.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.neonGreen),
              ),
            ),
            error: (e, _) => const Center(
              child: Text('Error loading trend', style: TextStyle(color: AppColors.negative)),
            ),
          ),
        ],
      ),
    );
  }

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
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}
