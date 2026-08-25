import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../accounts/providers/account_providers.dart';

class CategoryExpenseItem {
  final String category;
  final double amount;
  final double percentage;
  final Color color;

  CategoryExpenseItem({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}

class MonthTrendItem {
  final String monthLabel;
  final int monthIndex;
  final int year;
  final double income;
  final double expense;
  final double net;

  MonthTrendItem({
    required this.monthLabel,
    required this.monthIndex,
    required this.year,
    required this.income,
    required this.expense,
    required this.net,
  });
}

class DailySpendingItem {
  final int day;
  final double amount;

  DailySpendingItem({required this.day, required this.amount});
}

enum AnalyticsTimeframe {
  thisMonth('This Month'),
  threeMonths('3 Months'),
  sixMonths('6 Months'),
  allTime('All Time');

  final String label;
  const AnalyticsTimeframe(this.label);
}

class AnalyticsTimeframeNotifier extends Notifier<AnalyticsTimeframe> {
  @override
  AnalyticsTimeframe build() => AnalyticsTimeframe.thisMonth;

  void setTimeframe(AnalyticsTimeframe tf) => state = tf;
}

final analyticsTimeframeProvider =
    NotifierProvider<AnalyticsTimeframeNotifier, AnalyticsTimeframe>(
  AnalyticsTimeframeNotifier.new,
);

// Category Breakdown Provider
final categoryBreakdownProvider = FutureProvider<List<CategoryExpenseItem>>((ref) async {
  final repo = ref.watch(accountRepositoryProvider);
  final filterAccountId = ref.watch(selectedAccountFilterProvider);
  final baseCurrency = ref.watch(selectedBaseCurrencyProvider);
  final rate = await ref.watch(exchangeRateServiceProvider).getCachedUsdRate();
  final timeframe = ref.watch(analyticsTimeframeProvider);

  final transactions = await repo.getAllTransactions(accountId: filterAccountId);
  final now = DateTime.now();

  DateTime cutoffDate = DateTime(now.year, now.month, 1);
  switch (timeframe) {
    case AnalyticsTimeframe.thisMonth:
      cutoffDate = DateTime(now.year, now.month, 1);
      break;
    case AnalyticsTimeframe.threeMonths:
      cutoffDate = DateTime(now.year, now.month - 2, 1);
      break;
    case AnalyticsTimeframe.sixMonths:
      cutoffDate = DateTime(now.year, now.month - 5, 1);
      break;
    case AnalyticsTimeframe.allTime:
      cutoffDate = DateTime(2000, 1, 1);
      break;
  }

  final categoryTotals = <String, double>{};
  double grandTotal = 0.0;

  for (final tx in transactions) {
    if (tx.type == 'expense' && tx.timestamp.isAfter(cutoffDate)) {
      final txCurr = AppCurrency.fromCode(tx.currency);
      final converted = CurrencyFormatter.convert(
        amount: tx.amount,
        from: txCurr,
        to: baseCurrency,
        uahToUsdRate: rate,
      );

      categoryTotals[tx.category] = (categoryTotals[tx.category] ?? 0.0) + converted;
      grandTotal += converted;
    }
  }

  if (grandTotal == 0.0) return [];

  final sortedEntries = categoryTotals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final results = <CategoryExpenseItem>[];
  for (int i = 0; i < sortedEntries.length; i++) {
    final entry = sortedEntries[i];
    final color = AppColors.chartColors[i % AppColors.chartColors.length];
    final pct = (entry.value / grandTotal) * 100;
    results.add(
      CategoryExpenseItem(
        category: entry.key,
        amount: entry.value,
        percentage: pct,
        color: color,
      ),
    );
  }

  return results;
});

// 6-Month Trend Provider
final sixMonthTrendProvider = FutureProvider<List<MonthTrendItem>>((ref) async {
  final repo = ref.watch(accountRepositoryProvider);
  final filterAccountId = ref.watch(selectedAccountFilterProvider);
  final baseCurrency = ref.watch(selectedBaseCurrencyProvider);
  final rate = await ref.watch(exchangeRateServiceProvider).getCachedUsdRate();

  final transactions = await repo.getAllTransactions(accountId: filterAccountId);
  final now = DateTime.now();

  const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final List<MonthTrendItem> list = [];

  for (int i = 5; i >= 0; i--) {
    final targetMonthDate = DateTime(now.year, now.month - i, 1);
    final month = targetMonthDate.month;
    final year = targetMonthDate.year;
    final monthLabel = monthNames[month - 1];

    double inc = 0.0;
    double exp = 0.0;

    for (final tx in transactions) {
      if (tx.timestamp.year == year && tx.timestamp.month == month) {
        final txCurr = AppCurrency.fromCode(tx.currency);
        final converted = CurrencyFormatter.convert(
          amount: tx.amount,
          from: txCurr,
          to: baseCurrency,
          uahToUsdRate: rate,
        );

        if (tx.type == 'income') {
          inc += converted;
        } else if (tx.type == 'expense') {
          exp += converted;
        }
      }
    }

    list.add(
      MonthTrendItem(
        monthLabel: monthLabel,
        monthIndex: month,
        year: year,
        income: inc,
        expense: exp,
        net: inc - exp,
      ),
    );
  }

  return list;
});

// Daily Spending Provider for Current Month
final dailySpendingProvider = FutureProvider<List<DailySpendingItem>>((ref) async {
  final repo = ref.watch(accountRepositoryProvider);
  final filterAccountId = ref.watch(selectedAccountFilterProvider);
  final baseCurrency = ref.watch(selectedBaseCurrencyProvider);
  final rate = await ref.watch(exchangeRateServiceProvider).getCachedUsdRate();

  final transactions = await repo.getAllTransactions(accountId: filterAccountId);
  final now = DateTime.now();
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

  final Map<int, double> dayTotals = {};
  for (int d = 1; d <= daysInMonth; d++) {
    dayTotals[d] = 0.0;
  }

  for (final tx in transactions) {
    if (tx.type == 'expense' &&
        tx.timestamp.year == now.year &&
        tx.timestamp.month == now.month) {
      final txCurr = AppCurrency.fromCode(tx.currency);
      final converted = CurrencyFormatter.convert(
        amount: tx.amount,
        from: txCurr,
        to: baseCurrency,
        uahToUsdRate: rate,
      );

      final day = tx.timestamp.day;
      dayTotals[day] = (dayTotals[day] ?? 0.0) + converted;
    }
  }

  return dayTotals.entries
      .map((e) => DailySpendingItem(day: e.key, amount: e.value))
      .toList();
});
