import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../accounts/presentation/add_account_sheet.dart';
import '../../accounts/providers/account_providers.dart';
import '../../auth_guard/presentation/pin_setup_sheet.dart';
import '../../auth_guard/providers/auth_state_provider.dart';
import '../providers/personalisation_provider.dart';
import '../providers/settings_provider.dart';
import 'personalisation_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseCurrency = ref.watch(selectedBaseCurrencyProvider);
    final authState = ref.watch(authGuardProvider);
    final syncState = ref.watch(syncNotifierProvider);
    final accounts = ref.watch(accountsStreamProvider).value ?? [];
    final usdRate = ref.watch(exchangeRateStreamProvider).value ?? 41.50;
    final personalisation = ref.watch(personalisationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: Text('Settings', style: AppTypography.titleLarge),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Section: Base Currency
            _buildSectionHeader('DEFAULT DISPLAY CURRENCY'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildCurrencySelectorOption(
                      ref,
                      currency: AppCurrency.uah,
                      title: 'Ukrainian Hryvnia (UAH)',
                      symbol: '₴',
                      isSelected: baseCurrency == AppCurrency.uah,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildCurrencySelectorOption(
                      ref,
                      currency: AppCurrency.usd,
                      title: 'US Dollar (USD)',
                      symbol: '\$',
                      isSelected: baseCurrency == AppCurrency.usd,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section: Personalisation
            _buildSectionHeader('PERSONALISATION'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Theme & Typography', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(
                      'Font: ${personalisation.fontFamily}',
                      style: AppTypography.bodySmall,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: personalisation.accentColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.palette_outlined, color: personalisation.accentColor, size: 20),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: personalisation.accentColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: personalisation.accentColor.withValues(alpha: 0.4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
                      ],
                    ),
                    onTap: () => PersonalisationSheet.show(context),
                  ),
                  const Divider(color: AppColors.borderSubtle, height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const Text(
                          'Quick Accent:',
                          style: TextStyle(fontSize: 12, color: AppColors.textTertiary, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: PersonalisationNotifier.accentPresets.take(6).map((preset) {
                                final isSelected = personalisation.accentColor.toARGB32() == preset.color.toARGB32();
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: InkWell(
                                    onTap: () {
                                      ref.read(personalisationProvider.notifier).setAccentColor(preset.color);
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        color: preset.color,
                                        shape: BoxShape.circle,
                                        border: isSelected
                                            ? Border.all(color: Colors.white, width: 2)
                                            : Border.all(color: AppColors.border, width: 1),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: preset.color.withValues(alpha: 0.4),
                                                  blurRadius: 8,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: isSelected
                                          ? const Icon(Icons.check, size: 14, color: Colors.black)
                                          : null,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section: Security & App Guard
            _buildSectionHeader('SECURITY & APP GUARD'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  // PIN Lock Toggle & Setup
                  ListTile(
                    title: const Text('PIN Screen Guard', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(
                      authState.isPinSet ? '4-digit PIN configured' : 'Set up PIN to protect your balance',
                      style: AppTypography.bodySmall,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.pin_outlined, color: AppColors.textPrimary, size: 20),
                    ),
                    trailing: authState.isPinSet
                        ? Switch(
                            value: authState.isPinEnabled,
                            activeThumbColor: AppColors.textPrimary,
                            onChanged: (val) {
                              ref.read(authGuardProvider.notifier).togglePinEnabled(val);
                            },
                          )
                        : TextButton(
                            onPressed: () => PinSetupSheet.show(context),
                            child: const Text('Set PIN', style: TextStyle(color: AppColors.textPrimary)),
                          ),
                  ),
                  if (authState.isPinSet) ...[
                    const Divider(color: AppColors.borderSubtle, height: 1),
                    ListTile(
                      title: const Text('Change PIN', style: TextStyle(fontSize: 13)),
                      leading: const SizedBox(width: 36),
                      trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                      onTap: () => PinSetupSheet.show(context),
                    ),
                  ],
                  if (authState.isBiometricsAvailable) ...[
                    const Divider(color: AppColors.borderSubtle, height: 1),
                    ListTile(
                      title: const Text('Biometric Authentication', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('Unlock instantly with Fingerprint / FaceID', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.fingerprint, color: AppColors.textPrimary, size: 20),
                      ),
                      trailing: Switch(
                        value: authState.isBiometricsEnabled,
                        activeThumbColor: AppColors.textPrimary,
                        onChanged: (val) {
                          ref.read(authGuardProvider.notifier).toggleBiometrics(val);
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section: Connected Accounts
            _buildSectionHeader('CONNECTED ACCOUNTS (${accounts.length})'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < accounts.length; i++) ...[
                    if (i > 0) const Divider(color: AppColors.borderSubtle, height: 1),
                    ListTile(
                      title: Text(accounts[i].name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text(
                        '${accounts[i].type.toUpperCase()} • ${accounts[i].balance.toStringAsFixed(2)} ${accounts[i].currency}',
                        style: AppTypography.bodySmall,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          accounts[i].type == 'monobank'
                              ? Icons.credit_card
                              : (accounts[i].type == 'bybit'
                                  ? Icons.currency_bitcoin
                                  : (accounts[i].type == 'cash' ? Icons.payments_outlined : Icons.lock_outline)),
                          color: AppColors.textPrimary,
                          size: 18,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.negative),
                        onPressed: () {
                          ref.read(accountRepositoryProvider).deleteAccount(accounts[i].id);
                        },
                      ),
                    ),
                  ],
                  const Divider(color: AppColors.borderSubtle, height: 1),
                  ListTile(
                    title: const Text('Add / Connect Account', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.transfer)),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.transfer.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: AppColors.transfer, size: 18),
                    ),
                    onTap: () => AddAccountSheet.show(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section: Data & Sync Controls
            _buildSectionHeader('DATA & SYNCHRONIZATION'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Sync Remote Accounts & Rates', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(
                      syncState.lastSyncMessage ?? 'Live USD rate: $usdRate UAH',
                      style: AppTypography.bodySmall,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.sync, color: AppColors.textPrimary, size: 20),
                    ),
                    trailing: syncState.isSyncing
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary))
                        : TextButton(
                            onPressed: () => ref.read(syncNotifierProvider.notifier).syncAll(),
                            child: const Text('Sync Now', style: TextStyle(color: AppColors.textPrimary)),
                          ),
                  ),
                  const Divider(color: AppColors.borderSubtle, height: 1),
                  ListTile(
                    title: const Text('Seed Realistic Demo Dataset', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Populate Monobank, Bybit, Cash & 6-month historical logs', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.auto_awesome, color: AppColors.positive, size: 20),
                    ),
                    onTap: () async {
                      await ref.read(syncNotifierProvider.notifier).seedDemo();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Loaded demo accounts & historical transactions')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section: Danger Zone / Delete All Data
            _buildSectionHeader('DANGER ZONE'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.negative.withValues(alpha: 0.3)),
              ),
              child: ListTile(
                title: const Text('Delete All Data', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.negative)),
                subtitle: const Text('Wipe all accounts, transactions, subscriptions, and credentials', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.negative.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_forever, color: AppColors.negative, size: 20),
                ),
                onTap: () => _confirmDeleteAllData(context, ref),
              ),
            ),

            const SizedBox(height: 24),

            // Architecture & Offline Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ENGINEERED FOR PRIVACY & SPEED',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'grivna is 100% offline-first. All accounts, transactions, and subscriptions are stored locally in an encrypted Drift SQLite database with secure hardware keychain key storage.',
                    style: TextStyle(fontSize: 11, color: AppColors.textTertiary, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Text(
        title,
        style: AppTypography.bodySmall.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildCurrencySelectorOption(
    WidgetRef ref, {
    required AppCurrency currency,
    required String title,
    required String symbol,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        ref.read(selectedBaseCurrencyProvider.notifier).setCurrency(currency);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              symbol,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.background : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              currency.code,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.background : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAllData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.negative, size: 24),
              SizedBox(width: 10),
              Text('Delete All Data?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'This will permanently delete all accounts, transactions, subscriptions, and stored API credentials from your device.\n\nThis action cannot be undone.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogCtx);
                await ref.read(accountRepositoryProvider).clearAllData();
                ref.read(selectedAccountFilterProvider.notifier).setFilter(null);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All data has been deleted from the app'),
                      backgroundColor: AppColors.negative,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.negative,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Delete Everything'),
            ),
          ],
        );
      },
    );
  }
}
