import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../accounts/providers/account_providers.dart';

class SyncStatusState {
  final bool isSyncing;
  final String? lastSyncMessage;
  final DateTime? lastSyncTime;

  SyncStatusState({
    this.isSyncing = false,
    this.lastSyncMessage,
    this.lastSyncTime,
  });
}

class SyncNotifier extends Notifier<SyncStatusState> {
  @override
  SyncStatusState build() => SyncStatusState();

  Future<void> syncAll() async {
    state = SyncStatusState(isSyncing: true, lastSyncMessage: 'Syncing accounts and rates...');
    try {
      final rateService = ref.read(exchangeRateServiceProvider);
      final repo = ref.read(accountRepositoryProvider);

      // Sync exchange rates
      await rateService.syncExchangeRates();

      // Sync all accounts
      final accounts = await repo.getAllAccounts();
      for (final acc in accounts) {
        if (acc.type == 'monobank') {
          await repo.syncMonobankAccount(acc.id);
        } else if (acc.type == 'bybit') {
          await repo.syncBybitAccount(acc.id);
        }
      }

      state = SyncStatusState(
        isSyncing: false,
        lastSyncMessage: 'All accounts synced successfully',
        lastSyncTime: DateTime.now(),
      );
    } catch (e) {
      state = SyncStatusState(
        isSyncing: false,
        lastSyncMessage: 'Sync error: $e',
        lastSyncTime: DateTime.now(),
      );
    }
  }

  Future<void> seedDemo() async {
    state = SyncStatusState(isSyncing: true, lastSyncMessage: 'Populating demo accounts...');
    final repo = ref.read(accountRepositoryProvider);
    await repo.seedDemoData();
    state = SyncStatusState(
      isSyncing: false,
      lastSyncMessage: 'Demo data loaded successfully',
      lastSyncTime: DateTime.now(),
    );
  }
}

final syncNotifierProvider =
    NotifierProvider<SyncNotifier, SyncStatusState>(SyncNotifier.new);
