import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../accounts/providers/account_providers.dart';

// Stream of Subscriptions
final subscriptionsListProvider = StreamProvider<List<SubscriptionsTableData>>((ref) {
  final repo = ref.watch(accountRepositoryProvider);
  return repo.watchSubscriptions();
});

// Selected Horizon in Days (preset: 30, 90, 180, 365, or custom number of days/months)
class ForecastHorizonDaysNotifier extends Notifier<int> {
  @override
  int build() => 90; // default 3 months (90 days)

  void setMonths(int months) => state = months * 30;
  void setDays(int days) => state = days > 0 ? days : 30;
}

final forecastHorizonDaysProvider =
    NotifierProvider<ForecastHorizonDaysNotifier, int>(
  ForecastHorizonDaysNotifier.new,
);

// Backward compatibility alias
final forecastHorizonMonthsProvider = Provider<int>((ref) {
  final days = ref.watch(forecastHorizonDaysProvider);
  return (days / 30).round();
});

class SubscriptionForecastItem {
  final SubscriptionsTableData subscription;
  final int occurrences;
  final double singleCostBase;
  final double totalCostBase;

  SubscriptionForecastItem({
    required this.subscription,
    required this.occurrences,
    required this.singleCostBase,
    required this.totalCostBase,
  });
}

class FutureCostProjection {
  final int days;
  final double monthsEquivalent;
  final double totalProjectedCost;
  final List<SubscriptionForecastItem> items;

  FutureCostProjection({
    required this.days,
    required this.monthsEquivalent,
    required this.totalProjectedCost,
    required this.items,
  });
}

// Future Cost Projection Calculator Provider
final futureCostProjectionProvider = Provider<AsyncValue<FutureCostProjection>>((ref) {
  final subsAsync = ref.watch(subscriptionsListProvider);
  final rateAsync = ref.watch(exchangeRateStreamProvider);
  final baseCurrency = ref.watch(selectedBaseCurrencyProvider);
  final horizonDays = ref.watch(forecastHorizonDaysProvider);

  if (subsAsync.isLoading || rateAsync.isLoading) {
    return const AsyncValue.loading();
  }

  final subs = subsAsync.value ?? [];
  final usdRate = rateAsync.value ?? 41.50;

  double totalProjected = 0.0;
  final items = <SubscriptionForecastItem>[];

  final monthsEquivalent = horizonDays / 30.0;

  for (final sub in subs) {
    if (!sub.isActive) continue;

    final subCurr = AppCurrency.fromCode(sub.currency);
    final singleCostBase = CurrencyFormatter.convert(
      amount: sub.amount,
      from: subCurr,
      to: baseCurrency,
      uahToUsdRate: usdRate,
    );

    int occurrences = 0;
    if (sub.billingCycle == 'monthly') {
      occurrences = (horizonDays / 30.0).ceil();
    } else if (sub.billingCycle == 'yearly') {
      occurrences = (horizonDays / 365.0).ceil();
    } else if (sub.billingCycle == 'weekly') {
      occurrences = (horizonDays / 7.0).floor();
    } else {
      final cycle = sub.cycleDays > 0 ? sub.cycleDays : 30;
      occurrences = (horizonDays / cycle).floor();
    }
    if (occurrences < 1 && horizonDays > 0) occurrences = 1;

    final totalSubCost = singleCostBase * occurrences;
    totalProjected += totalSubCost;

    items.add(
      SubscriptionForecastItem(
        subscription: sub,
        occurrences: occurrences,
        singleCostBase: singleCostBase,
        totalCostBase: totalSubCost,
      ),
    );
  }

  // Sort items by highest projected cost
  items.sort((a, b) => b.totalCostBase.compareTo(a.totalCostBase));

  return AsyncValue.data(
    FutureCostProjection(
      days: horizonDays,
      monthsEquivalent: monthsEquivalent,
      totalProjectedCost: totalProjected,
      items: items,
    ),
  );
});

// Upcoming Payments sorted by closest due date
final upcomingPaymentsProvider = Provider<AsyncValue<List<SubscriptionsTableData>>>((ref) {
  final subsAsync = ref.watch(subscriptionsListProvider);

  return subsAsync.whenData((subs) {
    final active = subs.where((s) => s.isActive).toList();
    active.sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
    return active;
  });
});
