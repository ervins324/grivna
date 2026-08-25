import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../accounts/providers/account_providers.dart';
import '../../providers/analytics_providers.dart';

class CategoryDonutChart extends ConsumerStatefulWidget {
  const CategoryDonutChart({super.key});

  @override
  ConsumerState<CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends ConsumerState<CategoryDonutChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final categoryDataAsync = ref.watch(categoryBreakdownProvider);
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
                'CATEGORY BREAKDOWN',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppColors.textTertiary,
                ),
              ),
              const Icon(Icons.pie_chart_outline, size: 16, color: AppColors.textTertiary),
            ],
          ),
          const SizedBox(height: 20),

          categoryDataAsync.when(
            data: (categories) {
              if (categories.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 36),
                  child: Center(
                    child: Text('No expense data for this period', style: TextStyle(color: AppColors.textTertiary)),
                  ),
                );
              }

              final totalExpense = categories.fold<double>(0.0, (sum, item) => sum + item.amount);

              return Column(
                children: [
                  // Donut Chart
                  SizedBox(
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    _touchedIndex = -1;
                                    return;
                                  }
                                  _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 3,
                            centerSpaceRadius: 52,
                            sections: List.generate(categories.length, (i) {
                              final isTouched = i == _touchedIndex;
                              final item = categories[i];
                              final radius = isTouched ? 34.0 : 28.0;

                              return PieChartSectionData(
                                color: item.color,
                                value: item.amount,
                                title: isTouched ? '${item.percentage.toStringAsFixed(0)}%' : '',
                                radius: radius,
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            }),
                          ),
                        ),
                        // Center Info
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _touchedIndex >= 0 && _touchedIndex < categories.length
                                  ? categories[_touchedIndex].category
                                  : 'Total',
                              style: AppTypography.bodySmall.copyWith(fontSize: 11),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(
                                _touchedIndex >= 0 && _touchedIndex < categories.length
                                    ? categories[_touchedIndex].amount
                                    : totalExpense,
                                currency: baseCurrency,
                                showDecimals: false,
                              ),
                              style: AppTypography.titleMedium.copyWith(fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Ranked Categories List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categories.length,
                    separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 16),
                    itemBuilder: (context, i) {
                      final item = categories[i];
                      final isSelected = _touchedIndex == i;

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.surfaceElevated : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: item.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.category,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ),
                            Text(
                              '${item.percentage.toStringAsFixed(1)}%',
                              style: AppTypography.monoSmall.copyWith(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              CurrencyFormatter.format(
                                item.amount,
                                currency: baseCurrency,
                                showDecimals: false,
                              ),
                              style: AppTypography.monoAmount.copyWith(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary),
              ),
            ),
            error: (e, _) => Center(
              child: Text('Error loading chart', style: TextStyle(color: AppColors.negative)),
            ),
          ),
        ],
      ),
    );
  }
}
