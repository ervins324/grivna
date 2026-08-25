import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../providers/auth_state_provider.dart';

class PinSetupSheet extends ConsumerStatefulWidget {
  const PinSetupSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const PinSetupSheet(),
    );
  }

  @override
  ConsumerState<PinSetupSheet> createState() => _PinSetupSheetState();
}

class _PinSetupSheetState extends ConsumerState<PinSetupSheet> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String _error = '';

  void _onDigit(String d) async {
    if (!_isConfirming) {
      if (_pin.length < 4) {
        setState(() {
          _pin += d;
        });
        if (_pin.length == 4) {
          setState(() {
            _isConfirming = true;
          });
        }
      }
    } else {
      if (_confirmPin.length < 4) {
        setState(() {
          _confirmPin += d;
        });
        if (_confirmPin.length == 4) {
          if (_pin == _confirmPin) {
            await ref.read(authGuardProvider.notifier).setPin(_pin);
            if (mounted) Navigator.pop(context);
          } else {
            setState(() {
              _error = 'PINs do not match. Try again.';
              _pin = '';
              _confirmPin = '';
              _isConfirming = false;
            });
          }
        }
      }
    }
  }

  void _onDelete() {
    setState(() {
      if (_isConfirming) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        } else {
          _isConfirming = false;
        }
      } else {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentCode = _isConfirming ? _confirmPin : _pin;

    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _isConfirming ? 'Confirm PIN' : 'Create 4-digit PIN',
            style: AppTypography.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _isConfirming
                ? 'Re-enter your 4 digits to confirm'
                : 'This will protect your financial data',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 24),

          // Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final isFilled = index < currentCode.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFilled ? AppColors.textPrimary : Colors.transparent,
                  border: Border.all(
                    color: isFilled ? AppColors.textPrimary : AppColors.textTertiary,
                    width: 2,
                  ),
                ),
              );
            }),
          ),

          if (_error.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _error,
              style: const TextStyle(color: AppColors.negative, fontSize: 12),
            ),
          ],

          const SizedBox(height: 24),

          // Keypad
          for (var r = 0; r < 3; r++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var c = 1; c <= 3; c++)
                    _buildKey('${r * 3 + c}'),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 60, height: 60),
              _buildKey('0'),
              InkWell(
                onTap: _onDelete,
                borderRadius: BorderRadius.circular(30),
                child: const SizedBox(
                  width: 60,
                  height: 60,
                  child: Center(
                    child: Icon(Icons.backspace_outlined, color: AppColors.textPrimary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String digit) {
    return InkWell(
      onTap: () => _onDigit(digit),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            digit,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
