import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/database/app_database.dart';
import '../../../accounts/providers/account_providers.dart';

class TransferFundsSheet extends ConsumerStatefulWidget {
  final String? initialFromAccountId;

  const TransferFundsSheet({
    super.key,
    this.initialFromAccountId,
  });

  static Future<void> show(BuildContext context, {String? initialFromAccountId}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => TransferFundsSheet(initialFromAccountId: initialFromAccountId),
    );
  }

  @override
  ConsumerState<TransferFundsSheet> createState() => _TransferFundsSheetState();
}

class _TransferFundsSheetState extends ConsumerState<TransferFundsSheet> {
  String? _fromAccountId;
  String? _toAccountId;
  String _amountStr = '0';
  final TextEditingController _noteController = TextEditingController(text: 'Account Transfer');

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
    if (_fromAccountId == null || _toAccountId == null) return;
    if (_fromAccountId == _toAccountId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Source and destination accounts must be different')),
      );
      return;
    }

    final repo = ref.read(accountRepositoryProvider);
    await repo.transferFunds(
      fromAccountId: _fromAccountId!,
      toAccountId: _toAccountId!,
      amount: amount,
      description: _noteController.text.trim().isNotEmpty
          ? _noteController.text.trim()
          : 'Account Transfer',
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsStreamProvider).value ?? [];
    final usdRate = ref.watch(exchangeRateStreamProvider).value ?? 41.50;
    final selectedFilter = ref.watch(selectedAccountFilterProvider);

    if (_fromAccountId == null && accounts.isNotEmpty) {
      final preferredFrom = widget.initialFromAccountId ?? selectedFilter;
      if (preferredFrom != null && accounts.any((a) => a.id == preferredFrom)) {
        _fromAccountId = preferredFrom;
      } else {
        _fromAccountId = accounts[0].id;
      }

      if (_toAccountId == null && accounts.length > 1) {
        _toAccountId = accounts.firstWhere((a) => a.id != _fromAccountId).id;
      }
    }

    AccountsTableData? fromAcc;
    AccountsTableData? toAcc;

    if (_fromAccountId != null) {
      fromAcc = accounts.where((a) => a.id == _fromAccountId).firstOrNull;
    }
    if (_toAccountId != null) {
      toAcc = accounts.where((a) => a.id == _toAccountId).firstOrNull;
    }

    final amount = double.tryParse(_amountStr) ?? 0.0;
    double estimatedDestination = amount;
    if (fromAcc != null && toAcc != null) {
      if (fromAcc.currency == 'UAH' && toAcc.currency == 'USD') {
        estimatedDestination = amount / usdRate;
      } else if (fromAcc.currency == 'USD' && toAcc.currency == 'UAH') {
        estimatedDestination = amount * usdRate;
      }
    }

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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.transfer.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.swap_horiz, color: AppColors.transfer, size: 20),
                ),
                const SizedBox(width: 12),
                Text('Transfer Between Accounts', style: AppTypography.titleMedium),
              ],
            ),
            const SizedBox(height: 20),

            // From / To Account Selectors
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  // FROM
                  Row(
                    children: [
                      SizedBox(
                        width: 44,
                        child: Text('From', style: AppTypography.bodySmall),
                      ),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _fromAccountId,
                            dropdownColor: AppColors.surfaceElevated,
                            isExpanded: true,
                            items: accounts.map((acc) {
                              return DropdownMenuItem<String>(
                                value: acc.id,
                                child: Text(
                                  '${acc.name} (${acc.currency}) - ${acc.balance.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                ),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => _fromAccountId = v),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.borderSubtle, height: 16),
                  // TO
                  Row(
                    children: [
                      SizedBox(
                        width: 44,
                        child: Text('To', style: AppTypography.bodySmall),
                      ),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _toAccountId,
                            dropdownColor: AppColors.surfaceElevated,
                            isExpanded: true,
                            items: accounts.map((acc) {
                              return DropdownMenuItem<String>(
                                value: acc.id,
                                child: Text(
                                  '${acc.name} (${acc.currency}) - ${acc.balance.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                ),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => _toAccountId = v),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Amount Box + Conversion Preview
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _amountStr,
                        style: AppTypography.monoAmount.copyWith(fontSize: 32),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        fromAcc != null ? fromAcc.currency : 'UAH',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  if (fromAcc != null && toAcc != null && fromAcc.currency != toAcc.currency) ...[
                    const SizedBox(height: 4),
                    Text(
                      '≈ ${estimatedDestination.toStringAsFixed(2)} ${toAcc.currency} (Rate: $usdRate)',
                      style: AppTypography.monoSmall.copyWith(
                        fontSize: 12,
                        color: AppColors.transfer,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Keypad
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
                            color: AppColors.transfer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Icon(Icons.arrow_forward, size: 28, color: Colors.white),
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
