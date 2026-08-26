import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/security/secure_storage_service.dart';
import 'bybit_service.dart';
import 'exchange_rate_service.dart';
import 'monobank_service.dart';

class AccountRepository {
  final AppDatabase _db;
  final MonobankService _monobankService;
  final BybitService _bybitService;
  final ExchangeRateService _exchangeRateService;
  final SecureStorageService _secureStorage;
  final _uuid = const Uuid();

  AccountRepository({
    required AppDatabase db,
    MonobankService? monobankService,
    BybitService? bybitService,
    ExchangeRateService? exchangeRateService,
    SecureStorageService? secureStorage,
  })  : _db = db,
        _monobankService = monobankService ?? MonobankService(),
        _bybitService = bybitService ?? BybitService(),
        _exchangeRateService =
            exchangeRateService ?? ExchangeRateService(db: db),
        _secureStorage = secureStorage ?? SecureStorageService();

  // ---------------------------------------------------------------------------
  // Accounts CRUD
  // ---------------------------------------------------------------------------

  Stream<List<AccountsTableData>> watchAllAccounts() {
    return (_db.select(_db.accountsTable)
          ..where((tbl) => tbl.isArchived.equals(false)))
        .watch();
  }

  Future<List<AccountsTableData>> getAllAccounts() {
    return (_db.select(_db.accountsTable)
          ..where((tbl) => tbl.isArchived.equals(false)))
        .get();
  }

  Future<AccountsTableData?> getAccountById(String id) {
    return (_db.select(_db.accountsTable)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> createAccount({
    required String name,
    required String type, // 'monobank', 'bybit', 'cash', 'manual'
    required double balance,
    required String currency, // 'UAH', 'USD'
    int? colorHex,
    String? apiToken,
    String? apiKey,
    String? apiSecret,
  }) async {
    final id = _uuid.v4();

    if (apiToken != null && apiToken.isNotEmpty) {
      await _secureStorage.saveSecret('mono_$id', apiToken);
    }
    if (apiKey != null && apiKey.isNotEmpty) {
      await _secureStorage.saveSecret('bybit_key_$id', apiKey);
    }
    if (apiSecret != null && apiSecret.isNotEmpty) {
      await _secureStorage.saveSecret('bybit_secret_$id', apiSecret);
    }

    await _db.into(_db.accountsTable).insert(
          AccountsTableCompanion(
            id: Value(id),
            name: Value(name),
            type: Value(type),
            balance: Value(balance),
            currency: Value(currency),
            isSynced: Value(type == 'monobank' || type == 'bybit'),
            colorHex: Value(colorHex),
            lastSyncedAt: Value(DateTime.now()),
            isArchived: const Value(false),
          ),
        );
  }

  Future<void> updateAccountBalance(String id, double newBalance) async {
    await (_db.update(_db.accountsTable)..where((tbl) => tbl.id.equals(id)))
        .write(
      AccountsTableCompanion(
        balance: Value(newBalance),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteAccount(String id) async {
    await _secureStorage.deleteSecret('mono_$id');
    await _secureStorage.deleteSecret('bybit_key_$id');
    await _secureStorage.deleteSecret('bybit_secret_$id');
    await (_db.delete(_db.accountsTable)..where((tbl) => tbl.id.equals(id))).go();
    await (_db.delete(_db.transactionsTable)..where((tbl) => tbl.accountId.equals(id))).go();
  }

  Future<void> clearAllData() async {
    final accounts = await getAllAccounts();
    for (final acc in accounts) {
      await _secureStorage.deleteSecret('mono_${acc.id}');
      await _secureStorage.deleteSecret('bybit_key_${acc.id}');
      await _secureStorage.deleteSecret('bybit_secret_${acc.id}');
    }
    await _db.delete(_db.transactionsTable).go();
    await _db.delete(_db.subscriptionsTable).go();
    await _db.delete(_db.accountsTable).go();
  }

  // ---------------------------------------------------------------------------
  // Transactions CRUD & Transfers
  // ---------------------------------------------------------------------------

  Stream<List<TransactionsTableData>> watchTransactions({String? accountId, int limit = 100}) {
    final query = _db.select(_db.transactionsTable);
    if (accountId != null && accountId.isNotEmpty) {
      query.where((tbl) => tbl.accountId.equals(accountId) | tbl.toAccountId.equals(accountId));
    }
    query.orderBy([
      (tbl) => OrderingTerm(expression: tbl.timestamp, mode: OrderingMode.desc),
    ]);
    query.limit(limit);
    return query.watch();
  }

  Future<List<TransactionsTableData>> getAllTransactions({String? accountId}) {
    final query = _db.select(_db.transactionsTable);
    if (accountId != null && accountId.isNotEmpty) {
      query.where((tbl) => tbl.accountId.equals(accountId) | tbl.toAccountId.equals(accountId));
    }
    query.orderBy([
      (tbl) => OrderingTerm(expression: tbl.timestamp, mode: OrderingMode.desc),
    ]);
    return query.get();
  }

  Future<void> addTransaction({
    required String accountId,
    required double amount,
    required String currency,
    required String type, // 'expense', 'income'
    required String category,
    required String description,
    DateTime? timestamp,
  }) async {
    final txId = _uuid.v4();
    final time = timestamp ?? DateTime.now();

    await _db.into(_db.transactionsTable).insert(
          TransactionsTableCompanion(
            id: Value(txId),
            accountId: Value(accountId),
            amount: Value(amount),
            currency: Value(currency),
            type: Value(type),
            category: Value(category),
            description: Value(description),
            timestamp: Value(time),
            isSynced: const Value(false),
          ),
        );

    // Update account balance
    final account = await getAccountById(accountId);
    if (account != null) {
      final newBalance = type == 'income'
          ? account.balance + amount
          : account.balance - amount;
      await updateAccountBalance(accountId, newBalance);
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    final tx = await (_db.select(_db.transactionsTable)..where((tbl) => tbl.id.equals(transactionId))).getSingleOrNull();
    if (tx != null) {
      final account = await getAccountById(tx.accountId);
      if (account != null) {
        // Revert balance
        final revertedBalance = tx.type == 'income'
            ? account.balance - tx.amount
            : account.balance + tx.amount;
        await updateAccountBalance(account.id, revertedBalance);
      }
      await (_db.delete(_db.transactionsTable)..where((tbl) => tbl.id.equals(transactionId))).go();
    }
  }

  Future<void> transferFunds({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    String description = 'Account Transfer',
  }) async {
    final fromAccount = await getAccountById(fromAccountId);
    final toAccount = await getAccountById(toAccountId);
    if (fromAccount == null || toAccount == null) return;

    final usdRate = await _exchangeRateService.getCachedUsdRate();

    // Deduct from source
    final newFromBalance = fromAccount.balance - amount;
    await updateAccountBalance(fromAccountId, newFromBalance);

    // Calculate converted amount if currencies differ
    double destinationAmount = amount;
    if (fromAccount.currency == 'UAH' && toAccount.currency == 'USD') {
      destinationAmount = amount / usdRate;
    } else if (fromAccount.currency == 'USD' && toAccount.currency == 'UAH') {
      destinationAmount = amount * usdRate;
    }

    // Add to destination
    final newToBalance = toAccount.balance + destinationAmount;
    await updateAccountBalance(toAccountId, newToBalance);

    // Record transfer transaction
    final txId = _uuid.v4();
    await _db.into(_db.transactionsTable).insert(
          TransactionsTableCompanion(
            id: Value(txId),
            accountId: Value(fromAccountId),
            toAccountId: Value(toAccountId),
            amount: Value(amount),
            currency: Value(fromAccount.currency),
            type: const Value('transfer'),
            category: const Value('Transfer'),
            description: Value(description),
            timestamp: Value(DateTime.now()),
            isSynced: const Value(false),
          ),
        );
  }

  // ---------------------------------------------------------------------------
  // Subscriptions CRUD
  // ---------------------------------------------------------------------------

  Stream<List<SubscriptionsTableData>> watchSubscriptions() {
    return (_db.select(_db.subscriptionsTable)
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.nextBillingDate)]))
        .watch();
  }

  Future<void> addSubscription({
    required String name,
    required double amount,
    required String currency,
    required String billingCycle,
    required int cycleDays,
    required String category,
    required DateTime startDate,
    required DateTime nextBillingDate,
    String? accountId,
    int? colorHex,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.subscriptionsTable).insert(
          SubscriptionsTableCompanion(
            id: Value(id),
            name: Value(name),
            amount: Value(amount),
            currency: Value(currency),
            billingCycle: Value(billingCycle),
            cycleDays: Value(cycleDays),
            category: Value(category),
            startDate: Value(startDate),
            nextBillingDate: Value(nextBillingDate),
            accountId: Value(accountId),
            isActive: const Value(true),
            colorHex: Value(colorHex),
          ),
        );
  }

  Future<void> toggleSubscription(String id, bool isActive) async {
    await (_db.update(_db.subscriptionsTable)..where((tbl) => tbl.id.equals(id)))
        .write(SubscriptionsTableCompanion(isActive: Value(isActive)));
  }

  Future<void> deleteSubscription(String id) async {
    await (_db.delete(_db.subscriptionsTable)..where((tbl) => tbl.id.equals(id))).go();
  }

  // ---------------------------------------------------------------------------
  // Sync Remote Accounts (Monobank & Bybit)
  // ---------------------------------------------------------------------------

  Future<void> syncMonobankAccount(String accountId) async {
    final token = await _secureStorage.getSecret('mono_$accountId');
    if (token == null || token.isEmpty) return;

    try {
      final clientInfo = await _monobankService.getClientInfo(token);
      final account = await getAccountById(accountId);
      if (account == null) return;

      // Find matching monobank account
      final monoAcc = clientInfo.accounts.firstWhere(
        (a) => a.id == account.externalAccountId || a.currency == account.currency,
        orElse: () => clientInfo.accounts.first,
      );

      await updateAccountBalance(accountId, monoAcc.balance);

      // Fetch extended transactions (up to 365 days in 30-day windows)
      final now = DateTime.now();
      final from = now.subtract(const Duration(days: 365));
      final statements = await _monobankService.getExtendedStatement(
        apiToken: token,
        accountId: monoAcc.id.isNotEmpty ? monoAcc.id : '0',
        from: from,
        to: now,
        maxChunks: 12,
      );

      for (final item in statements) {
        final txId = 'mono_${item.id}';
        final isIncome = item.amount > 0;
        final absAmount = item.amount.abs();
        final cat = _mapMccToCategory(item.mcc);

        await _db.into(_db.transactionsTable).insertOnConflictUpdate(
              TransactionsTableCompanion(
                id: Value(txId),
                accountId: Value(accountId),
                amount: Value(absAmount),
                currency: Value(account.currency),
                type: Value(isIncome ? 'income' : 'expense'),
                category: Value(cat),
                description: Value(item.description),
                timestamp: Value(DateTime.fromMillisecondsSinceEpoch(item.time * 1000)),
                isSynced: const Value(true),
                externalId: Value(item.id),
              ),
            );
      }
    } catch (_) {
      // Ignore or log network errors
    }
  }

  Future<void> syncBybitAccount(String accountId) async {
    final apiKey = await _secureStorage.getSecret('bybit_key_$accountId');
    final apiSecret = await _secureStorage.getSecret('bybit_secret_$accountId');
    if (apiKey == null || apiSecret == null) return;

    try {
      final balanceInfo = await _bybitService.getWalletBalance(
        apiKey: apiKey,
        apiSecret: apiSecret,
      );

      await updateAccountBalance(accountId, balanceInfo.totalEquityUsd);

      final transactions = await _bybitService.getRecentTransactions(
        apiKey: apiKey,
        apiSecret: apiSecret,
      );

      for (final tx in transactions) {
        final txId = 'bybit_${tx.id}';
        final isIncome = tx.change > 0;
        await _db.into(_db.transactionsTable).insertOnConflictUpdate(
              TransactionsTableCompanion(
                id: Value(txId),
                accountId: Value(accountId),
                amount: Value(tx.change.abs()),
                currency: const Value('USD'),
                type: Value(isIncome ? 'income' : 'expense'),
                category: const Value('Freelance & Crypto'),
                description: Value('Bybit Card / ${tx.coin} ${tx.type}'),
                timestamp: Value(tx.transactionTime),
                isSynced: const Value(true),
                externalId: Value(tx.id),
              ),
            );
      }
    } catch (_) {
      // Ignore network errors
    }
  }

  String _mapMccToCategory(int mcc) {
    if ([5411, 5422, 5441, 5451, 5499].contains(mcc)) return 'Groceries';
    if ([5812, 5814, 5813].contains(mcc)) return 'Dining Out';
    if ([4111, 4121, 4789, 5541, 5542].contains(mcc)) return 'Transport';
    if ([4899, 5735, 5815, 5817, 5818].contains(mcc)) return 'Subscriptions';
    if ([4900, 4814, 6513].contains(mcc)) return 'Housing & Utilities';
    if ([5732, 5734, 5045].contains(mcc)) return 'Tech & Gadgets';
    if ([7832, 7999, 7922].contains(mcc)) return 'Entertainment';
    if ([8011, 8021, 8099, 7997].contains(mcc)) return 'Health & Fitness';
    return 'General';
  }

  // ---------------------------------------------------------------------------
  // Demo Data Seeder (Immediate testing with realistic data)
  // ---------------------------------------------------------------------------

  Future<void> seedDemoData() async {
    // Clear existing
    await _db.delete(_db.accountsTable).go();
    await _db.delete(_db.transactionsTable).go();
    await _db.delete(_db.subscriptionsTable).go();

    final now = DateTime.now();

    // Accounts
    final monoAccId = 'demo_monobank';
    final bybitAccId = 'demo_bybit';
    final cashAccId = 'demo_cash';
    final vaultAccId = 'demo_vault';

    await _db.into(_db.accountsTable).insert(
          AccountsTableCompanion(
            id: Value(monoAccId),
            name: const Value('Monobank Black'),
            type: const Value('monobank'),
            balance: const Value(48750.00),
            currency: const Value('UAH'),
            isSynced: const Value(true),
            lastSyncedAt: Value(now),
            colorHex: const Value(0xFF1E1E1E),
            isArchived: const Value(false),
          ),
        );

    await _db.into(_db.accountsTable).insert(
          AccountsTableCompanion(
            id: Value(bybitAccId),
            name: const Value('Bybit Card USD'),
            type: const Value('bybit'),
            balance: const Value(3420.50),
            currency: const Value('USD'),
            isSynced: const Value(true),
            lastSyncedAt: Value(now),
            colorHex: const Value(0xFFF7A600),
            isArchived: const Value(false),
          ),
        );

    await _db.into(_db.accountsTable).insert(
          AccountsTableCompanion(
            id: Value(cashAccId),
            name: const Value('Cash Wallet'),
            type: const Value('cash'),
            balance: const Value(8500.00),
            currency: const Value('UAH'),
            isSynced: const Value(false),
            lastSyncedAt: Value(now),
            colorHex: const Value(0xFF10B981),
            isArchived: const Value(false),
          ),
        );

    await _db.into(_db.accountsTable).insert(
          AccountsTableCompanion(
            id: Value(vaultAccId),
            name: const Value('Emergency Vault'),
            type: const Value('manual'),
            balance: const Value(5000.00),
            currency: const Value('USD'),
            isSynced: const Value(false),
            lastSyncedAt: Value(now),
            colorHex: const Value(0xFF8B5CF6),
            isArchived: const Value(false),
          ),
        );

    // Subscriptions
    final demoSubscriptions = [
      SubscriptionsTableCompanion(
        id: const Value('sub_chatgpt'),
        name: const Value('ChatGPT Plus'),
        amount: const Value(20.00),
        currency: const Value('USD'),
        billingCycle: const Value('monthly'),
        cycleDays: const Value(30),
        category: const Value('Subscriptions'),
        startDate: Value(now.subtract(const Duration(days: 120))),
        nextBillingDate: Value(now.add(const Duration(days: 4))),
        accountId: Value(bybitAccId),
        isActive: const Value(true),
        colorHex: const Value(0xFF10A37F),
      ),
      SubscriptionsTableCompanion(
        id: const Value('sub_spotify'),
        name: const Value('Spotify Premium'),
        amount: const Value(4.99),
        currency: const Value('USD'),
        billingCycle: const Value('monthly'),
        cycleDays: const Value(30),
        category: const Value('Subscriptions'),
        startDate: Value(now.subtract(const Duration(days: 200))),
        nextBillingDate: Value(now.add(const Duration(days: 9))),
        accountId: Value(bybitAccId),
        isActive: const Value(true),
        colorHex: const Value(0xFF1DB954),
      ),
      SubscriptionsTableCompanion(
        id: const Value('sub_icloud'),
        name: const Value('iCloud+ 2TB'),
        amount: const Value(9.99),
        currency: const Value('USD'),
        billingCycle: const Value('monthly'),
        cycleDays: const Value(30),
        category: const Value('Subscriptions'),
        startDate: Value(now.subtract(const Duration(days: 300))),
        nextBillingDate: Value(now.add(const Duration(days: 14))),
        accountId: Value(bybitAccId),
        isActive: const Value(true),
        colorHex: const Value(0xFF38BDF8),
      ),
      SubscriptionsTableCompanion(
        id: const Value('sub_gym'),
        name: const Value('SportLife Gym Club'),
        amount: const Value(1800.00),
        currency: const Value('UAH'),
        billingCycle: const Value('monthly'),
        cycleDays: const Value(30),
        category: const Value('Health & Fitness'),
        startDate: Value(now.subtract(const Duration(days: 90))),
        nextBillingDate: Value(now.add(const Duration(days: 18))),
        accountId: Value(monoAccId),
        isActive: const Value(true),
        colorHex: const Value(0xFFF59E0B),
      ),
      SubscriptionsTableCompanion(
        id: const Value('sub_github'),
        name: const Value('GitHub Copilot Pro'),
        amount: const Value(100.00),
        currency: const Value('USD'),
        billingCycle: const Value('yearly'),
        cycleDays: const Value(365),
        category: const Value('Subscriptions'),
        startDate: Value(now.subtract(const Duration(days: 180))),
        nextBillingDate: Value(now.add(const Duration(days: 62))),
        accountId: Value(bybitAccId),
        isActive: const Value(true),
        colorHex: const Value(0xFFFAFAFA),
      ),
    ];

    for (final sub in demoSubscriptions) {
      await _db.into(_db.subscriptionsTable).insert(sub);
    }

    // Transactions across past 6 months
    final demoTransactions = <TransactionsTableCompanion>[];

    // Recent items (Past 7 days)
    demoTransactions.add(TransactionsTableCompanion(
      id: const Value('tx_d1'),
      accountId: Value(monoAccId),
      amount: const Value(680.00),
      currency: const Value('UAH'),
      type: const Value('expense'),
      category: const Value('Groceries'),
      description: const Value('Silpo Supermarket Kyiv'),
      timestamp: Value(now.subtract(const Duration(hours: 3))),
      isSynced: const Value(true),
    ));

    demoTransactions.add(TransactionsTableCompanion(
      id: const Value('tx_d2'),
      accountId: Value(bybitAccId),
      amount: const Value(45.50),
      currency: const Value('USD'),
      type: const Value('expense'),
      category: const Value('Tech & Gadgets'),
      description: const Value('AWS Hosting Services'),
      timestamp: Value(now.subtract(const Duration(hours: 14))),
      isSynced: const Value(true),
    ));

    demoTransactions.add(TransactionsTableCompanion(
      id: const Value('tx_d3'),
      accountId: Value(monoAccId),
      amount: const Value(240.00),
      currency: const Value('UAH'),
      type: const Value('expense'),
      category: const Value('Transport'),
      description: const Value('Bolt Taxi Trip'),
      timestamp: Value(now.subtract(const Duration(days: 1, hours: 2))),
      isSynced: const Value(true),
    ));

    demoTransactions.add(TransactionsTableCompanion(
      id: const Value('tx_d4'),
      accountId: Value(monoAccId),
      amount: const Value(490.00),
      currency: const Value('UAH'),
      type: const Value('expense'),
      category: const Value('Dining Out'),
      description: const Value('Coffee & Brunch at Idealist'),
      timestamp: Value(now.subtract(const Duration(days: 2))),
      isSynced: const Value(true),
    ));

    demoTransactions.add(TransactionsTableCompanion(
      id: const Value('tx_d5'),
      accountId: Value(bybitAccId),
      amount: const Value(2500.00),
      currency: const Value('USD'),
      type: const Value('income'),
      category: const Value('Freelance & Crypto'),
      description: const Value('Contract Milestone Payout'),
      timestamp: Value(now.subtract(const Duration(days: 3))),
      isSynced: const Value(true),
    ));

    demoTransactions.add(TransactionsTableCompanion(
      id: const Value('tx_d6'),
      accountId: Value(cashAccId),
      amount: const Value(350.00),
      currency: const Value('UAH'),
      type: const Value('expense'),
      category: const Value('Groceries'),
      description: const Value('Farmer Market Fresh Fruits'),
      timestamp: Value(now.subtract(const Duration(days: 4))),
      isSynced: const Value(false),
    ));

    demoTransactions.add(TransactionsTableCompanion(
      id: const Value('tx_d7'),
      accountId: Value(monoAccId),
      amount: const Value(42000.00),
      currency: const Value('UAH'),
      type: const Value('income'),
      category: const Value('Salary'),
      description: const Value('Monthly Tech Salary'),
      timestamp: Value(now.subtract(const Duration(days: 6))),
      isSynced: const Value(true),
    ));

    // Historical transactions over past 5 months to feed 6-Month charts & category trends
    final categories = ['Groceries', 'Dining Out', 'Transport', 'Subscriptions', 'Housing & Utilities', 'Entertainment'];
    final amounts = [1250.0, 620.0, 310.0, 850.0, 3400.0, 950.0];

    for (int monthBack = 1; monthBack <= 5; monthBack++) {
      final baseDate = DateTime(now.year, now.month - monthBack, 15);
      // Add regular income
      demoTransactions.add(TransactionsTableCompanion(
        id: Value('tx_hist_inc_$monthBack'),
        accountId: Value(monoAccId),
        amount: const Value(42000.00),
        currency: const Value('UAH'),
        type: const Value('income'),
        category: const Value('Salary'),
        description: Value('Salary ${baseDate.month}/${baseDate.year}'),
        timestamp: Value(baseDate.subtract(const Duration(days: 10))),
        isSynced: const Value(true),
      ));

      demoTransactions.add(TransactionsTableCompanion(
        id: Value('tx_hist_bybit_inc_$monthBack'),
        accountId: Value(bybitAccId),
        amount: const Value(1800.00),
        currency: const Value('USD'),
        type: const Value('income'),
        category: const Value('Freelance & Crypto'),
        description: Value('Client Payout ${baseDate.month}/${baseDate.year}'),
        timestamp: Value(baseDate.subtract(const Duration(days: 5))),
        isSynced: const Value(true),
      ));

      // Add expense series
      for (int i = 0; i < categories.length; i++) {
        demoTransactions.add(TransactionsTableCompanion(
          id: Value('tx_hist_exp_${monthBack}_$i'),
          accountId: Value(i % 2 == 0 ? monoAccId : bybitAccId),
          amount: Value(i % 2 == 0 ? amounts[i] * (1.0 + (monthBack * 0.05)) : (amounts[i] / 40.0)),
          currency: Value(i % 2 == 0 ? 'UAH' : 'USD'),
          type: const Value('expense'),
          category: Value(categories[i]),
          description: Value('${categories[i]} Expense'),
          timestamp: Value(baseDate.add(Duration(days: i * 2))),
          isSynced: const Value(true),
        ));
      }
    }

    for (final tx in demoTransactions) {
      await _db.into(_db.transactionsTable).insert(tx);
    }
  }
}
