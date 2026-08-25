import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/security/biometrics_service.dart';
import '../../../core/security/secure_storage_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../data/account_repository.dart';
import '../data/bybit_service.dart';
import '../data/exchange_rate_service.dart';
import '../data/monobank_service.dart';

// Core Database Provider
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// Services Providers
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final biometricsServiceProvider = Provider<BiometricsService>((ref) {
  return BiometricsService();
});

final monobankServiceProvider = Provider<MonobankService>((ref) {
  return MonobankService();
});

final bybitServiceProvider = Provider<BybitService>((ref) {
  return BybitService();
});

final exchangeRateServiceProvider = Provider<ExchangeRateService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final mono = ref.watch(monobankServiceProvider);
  return ExchangeRateService(db: db, monobankService: mono);
});

// Repository Provider
final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final mono = ref.watch(monobankServiceProvider);
  final bybit = ref.watch(bybitServiceProvider);
  final rate = ref.watch(exchangeRateServiceProvider);
  final storage = ref.watch(secureStorageServiceProvider);

  return AccountRepository(
    db: db,
    monobankService: mono,
    bybitService: bybit,
    exchangeRateService: rate,
    secureStorage: storage,
  );
});

// Live USD/UAH Rate Stream Provider
final exchangeRateStreamProvider = StreamProvider<double>((ref) {
  final rateService = ref.watch(exchangeRateServiceProvider);
  return rateService.watchUsdRate();
});

// All Active Accounts Stream Provider
final accountsStreamProvider = StreamProvider<List<AccountsTableData>>((ref) {
  final repo = ref.watch(accountRepositoryProvider);
  return repo.watchAllAccounts();
});

// Selected Base Currency Notifier & Provider
class SelectedBaseCurrencyNotifier extends Notifier<AppCurrency> {
  @override
  AppCurrency build() => AppCurrency.uah;

  void setCurrency(AppCurrency currency) => state = currency;
}

final selectedBaseCurrencyProvider =
    NotifierProvider<SelectedBaseCurrencyNotifier, AppCurrency>(
  SelectedBaseCurrencyNotifier.new,
);

// Global Account Filter Notifier & Provider
class SelectedAccountFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setFilter(String? accountId) => state = accountId;
}

final selectedAccountFilterProvider =
    NotifierProvider<SelectedAccountFilterNotifier, String?>(
  SelectedAccountFilterNotifier.new,
);

// Categories Stream Provider
final categoriesStreamProvider = StreamProvider<List<CategoriesTableData>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.select(db.categoriesTable).watch();
});
