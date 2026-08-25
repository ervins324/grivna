import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../accounts/providers/account_providers.dart';

// Stream of Subscriptions
final subscriptionsListProvider = StreamProvider<List<SubscriptionsTableData>>((ref) {
  final repo = ref.watch(accountRepositoryProvider);
  return repo.watchSubscriptions();
});

// Selected Horizon in Months (1, 3, 6, 12)
class ForecastHorizonMonthsNotifier extends Notifier<int> {
  @override
  int build() => 3;

  void setMonths(int months) => state = months;
}

final forecastHorizonMonthsProvider =
    NotifierProvider<ForecastHorizonMonthsNotifier, int>(
  ForecastHorizonMonthsNotifier.new,
);

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
  final int months;
  final double totalProjectedCost;
  final List<SubscriptionForecastItem> items;

  FutureCostProjection({
    required this.months,
    required this.totalProjectedCost,
    required this.items,
  });
}

// Future Cost Projection Calculator Provider
final futureCostProjectionProvider = Provider<AsyncValue<FutureCostProjection>>((ref) {
  final subsAsync = ref.watch(subscriptionsListProvider);
  final rateAsync = ref.watch(exchangeRateStreamProvider);
  final baseCurrency = ref.watch(selectedBaseCurrencyProvider);
  final horizonMonths = ref.watch(forecastHorizonMonthsProvider);

  if (subsAsync.isLoading || rateAsync.isLoading) {
    return const AsyncValue.loading();
  }

  final subs = subsAsync.value ?? [];
  final usdRate = rateAsync.value ?? 41.50;

  double totalProjected = 0.0;
  final items = <SubscriptionForecastItem>[];

  final daysInHorizon = horizonMonths * 30;

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
      occurrences = horizonMonths;
    } else if (sub.billingCycle == 'yearly') {
      occurrences = (horizonMonths / 12).ceil();
    } else if (sub.billingCycle == 'weekly') {
      occurrences = (daysInHorizon / 7).floor();
    } else {
      // Custom cycle days
      final cycle = sub.cycleDays > 0 ? sub.cycleDays : 30;
      occurrences = (daysInHorizon / cycle).floor();
    }

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
      months: horizonMonths,
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
