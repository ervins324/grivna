import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/account_providers.dart';

class AddAccountSheet extends ConsumerStatefulWidget {
  const AddAccountSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const AddAccountSheet(),
    );
  }

  @override
  ConsumerState<AddAccountSheet> createState() => _AddAccountSheetState();
}

class _AddAccountSheetState extends ConsumerState<AddAccountSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Monobank fields
  final _monoTokenController = TextEditingController();
  bool _monoLoading = false;

  // Bybit fields
  final _bybitKeyController = TextEditingController();
  final _bybitSecretController = TextEditingController();
  bool _bybitLoading = false;

  // Cash / Manual fields
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController(text: '0');
  AppCurrency _manualCurrency = AppCurrency.uah;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _monoTokenController.dispose();
    _bybitKeyController.dispose();
    _bybitSecretController.dispose();
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _connectMonobank() async {
    final token = _monoTokenController.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your Monobank personal token')),
      );
      return;
    }

    setState(() => _monoLoading = true);
    try {
      final monoService = ref.read(monobankServiceProvider);
      final clientInfo = await monoService.getClientInfo(token);

      final repo = ref.read(accountRepositoryProvider);
      for (final acc in clientInfo.accounts) {
        if (acc.balance > 0 || acc.type == 'black' || acc.type == 'white') {
          await repo.createAccount(
            name: 'Monobank ${acc.type.toUpperCase()}',
            type: 'monobank',
            balance: acc.balance,
            currency: acc.currency,
            colorHex: 0xFF1E1E1E,
            apiToken: token,
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connected Monobank for ${clientInfo.name}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Monobank connection error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _monoLoading = false);
    }
  }

  Future<void> _connectBybit() async {
    final key = _bybitKeyController.text.trim();
    final secret = _bybitSecretController.text.trim();

    if (key.isEmpty || secret.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Bybit API Key and Secret')),
      );
      return;
    }

    setState(() => _bybitLoading = true);
    try {
      final bybitService = ref.read(bybitServiceProvider);
      final balance = await bybitService.getWalletBalance(apiKey: key, apiSecret: secret);

      final repo = ref.read(accountRepositoryProvider);
      await repo.createAccount(
        name: 'Bybit Card & Wallet',
        type: 'bybit',
        balance: balance.totalEquityUsd,
        currency: 'USD',
        colorHex: 0xFFF7A600,
        apiKey: key,
        apiSecret: secret,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connected Bybit Wallet successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bybit connection error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _bybitLoading = false);
    }
  }

  Future<void> _createManualAccount(String type) async {
    final name = _nameController.text.trim();
    final balance = double.tryParse(_balanceController.text.trim()) ?? 0.0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter account name')),
      );
      return;
    }

    final repo = ref.read(accountRepositoryProvider);
    await repo.createAccount(
      name: name,
      type: type,
      balance: balance,
      currency: _manualCurrency.code,
      colorHex: type == 'cash' ? 0xFF10B981 : 0xFF8B5CF6,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Connect or Add Account', style: AppTypography.titleLarge),
            const SizedBox(height: 16),

            // Tab Selector
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.background,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                tabs: const [
                  Tab(text: 'Monobank'),
                  Tab(text: 'Bybit Card'),
                  Tab(text: 'Cash / Manual'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 260,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Monobank
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Connect via Monobank Personal API token from api.monobank.ua',
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _monoTokenController,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'X-Token',
                          labelStyle: const TextStyle(color: AppColors.textTertiary),
                          filled: true,
                          fillColor: AppColors.surfaceElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _monoLoading ? null : _connectMonobank,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textPrimary,
                          foregroundColor: AppColors.background,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _monoLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background),
                              )
                            : const Text('Connect Monobank (Live UAH)', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),

                  // Tab 2: Bybit Card
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Connect Bybit v5 API with Read-Only permissions for Wallet & Card balance',
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _bybitKeyController,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'API Key',
                          labelStyle: const TextStyle(color: AppColors.textTertiary),
                          filled: true,
                          fillColor: AppColors.surfaceElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _bybitSecretController,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'API Secret (HMAC SHA-256)',
                          labelStyle: const TextStyle(color: AppColors.textTertiary),
                          filled: true,
                          fillColor: AppColors.surfaceElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _bybitLoading ? null : _connectBybit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bybit,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _bybitLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                              )
                            : const Text('Connect Bybit Card (Live USD)', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),

                  // Tab 3: Cash & Custom Manual
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'Account Name (e.g. Cash Wallet, Safe Vault)',
                          labelStyle: const TextStyle(color: AppColors.textTertiary),
                          filled: true,
                          fillColor: AppColors.surfaceElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _balanceController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                              decoration: InputDecoration(
                                labelText: 'Initial Balance',
                                labelStyle: const TextStyle(color: AppColors.textTertiary),
                                filled: true,
                                fillColor: AppColors.surfaceElevated,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.border),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.border),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                _buildManualCurrencyChip('UAH', AppCurrency.uah),
                                _buildManualCurrencyChip('USD', AppCurrency.usd),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _createManualAccount('cash'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.cash,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text('Add Cash', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _createManualAccount('manual'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.surfaceElevated,
                                foregroundColor: AppColors.textPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text('Add Manual', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualCurrencyChip(String label, AppCurrency curr) {
    final isSelected = _manualCurrency == curr;
    return InkWell(
      onTap: () => setState(() => _manualCurrency = curr),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.background : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
