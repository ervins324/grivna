import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../accounts/presentation/add_account_sheet.dart';
import '../../accounts/providers/account_providers.dart';
import '../../settings/providers/settings_provider.dart';
import 'widgets/account_cards_carousel.dart';
import 'widgets/quick_manual_entry_sheet.dart';
import 'widgets/recent_transactions_list.dart';
import 'widgets/transfer_funds_sheet.dart';
import 'widgets/unified_balance_header.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'grivna',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: syncState.isSyncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary),
                  )
                : const Icon(Icons.sync, size: 20, color: AppColors.textSecondary),
            tooltip: 'Sync remote accounts & rates',
            onPressed: syncState.isSyncing
                ? null
                : () {
                    ref.read(syncNotifierProvider.notifier).syncAll();
                  },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.textPrimary,
        backgroundColor: AppColors.surfaceElevated,
        onRefresh: () async {
          await ref.read(syncNotifierProvider.notifier).syncAll();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Unified Net Worth Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: UnifiedBalanceHeader(
                  onAddExpense: () {
                    final selectedFilter = ref.read(selectedAccountFilterProvider);
                    QuickManualEntrySheet.show(
                      context,
                      initialType: 'expense',
                      initialAccountId: selectedFilter,
                    );
                  },
                  onAddIncome: () {
                    final selectedFilter = ref.read(selectedAccountFilterProvider);
                    QuickManualEntrySheet.show(
                      context,
                      initialType: 'income',
                      initialAccountId: selectedFilter,
                    );
                  },
                  onTransfer: () {
                    final selectedFilter = ref.read(selectedAccountFilterProvider);
                    TransferFundsSheet.show(
                      context,
                      initialFromAccountId: selectedFilter,
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Individual Account Carousel
              AccountCardsCarousel(
                onAddAccount: () => AddAccountSheet.show(context),
              ),

              const SizedBox(height: 24),

              // Recent Transactions List
              const RecentTransactionsList(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
