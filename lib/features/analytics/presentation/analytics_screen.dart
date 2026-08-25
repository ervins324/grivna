import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import 'widgets/analytics_account_filter.dart';
import 'widgets/category_donut_chart.dart';
import 'widgets/daily_spending_bar_chart.dart';
import 'widgets/income_expense_bar_chart.dart';
import 'widgets/six_month_trend_line_chart.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: Text('Analytics & Trends', style: AppTypography.titleLarge),
      ),
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            // Global Account & Timeframe Filters
            AnalyticsAccountFilter(),

            SizedBox(height: 20),

            // Category Donut Chart
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: CategoryDonutChart(),
            ),

            SizedBox(height: 20),

            // 6-Month Spending Trend Line Chart
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SixMonthTrendLineChart(),
            ),

            SizedBox(height: 20),

            // Income vs Expense Bar Chart
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: IncomeExpenseBarChart(),
            ),

            SizedBox(height: 20),

            // Daily Spending Bar Chart
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: DailySpendingBarChart(),
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
