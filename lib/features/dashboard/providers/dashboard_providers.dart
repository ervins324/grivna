import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../accounts/providers/account_providers.dart';

class UnifiedBalanceState {
  final double totalBalance;
  final AppCurrency baseCurrency;
  final double usdRate;
  final int totalAccountsCount;

  UnifiedBalanceState({
    required this.totalBalance,
    required this.baseCurrency,
    required this.usdRate,
    required this.totalAccountsCount,
  });
}

final unifiedBalanceProvider = Provider<AsyncValue<UnifiedBalanceState>>((ref) {
  final accountsAsync = ref.watch(accountsStreamProvider);
  final rateAsync = ref.watch(exchangeRateStreamProvider);
  final baseCurrency = ref.watch(selectedBaseCurrencyProvider);

  if (accountsAsync.isLoading || rateAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (accountsAsync.hasError) {
    return AsyncValue.error(accountsAsync.error!, accountsAsync.stackTrace!);
  }

  final accounts = accountsAsync.value ?? [];
  final usdRate = rateAsync.value ?? 41.50;

  double total = 0.0;
  for (final acc in accounts) {
    final accCurr = AppCurrency.fromCode(acc.currency);
    final converted = CurrencyFormatter.convert(
      amount: acc.balance,
      from: accCurr,
      to: baseCurrency,
      uahToUsdRate: usdRate,
    );
    total += converted;
  }

  return AsyncValue.data(
    UnifiedBalanceState(
      totalBalance: total,
      baseCurrency: baseCurrency,
      usdRate: usdRate,
      totalAccountsCount: accounts.length,
    ),
  );
});

// Recent Transactions Stream Provider filtered by selected account filter
final recentTransactionsProvider = StreamProvider<List<TransactionsTableData>>((ref) {
  final repo = ref.watch(accountRepositoryProvider);
  final filterAccountId = ref.watch(selectedAccountFilterProvider);
  return repo.watchTransactions(accountId: filterAccountId, limit: 50);
});

// Monthly Income & Expense Overview
class MonthlyOverview {
  final double totalIncome;
  final double totalExpense;
  final double netSavings;
  final double savingsRate;

  MonthlyOverview({
    required this.totalIncome,
    required this.totalExpense,
    required this.netSavings,
    required this.savingsRate,
  });
}

final monthlyOverviewProvider = Provider<AsyncValue<MonthlyOverview>>((ref) {
  final transactionsAsync = ref.watch(recentTransactionsProvider);
  final rateAsync = ref.watch(exchangeRateStreamProvider);
  final baseCurrency = ref.watch(selectedBaseCurrencyProvider);

  if (transactionsAsync.isLoading || rateAsync.isLoading) {
    return const AsyncValue.loading();
  }

  final transactions = transactionsAsync.value ?? [];
  final usdRate = rateAsync.value ?? 41.50;
  final now = DateTime.now();
  final currentMonth = now.month;
  final currentYear = now.year;

  double income = 0.0;
  double expense = 0.0;

  for (final tx in transactions) {
    if (tx.timestamp.year == currentYear && tx.timestamp.month == currentMonth) {
      final txCurr = AppCurrency.fromCode(tx.currency);
      final converted = CurrencyFormatter.convert(
        amount: tx.amount,
        from: txCurr,
        to: baseCurrency,
        uahToUsdRate: usdRate,
      );

      if (tx.type == 'income') {
        income += converted;
      } else if (tx.type == 'expense') {
        expense += converted;
      }
    }
  }

  final net = income - expense;
  final rate = income > 0 ? (net / income) * 100 : 0.0;

  return AsyncValue.data(
    MonthlyOverview(
      totalIncome: income,
      totalExpense: expense,
      netSavings: net,
      savingsRate: rate.clamp(-100.0, 100.0),
    ),
  );
});
