import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../accounts/providers/account_providers.dart';
import '../../providers/dashboard_providers.dart';

class RecentTransactionsList extends ConsumerStatefulWidget {
  const RecentTransactionsList({super.key});

  @override
  ConsumerState<RecentTransactionsList> createState() => _RecentTransactionsListState();
}

class _RecentTransactionsListState extends ConsumerState<RecentTransactionsList> {
  final String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'expense', 'income', 'transfer'

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(recentTransactionsProvider);
    final accounts = ref.watch(accountsStreamProvider).value ?? [];
    final accountMap = {for (var a in accounts) a.id: a};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT TRANSACTIONS',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppColors.textTertiary,
                ),
              ),
              // Filter chips (All / In / Out / Trans)
              Row(
                children: [
                  _buildTypeFilterChip('All', 'All'),
                  const SizedBox(width: 4),
                  _buildTypeFilterChip('Out', 'expense'),
                  const SizedBox(width: 4),
                  _buildTypeFilterChip('In', 'income'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Transactions List
        transactionsAsync.when(
          data: (transactions) {
            var filtered = transactions;
            if (_selectedFilter != 'All') {
              filtered = filtered.where((t) => t.type == _selectedFilter).toList();
            }
            if (_searchQuery.isNotEmpty) {
              filtered = filtered.where((t) {
                return t.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    t.category.toLowerCase().contains(_searchQuery.toLowerCase());
              }).toList();
            }

            if (filtered.isEmpty) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.symmetric(vertical: 36),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 36, color: AppColors.textTertiary),
                      const SizedBox(height: 10),
                      Text('No transactions found', style: AppTypography.bodyMedium),
                      const SizedBox(height: 4),
                      Text('Tap + to log your first transaction', style: AppTypography.bodySmall),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final tx = filtered[index];
                final account = accountMap[tx.accountId];
                final curr = AppCurrency.fromCode(tx.currency);

                return Dismissible(
                  key: Key(tx.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    padding: const EdgeInsets.only(right: 20),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      color: AppColors.negative,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
                  ),
                  onDismissed: (_) {
                    ref.read(accountRepositoryProvider).deleteTransaction(tx.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        // Category Icon Avatar
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Center(
                            child: Icon(
                              _getCategoryIcon(tx.category, tx.type),
                              size: 18,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Title & Account Name
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.description.isNotEmpty ? tx.description : tx.category,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.titleMedium.copyWith(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  if (account != null) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceElevated,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        account.name,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(
                                    DateTimeUtils.formatRelativeDate(tx.timestamp),
                                    style: AppTypography.bodySmall.copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Amount
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              tx.type == 'transfer'
                                  ? CurrencyFormatter.format(tx.amount, currency: curr)
                                  : CurrencyFormatter.format(
                                      tx.type == 'expense' ? -tx.amount : tx.amount,
                                      currency: curr,
                                      includePlusSign: true,
                                    ),
                              style: AppTypography.monoAmount.copyWith(
                                fontSize: 14,
                                color: tx.type == 'income'
                                    ? AppColors.positive
                                    : (tx.type == 'transfer' ? AppColors.transfer : AppColors.textPrimary),
                              ),
                            ),
                            if (tx.isSynced)
                              const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Text(
                                  'Auto-synced',
                                  style: TextStyle(fontSize: 9, color: AppColors.textTertiary),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary),
            ),
          ),
          error: (e, _) => Center(
            child: Text('Error loading transactions', style: TextStyle(color: AppColors.negative)),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeFilterChip(String label, String type) {
    final isSelected = _selectedFilter == type;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = type),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textPrimary : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.background : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category, String type) {
    if (type == 'transfer') return Icons.swap_horiz;
    switch (category.toLowerCase()) {
      case 'groceries':
        return Icons.shopping_cart_outlined;
      case 'dining out':
        return Icons.restaurant_outlined;
      case 'transport':
        return Icons.directions_car_outlined;
      case 'subscriptions':
        return Icons.subscriptions_outlined;
      case 'housing & utilities':
        return Icons.home_outlined;
      case 'tech & gadgets':
        return Icons.devices_outlined;
      case 'entertainment':
        return Icons.sports_esports_outlined;
      case 'health & fitness':
        return Icons.fitness_center_outlined;
      case 'salary':
        return Icons.account_balance_wallet_outlined;
      case 'freelance & crypto':
        return Icons.currency_bitcoin;
      case 'investments':
        return Icons.trending_up;
      default:
        return Icons.attach_money;
    }
  }
}
