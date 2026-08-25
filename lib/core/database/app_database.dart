import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// -------------------------------------------------------------
// Drift Tables
// -------------------------------------------------------------

class AccountsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get type => text()(); // 'monobank', 'bybit', 'cash', 'manual'
  RealColumn get balance => real().withDefault(const Constant(0.0))();
  TextColumn get currency => text().withDefault(const Constant('UAH'))(); // 'UAH', 'USD'
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  IntColumn get colorHex => integer().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  TextColumn get externalAccountId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class TransactionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get accountId => text()();
  TextColumn get toAccountId => text().nullable()(); // For transfers
  RealColumn get amount => real()();
  TextColumn get currency => text().withDefault(const Constant('UAH'))();
  TextColumn get type => text()(); // 'expense', 'income', 'transfer'
  TextColumn get category => text().withDefault(const Constant('General'))();
  TextColumn get description => text().withDefault(const Constant(''))();
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get externalId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class CategoriesTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get iconName => text().withDefault(const Constant('category'))();
  IntColumn get colorHex => integer().withDefault(const Constant(0xFFFAFAFA))();
  TextColumn get type => text().withDefault(const Constant('expense'))(); // 'expense', 'income'
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class SubscriptionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get amount => real()();
  TextColumn get currency => text().withDefault(const Constant('USD'))();
  TextColumn get billingCycle => text().withDefault(const Constant('monthly'))(); // 'monthly', 'yearly', 'weekly'
  IntColumn get cycleDays => integer().withDefault(const Constant(30))();
  TextColumn get category => text().withDefault(const Constant('Subscriptions'))();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get nextBillingDate => dateTime()();
  TextColumn get accountId => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get colorHex => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ExchangeRatesTable extends Table {
  TextColumn get id => text()(); // e.g. 'USD_UAH'
  TextColumn get fromCurrency => text()();
  TextColumn get toCurrency => text()();
  RealColumn get rate => real()();
  RealColumn get buyRate => real().withDefault(const Constant(0.0))();
  RealColumn get sellRate => real().withDefault(const Constant(0.0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class AppSettingsTable extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

// -------------------------------------------------------------
// Drift Database Class
// -------------------------------------------------------------

@DriftDatabase(tables: [
  AccountsTable,
  TransactionsTable,
  CategoriesTable,
  SubscriptionsTable,
  ExchangeRatesTable,
  AppSettingsTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'grivna_db');
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          // Seed default categories and default exchange rate
          await _seedDefaults();
        },
      );

  Future<void> _seedDefaults() async {
    // Default categories
    final defaultCategories = [
      CategoriesTableCompanion(id: const Value('cat_groceries'), name: const Value('Groceries'), iconName: const Value('shopping_cart'), colorHex: const Value(0xFF10B981), type: const Value('expense')),
      CategoriesTableCompanion(id: const Value('cat_dining'), name: const Value('Dining Out'), iconName: const Value('restaurant'), colorHex: const Value(0xFFF59E0B), type: const Value('expense')),
      CategoriesTableCompanion(id: const Value('cat_transport'), name: const Value('Transport'), iconName: const Value('directions_car'), colorHex: const Value(0xFF38BDF8), type: const Value('expense')),
      CategoriesTableCompanion(id: const Value('cat_subscriptions'), name: const Value('Subscriptions'), iconName: const Value('subscriptions'), colorHex: const Value(0xFF818CF8), type: const Value('expense')),
      CategoriesTableCompanion(id: const Value('cat_housing'), name: const Value('Housing & Utilities'), iconName: const Value('home'), colorHex: const Value(0xFFC084FC), type: const Value('expense')),
      CategoriesTableCompanion(id: const Value('cat_tech'), name: const Value('Tech & Gadgets'), iconName: const Value('devices'), colorHex: const Value(0xFF94A3B8), type: const Value('expense')),
      CategoriesTableCompanion(id: const Value('cat_entertainment'), name: const Value('Entertainment'), iconName: const Value('sports_esports'), colorHex: const Value(0xFFF472B6), type: const Value('expense')),
      CategoriesTableCompanion(id: const Value('cat_health'), name: const Value('Health & Fitness'), iconName: const Value('fitness_center'), colorHex: const Value(0xFF34D399), type: const Value('expense')),
      CategoriesTableCompanion(id: const Value('cat_salary'), name: const Value('Salary'), iconName: const Value('account_balance_wallet'), colorHex: const Value(0xFF10B981), type: const Value('income')),
      CategoriesTableCompanion(id: const Value('cat_freelance'), name: const Value('Freelance & Crypto'), iconName: const Value('currency_bitcoin'), colorHex: const Value(0xFFF7A600), type: const Value('income')),
      CategoriesTableCompanion(id: const Value('cat_investment'), name: const Value('Investments'), iconName: const Value('trending_up'), colorHex: const Value(0xFF6366F1), type: const Value('income')),
      CategoriesTableCompanion(id: const Value('cat_transfer'), name: const Value('Transfer'), iconName: const Value('swap_horiz'), colorHex: const Value(0xFF38BDF8), type: const Value('transfer')),
    ];

    for (final cat in defaultCategories) {
      await into(categoriesTable).insertOnConflictUpdate(cat);
    }

    // Default fallback exchange rate (1 USD = 41.50 UAH)
    await into(exchangeRatesTable).insertOnConflictUpdate(
      ExchangeRatesTableCompanion(
        id: const Value('USD_UAH'),
        fromCurrency: const Value('USD'),
        toCurrency: const Value('UAH'),
        rate: const Value(41.50),
        buyRate: const Value(41.20),
        sellRate: const Value(41.75),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
