import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../providers/auth_state_provider.dart';

class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  String _enteredPin = '';
  static const int _pinLength = 4;

  void _onDigitPressed(String digit) async {
    if (_enteredPin.length < _pinLength) {
      setState(() {
        _enteredPin += digit;
      });

      if (_enteredPin.length == _pinLength) {
        final success = await ref.read(authGuardProvider.notifier).unlockWithPin(_enteredPin);
        if (!success) {
          setState(() {
            _enteredPin = '';
          });
        }
      }
    }
  }

  void _onDelete() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authGuardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Logo / App Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Text(
                  '₴',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'grivna',
              style: AppTypography.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter PIN to unlock',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 32),

            // PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pinLength, (index) {
                final isFilled = index < _enteredPin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
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

            if (authState.errorMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                authState.errorMessage,
                style: const TextStyle(color: AppColors.negative, fontSize: 13),
              ),
            ],

            const Spacer(flex: 2),

            // Custom Keypad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  for (var row = 0; row < 3; row++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (var col = 1; col <= 3; col++)
                            _buildKeypadButton(
                              '${row * 3 + col}',
                              onTap: () => _onDigitPressed('${row * 3 + col}'),
                            ),
                        ],
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Biometric button
                      if (authState.isBiometricsAvailable)
                        _buildActionButton(
                          Icons.fingerprint,
                          onTap: () => ref.read(authGuardProvider.notifier).unlockWithBiometrics(),
                        )
                      else
                        const SizedBox(width: 72, height: 72),
                      _buildKeypadButton(
                        '0',
                        onTap: () => _onDigitPressed('0'),
                      ),
                      _buildActionButton(
                        Icons.backspace_outlined,
                        onTap: _onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String digit, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Center(
          child: Text(
            digit,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Center(
          child: Icon(icon, color: AppColors.textPrimary, size: 26),
        ),
      ),
    );
  }
}
