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

class _AddAccountSheetState extends ConsumerState<AddAccountSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // General in-sheet error/status banner
  String? _errorMessage;
  String? _successMessage;

  // Monobank fields & state
  final _monoTokenController = TextEditingController();
  String? _monoError;
  bool _monoLoading = false;

  // Bybit fields & state
  final _bybitKeyController = TextEditingController();
  final _bybitSecretController = TextEditingController();
  String? _bybitKeyError;
  String? _bybitSecretError;
  bool _bybitLoading = false;

  // Cash / Manual fields & state
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController(text: '0');
  String? _nameError;
  AppCurrency _manualCurrency = AppCurrency.uah;
  bool _manualLoading = false;

  final List<String> _manualPresets = [
    'Cash Wallet',
    'Emergency Vault',
    'Physical Safe',
    'Crypto Stash',
    'Revolut',
    'Wise',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          _errorMessage = null;
          _successMessage = null;
        });
      }
    });
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
    setState(() {
      _errorMessage = null;
      _monoError = null;
    });

    if (token.isEmpty) {
      setState(() {
        _monoError = 'Please enter your Monobank personal token';
      });
      return;
    }

    setState(() => _monoLoading = true);
    try {
      final monoService = ref.read(monobankServiceProvider);
      final clientInfo = await monoService.getClientInfo(token);

      final repo = ref.read(accountRepositoryProvider);
      int addedCount = 0;
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
          addedCount++;
        }
      }

      if (addedCount == 0 && clientInfo.accounts.isNotEmpty) {
        final acc = clientInfo.accounts.first;
        await repo.createAccount(
          name: 'Monobank ${acc.type.toUpperCase()}',
          type: 'monobank',
          balance: acc.balance,
          currency: acc.currency,
          colorHex: 0xFF1E1E1E,
          apiToken: token,
        );
      }

      if (mounted) {
        setState(() {
          _successMessage = 'Connected Monobank for ${clientInfo.name}';
        });
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Monobank connection error: ${e.toString().replaceAll('Exception: ', '')}';
        });
      }
    } finally {
      if (mounted) setState(() => _monoLoading = false);
    }
  }

  Future<void> _createDemoMonobank() async {
    setState(() {
      _errorMessage = null;
      _monoLoading = true;
    });
    try {
      final repo = ref.read(accountRepositoryProvider);
      await repo.createAccount(
        name: 'Monobank Black (Live UAH)',
        type: 'monobank',
        balance: 32500.00,
        currency: 'UAH',
        colorHex: 0xFF1E1E1E,
      );
      if (mounted) {
        setState(() => _successMessage = 'Created Monobank Demo Account');
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Failed to create demo account: $e');
      }
    } finally {
      if (mounted) setState(() => _monoLoading = false);
    }
  }

  Future<void> _connectBybit() async {
    final key = _bybitKeyController.text.trim();
    final secret = _bybitSecretController.text.trim();

    setState(() {
      _errorMessage = null;
      _bybitKeyError = null;
      _bybitSecretError = null;
    });

    bool hasError = false;
    if (key.isEmpty) {
      _bybitKeyError = 'Please enter Bybit API Key';
      hasError = true;
    }
    if (secret.isEmpty) {
      _bybitSecretError = 'Please enter Bybit API Secret';
      hasError = true;
    }

    if (hasError) {
      setState(() {});
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
        setState(() {
          _successMessage = 'Connected Bybit Wallet successfully';
        });
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Bybit connection error: ${e.toString().replaceAll('Exception: ', '')}';
        });
      }
    } finally {
      if (mounted) setState(() => _bybitLoading = false);
    }
  }

  Future<void> _createDemoBybit() async {
    setState(() {
      _errorMessage = null;
      _bybitLoading = true;
    });
    try {
      final repo = ref.read(accountRepositoryProvider);
      await repo.createAccount(
        name: 'Bybit Card USD (Demo)',
        type: 'bybit',
        balance: 2450.00,
        currency: 'USD',
        colorHex: 0xFFF7A600,
      );
      if (mounted) {
        setState(() => _successMessage = 'Created Bybit Demo Account');
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Failed to create demo account: $e');
      }
    } finally {
      if (mounted) setState(() => _bybitLoading = false);
    }
  }

  Future<void> _createManualAccount(String type) async {
    final name = _nameController.text.trim();
    final balance = double.tryParse(_balanceController.text.trim().replaceAll(',', '.')) ?? 0.0;

    setState(() {
      _errorMessage = null;
      _nameError = null;
    });

    if (name.isEmpty) {
      setState(() {
        _nameError = 'Please enter an account name';
      });
      return;
    }

    setState(() => _manualLoading = true);
    try {
      final repo = ref.read(accountRepositoryProvider);
      await repo.createAccount(
        name: name,
        type: type,
        balance: balance,
        currency: _manualCurrency.code,
        colorHex: type == 'cash' ? 0xFF10B981 : 0xFF8B5CF6,
      );

      if (mounted) {
        setState(() {
          _successMessage = 'Account "$name" created successfully';
        });
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to create account: $e';
        });
      }
    } finally {
      if (mounted) setState(() => _manualLoading = false);
    }
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
            const SizedBox(height: 16),

            // In-sheet Error / Success Banners
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.negative.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.negative.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, size: 18, color: AppColors.negative),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 12, color: AppColors.negative, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

            if (_successMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.positive.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.positive.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 18, color: AppColors.positive),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: const TextStyle(fontSize: 12, color: AppColors.positive, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

            // Content Area based on selected Tab
            AnimatedBuilder(
              animation: _tabController,
              builder: (context, _) {
                switch (_tabController.index) {
                  case 0:
                    return _buildMonobankTab();
                  case 1:
                    return _buildBybitTab();
                  case 2:
                  default:
                    return _buildManualTab();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonobankTab() {
    return Column(
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
            errorText: _monoError,
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
          onChanged: (_) {
            if (_monoError != null) setState(() => _monoError = null);
          },
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
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
                    : const Text('Connect Live Monobank', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _monoLoading ? null : _createDemoMonobank,
          icon: const Icon(Icons.flash_on, size: 16, color: AppColors.neonGreen),
          label: const Text('Add Demo Monobank Account (Fast Test)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textPrimary)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.border),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }

  Widget _buildBybitTab() {
    return Column(
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
            errorText: _bybitKeyError,
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
          onChanged: (_) {
            if (_bybitKeyError != null) setState(() => _bybitKeyError = null);
          },
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _bybitSecretController,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'API Secret (HMAC SHA-256)',
            errorText: _bybitSecretError,
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
          onChanged: (_) {
            if (_bybitSecretError != null) setState(() => _bybitSecretError = null);
          },
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
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
                    : const Text('Connect Live Bybit Card', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _bybitLoading ? null : _createDemoBybit,
          icon: const Icon(Icons.flash_on, size: 16, color: AppColors.bybit),
          label: const Text('Add Demo Bybit USD Card (Fast Test)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textPrimary)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.border),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }

  Widget _buildManualTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Quick Presets
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _manualPresets.length,
            separatorBuilder: (_, _) => const SizedBox(width: 6),
            itemBuilder: (context, i) {
              final preset = _manualPresets[i];
              return ActionChip(
                label: Text(preset, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                backgroundColor: AppColors.surfaceElevated,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                onPressed: () {
                  setState(() {
                    _nameController.text = preset;
                    _nameError = null;
                  });
                },
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _nameController,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            labelText: 'Account Name (e.g. Cash Wallet, Safe Vault)',
            errorText: _nameError,
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
          onChanged: (_) {
            if (_nameError != null) setState(() => _nameError = null);
          },
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
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _manualLoading ? null : () => _createManualAccount('cash'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cash,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _manualLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Text('Add Cash', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: _manualLoading ? null : () => _createManualAccount('manual'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceElevated,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _manualLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary),
                      )
                    : const Text('Add Manual', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ],
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

