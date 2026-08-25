import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import 'monobank_service.dart';

class ExchangeRateService {
  final MonobankService _monobankService;
  final AppDatabase _db;

  ExchangeRateService({
    MonobankService? monobankService,
    required AppDatabase db,
  })  : _monobankService = monobankService ?? MonobankService(),
        _db = db;

  /// Syncs USD/UAH exchange rates from Monobank and stores them in Drift DB
  Future<double> syncExchangeRates() async {
    try {
      final currencies = await _monobankService.getPublicCurrencies();
      // Look for USD (840) to UAH (980)
      for (final item in currencies) {
        final cA = item['currencyCodeA'] as int?;
        final cB = item['currencyCodeB'] as int?;
        if (cA == 840 && cB == 980) {
          final rateBuy = (item['rateBuy'] as num?)?.toDouble() ?? 0.0;
          final rateSell = (item['rateSell'] as num?)?.toDouble() ?? 0.0;
          final rateCross = (item['rateCross'] as num?)?.toDouble() ?? 0.0;

          final effectiveRate = rateCross > 0
              ? rateCross
              : (rateBuy > 0 && rateSell > 0 ? (rateBuy + rateSell) / 2.0 : 41.50);

          await _db.into(_db.exchangeRatesTable).insertOnConflictUpdate(
                ExchangeRatesTableCompanion(
                  id: const Value('USD_UAH'),
                  fromCurrency: const Value('USD'),
                  toCurrency: const Value('UAH'),
                  rate: Value(effectiveRate),
                  buyRate: Value(rateBuy),
                  sellRate: Value(rateSell),
                  updatedAt: Value(DateTime.now()),
                ),
              );

          return effectiveRate;
        }
      }
    } catch (_) {
      // Ignore network errors, fall back to cached DB rate
    }

    return getCachedUsdRate();
  }

  /// Get cached USD -> UAH rate from Drift DB
  Future<double> getCachedUsdRate() async {
    final query = _db.select(_db.exchangeRatesTable)
      ..where((tbl) => tbl.id.equals('USD_UAH'));
    final result = await query.getSingleOrNull();
    return result?.rate ?? 41.50;
  }

  /// Watch USD -> UAH rate stream
  Stream<double> watchUsdRate() {
    final query = _db.select(_db.exchangeRatesTable)
      ..where((tbl) => tbl.id.equals('USD_UAH'));
    return query.watchSingleOrNull().map((entry) => entry?.rate ?? 41.50);
  }
}
