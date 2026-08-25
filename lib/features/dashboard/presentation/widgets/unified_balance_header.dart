import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../accounts/providers/account_providers.dart';
import '../../providers/dashboard_providers.dart';

class UnifiedBalanceHeader extends ConsumerWidget {
  final VoidCallback onAddExpense;
  final VoidCallback onAddIncome;
  final VoidCallback onTransfer;

  const UnifiedBalanceHeader({
    super.key,
    required this.onAddExpense,
    required this.onAddIncome,
    required this.onTransfer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(unifiedBalanceProvider);
    final baseCurrency = ref.watch(selectedBaseCurrencyProvider);
    final monthlyOverviewAsync = ref.watch(monthlyOverviewProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Net Worth Label & Currency Switcher
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.positive,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'TOTAL NET WORTH',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              // Currency Toggle Pill
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    _buildCurrencyChip(
                      context,
                      ref,
                      currency: AppCurrency.uah,
                      label: 'UAH ₴',
                      isSelected: baseCurrency == AppCurrency.uah,
                    ),
                    const SizedBox(width: 4),
                    _buildCurrencyChip(
                      context,
                      ref,
                      currency: AppCurrency.usd,
                      label: 'USD \$',
                      isSelected: baseCurrency == AppCurrency.usd,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Big Main Balance
          balanceAsync.when(
            data: (state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    CurrencyFormatter.format(
                      state.totalBalance,
                      currency: state.baseCurrency,
                      showDecimals: true,
                    ),
                    style: AppTypography.displayLarge,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '1 USD ≈ ${state.usdRate.toStringAsFixed(2)} UAH',
                          style: AppTypography.monoSmall.copyWith(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${state.totalAccountsCount} accounts connected',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                height: 44,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary),
                  ),
                ),
              ),
            ),
            error: (e, _) => Text('Error loading balance', style: TextStyle(color: AppColors.negative)),
          ),

          const SizedBox(height: 20),

          // Monthly Inflow & Outflow Stats
          monthlyOverviewAsync.when(
            data: (stats) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.positiveMuted.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_downward, color: AppColors.positive, size: 14),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Inflow', style: AppTypography.bodySmall),
                              Text(
                                CurrencyFormatter.format(
                                  stats.totalIncome,
                                  currency: baseCurrency,
                                  showDecimals: false,
                                ),
                                style: AppTypography.titleMedium.copyWith(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 28, color: AppColors.border),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.negativeMuted.withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_upward, color: AppColors.negative, size: 14),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Outflow', style: AppTypography.bodySmall),
                                Text(
                                  CurrencyFormatter.format(
                                    stats.totalExpense,
                                    currency: baseCurrency,
                                    showDecimals: false,
                                  ),
                                  style: AppTypography.titleMedium.copyWith(fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 18),

          // Quick Action Buttons (Expense, Income, Transfer)
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.remove,
                  label: 'Expense',
                  color: AppColors.surfaceElevated,
                  textColor: AppColors.textPrimary,
                  onTap: onAddExpense,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.add,
                  label: 'Income',
                  color: AppColors.surfaceElevated,
                  textColor: AppColors.textPrimary,
                  onTap: onAddIncome,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.swap_horiz,
                  label: 'Transfer',
                  color: AppColors.surfaceElevated,
                  textColor: AppColors.transfer,
                  onTap: onTransfer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyChip(
    BuildContext context,
    WidgetRef ref, {
    required AppCurrency currency,
    required String label,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        ref.read(selectedBaseCurrencyProvider.notifier).setCurrency(currency);
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.background : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
