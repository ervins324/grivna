import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../accounts/providers/account_providers.dart';

class QuickManualEntrySheet extends ConsumerStatefulWidget {
  final String initialType; // 'expense' or 'income'

  const QuickManualEntrySheet({
    super.key,
    this.initialType = 'expense',
  });

  static Future<void> show(BuildContext context, {String initialType = 'expense'}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => QuickManualEntrySheet(initialType: initialType),
    );
  }

  @override
  ConsumerState<QuickManualEntrySheet> createState() => _QuickManualEntrySheetState();
}

class _QuickManualEntrySheetState extends ConsumerState<QuickManualEntrySheet> {
  late String _type;
  String _amountStr = '0';
  String _selectedCategory = 'Groceries';
  String? _selectedAccountId;
  AppCurrency _currency = AppCurrency.uah;
  final TextEditingController _noteController = TextEditingController();

  final List<String> _expenseCategories = [
    'Groceries',
    'Dining Out',
    'Transport',
    'Subscriptions',
    'Housing & Utilities',
    'Tech & Gadgets',
    'Entertainment',
    'Health & Fitness',
    'General',
  ];

  final List<String> _incomeCategories = [
    'Salary',
    'Freelance & Crypto',
    'Investments',
    'Gifts & Bonuses',
    'Other Income',
  ];

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _selectedCategory = _type == 'expense' ? 'Groceries' : 'Salary';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onKeypadTap(String value) {
    setState(() {
      if (value == '.' && _amountStr.contains('.')) return;
      if (_amountStr == '0' && value != '.') {
        _amountStr = value;
      } else {
        if (_amountStr.length < 10) {
          _amountStr += value;
        }
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_amountStr.length > 1) {
        _amountStr = _amountStr.substring(0, _amountStr.length - 1);
      } else {
        _amountStr = '0';
      }
    });
  }

  void _onClear() {
    setState(() {
      _amountStr = '0';
    });
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountStr) ?? 0.0;
    if (amount <= 0) return;

    final accounts = ref.read(accountsStreamProvider).value ?? [];
    if (accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add an account first')),
      );
      return;
    }

    final accountId = _selectedAccountId ?? accounts.first.id;
    final repo = ref.read(accountRepositoryProvider);

    await repo.addTransaction(
      accountId: accountId,
      amount: amount,
      currency: _currency.code,
      type: _type,
      category: _selectedCategory,
      description: _noteController.text.trim().isNotEmpty
          ? _noteController.text.trim()
          : '$_selectedCategory $_type',
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsStreamProvider).value ?? [];
    if (_selectedAccountId == null && accounts.isNotEmpty) {
      _selectedAccountId = accounts.first.id;
      _currency = AppCurrency.fromCode(accounts.first.currency);
    }

    final categories = _type == 'expense' ? _expenseCategories : _incomeCategories;

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
            // Drag Handle
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

            // Top Header: Type Toggle & Currency
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Expense / Income Switcher
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Row(
                    children: [
                      _buildTypeToggleItem('Expense', 'expense', isNegative: true),
                      _buildTypeToggleItem('Income', 'income', isNegative: false),
                    ],
                  ),
                ),

                // Currency Selector
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      _buildCurrencyToggle('UAH', AppCurrency.uah),
                      _buildCurrencyToggle('USD', AppCurrency.usd),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Amount Display
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _type == 'expense' ? '- ' : '+ ',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: _type == 'expense' ? AppColors.negative : AppColors.positive,
                    ),
                  ),
                  Text(
                    _amountStr,
                    style: AppTypography.monoAmount.copyWith(fontSize: 36),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _currency.symbol,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Account Selector & Note field
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedAccountId,
                        dropdownColor: AppColors.surfaceElevated,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                        items: accounts.map((acc) {
                          return DropdownMenuItem<String>(
                            value: acc.id,
                            child: Text(
                              acc.name,
                              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            final acc = accounts.firstWhere((a) => a.id == val);
                            setState(() {
                              _selectedAccountId = val;
                              _currency = AppCurrency.fromCode(acc.currency);
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Note / Description',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                      filled: true,
                      fillColor: AppColors.surfaceElevated,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
              ],
            ),
            const SizedBox(height: 16),

            // Category Chips Grid
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final cat = categories[i];
                  final isSelected = _selectedCategory == cat;
                  return InkWell(
                    onTap: () => setState(() => _selectedCategory = cat),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.textPrimary : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.background : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Custom Keypad (1-9, ., 0, backspace, done)
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      for (var r = 0; r < 3; r++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              for (var c = 1; c <= 3; c++)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: _buildKeypadBtn('${r * 3 + c}'),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: _buildKeypadBtn('.'),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: _buildKeypadBtn('0'),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: _buildKeypadBtn('⌫', isAction: true, onTap: _onBackspace),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Action Buttons Column
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      InkWell(
                        onTap: _onClear,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Center(
                            child: Text(
                              'C',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _submit,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: 112,
                          decoration: BoxDecoration(
                            color: AppColors.textPrimary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Icon(Icons.check, size: 28, color: AppColors.background),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggleItem(String label, String typeVal, {required bool isNegative}) {
    final isSelected = _type == typeVal;
    return InkWell(
      onTap: () {
        setState(() {
          _type = typeVal;
          _selectedCategory = _type == 'expense' ? 'Groceries' : 'Salary';
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isNegative ? AppColors.negative : AppColors.positive)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyToggle(String label, AppCurrency curr) {
    final isSelected = _currency == curr;
    return InkWell(
      onTap: () => setState(() => _currency = curr),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.background : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadBtn(String text, {bool isAction = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () => _onKeypadTap(text),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
