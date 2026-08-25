import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../accounts/providers/account_providers.dart';

class AddSubscriptionSheet extends ConsumerStatefulWidget {
  const AddSubscriptionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const AddSubscriptionSheet(),
    );
  }

  @override
  ConsumerState<AddSubscriptionSheet> createState() => _AddSubscriptionSheetState();
}

class _AddSubscriptionSheetState extends ConsumerState<AddSubscriptionSheet> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _cycle = 'monthly'; // 'monthly', 'yearly', 'weekly'
  AppCurrency _currency = AppCurrency.usd;
  final String _category = 'Subscriptions';
  DateTime _nextBillingDate = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    if (name.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide subscription name and amount')),
      );
      return;
    }

    final repo = ref.read(accountRepositoryProvider);
    await repo.addSubscription(
      name: name,
      amount: amount,
      currency: _currency.code,
      billingCycle: _cycle,
      cycleDays: _cycle == 'yearly' ? 365 : (_cycle == 'weekly' ? 7 : 30),
      category: _category,
      startDate: DateTime.now(),
      nextBillingDate: _nextBillingDate,
      colorHex: 0xFFFAFAFA,
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
            Text('Add Recurring Subscription', style: AppTypography.titleLarge),
            const SizedBox(height: 16),

            // Subscription Name
            TextField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Service Name (e.g. Netflix, ChatGPT)',
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
            const SizedBox(height: 12),

            // Amount & Currency Toggle
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Price',
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
                      _buildCurrencyOption('USD', AppCurrency.usd),
                      _buildCurrencyOption('UAH', AppCurrency.uah),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Billing Cycle Selector
            Text('Billing Frequency', style: AppTypography.bodySmall),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildCycleOption('Monthly', 'monthly'),
                const SizedBox(width: 8),
                _buildCycleOption('Yearly', 'yearly'),
                const SizedBox(width: 8),
                _buildCycleOption('Weekly', 'weekly'),
              ],
            ),
            const SizedBox(height: 16),

            // Next Billing Date Picker
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _nextBillingDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 730)),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: AppColors.textPrimary,
                          surface: AppColors.surface,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() => _nextBillingDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Next Due Date', style: AppTypography.bodyMedium),
                    Text(
                      '${_nextBillingDate.day}/${_nextBillingDate.month}/${_nextBillingDate.year}',
                      style: AppTypography.monoSmall.copyWith(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Save Subscription',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyOption(String label, AppCurrency curr) {
    final isSelected = _currency == curr;
    return InkWell(
      onTap: () => setState(() => _currency = curr),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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

  Widget _buildCycleOption(String label, String value) {
    final isSelected = _cycle == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _cycle = value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.textPrimary : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.background : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
