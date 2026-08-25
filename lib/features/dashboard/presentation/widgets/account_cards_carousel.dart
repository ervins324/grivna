import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../accounts/providers/account_providers.dart';

class AccountCardsCarousel extends ConsumerWidget {
  final VoidCallback onAddAccount;

  const AccountCardsCarousel({
    super.key,
    required this.onAddAccount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsStreamProvider);
    final selectedFilter = ref.watch(selectedAccountFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ACCOUNTS',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppColors.textTertiary,
                ),
              ),
              if (selectedFilter != null)
                InkWell(
                  onTap: () => ref.read(selectedAccountFilterProvider.notifier).setFilter(null),
                  child: const Text(
                    'Clear filter (Show all)',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.transfer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: accountsAsync.when(
            data: (accounts) {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: accounts.length + 1,
                itemBuilder: (context, index) {
                  if (index == accounts.length) {
                    return _buildAddAccountCard(context);
                  }
                  final account = accounts[index];
                  final isSelected = selectedFilter == account.id;
                  return _buildAccountCard(context, ref, account, isSelected);
                },
              );
            },
            loading: () => const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary),
              ),
            ),
            error: (e, _) => Center(
              child: Text('Error loading accounts', style: TextStyle(color: AppColors.negative)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountCard(
    BuildContext context,
    WidgetRef ref,
    AccountsTableData account,
    bool isSelected,
  ) {
    final curr = AppCurrency.fromCode(account.currency);
    Color brandColor = AppColors.surfaceElevated;
    IconData typeIcon = Icons.account_balance_wallet;

    if (account.type == 'monobank') {
      brandColor = const Color(0xFF1F1F1F);
      typeIcon = Icons.credit_card;
    } else if (account.type == 'bybit') {
      brandColor = const Color(0xFF221C11);
      typeIcon = Icons.currency_bitcoin;
    } else if (account.type == 'cash') {
      brandColor = const Color(0xFF0D2818);
      typeIcon = Icons.payments_outlined;
    } else if (account.type == 'manual') {
      brandColor = const Color(0xFF1E1735);
      typeIcon = Icons.lock_outline;
    }

    return InkWell(
      onTap: () {
        final current = ref.read(selectedAccountFilterProvider);
        ref.read(selectedAccountFilterProvider.notifier).setFilter(
              current == account.id ? null : account.id,
            );
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 200,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: brandColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.textPrimary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(typeIcon, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      account.type.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                if (account.isSynced)
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.positive,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),

            // Account Name
            Text(
              account.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.titleMedium.copyWith(fontSize: 14),
            ),

            // Balance
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CurrencyFormatter.format(
                    account.balance,
                    currency: curr,
                    showDecimals: true,
                  ),
                  style: AppTypography.monoAmount.copyWith(fontSize: 18),
                ),
                if (account.lastSyncedAt != null)
                  Text(
                    'Synced ${DateTimeUtils.formatTime(account.lastSyncedAt!)}',
                    style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAccountCard(BuildContext context) {
    return InkWell(
      onTap: onAddAccount,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.border,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: const Icon(Icons.add, size: 20, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            Text(
              'Connect Account',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
