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
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.neonBorder.withValues(alpha: 0.25), width: 1.2),
        boxShadow: AppColors.softCardGlow(),
      ),
      child: Stack(
        children: [
          // Soft ambient neon green gradient glow at top corner
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonGreen.withValues(alpha: 0.08),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonGreen.withValues(alpha: 0.12),
                    blurRadius: 50,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Net Worth Label & Currency Switcher
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Soft glowing neon live dot
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.neonGreen,
                            shape: BoxShape.circle,
                            boxShadow: AppColors.neonGlow(blur: 8, color: AppColors.neonGreen),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'TOTAL NET WORTH',
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.3,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    // Currency Toggle Pill with subtle neon highlight
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
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.neonGreenSubtle,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.neonBorder.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.bolt, size: 12, color: AppColors.neonGreen),
                                  const SizedBox(width: 4),
                                  Text(
                                    '1 USD ≈ ${state.usdRate.toStringAsFixed(2)} UAH',
                                    style: AppTypography.monoSmall.copyWith(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.neonGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${state.totalAccountsCount} accounts active',
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
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.neonGreen),
                        ),
                      ),
                    ),
                  ),
                  error: (e, _) => const Text('Error loading balance', style: TextStyle(color: AppColors.negative)),
                ),

                const SizedBox(height: 20),

                // Monthly Inflow & Outflow Stats with neon accents
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
                                    color: AppColors.neonGreenSubtle,
                                    shape: BoxShape.circle,
                                    boxShadow: AppColors.neonGlow(blur: 10, color: AppColors.neonGreenGlow),
                                  ),
                                  child: const Icon(Icons.arrow_downward, color: AppColors.neonGreen, size: 14),
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

                // Quick Action Buttons
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
                        color: AppColors.neonGreenSubtle,
                        borderColor: AppColors.neonBorder.withValues(alpha: 0.5),
                        textColor: AppColors.neonGreen,
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
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.15),
                    blurRadius: 8,
                  ),
                ]
              : null,
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
    Color? borderColor,
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
          border: Border.all(color: borderColor ?? AppColors.border),
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
