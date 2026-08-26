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
            // Glowing Neon Logo
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.neonGreen, width: 1.5),
                boxShadow: AppColors.neonGlow(blur: 24, spread: 2, color: AppColors.neonGreenGlow),
              ),
              child: Center(
                child: Text(
                  '₴',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neonGreen,
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
              authState.isPinSet ? 'Enter PIN to unlock' : 'Default PIN: 0000',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 32),

            // Glowing PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pinLength, (index) {
                final isFilled = index < _enteredPin.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled ? AppColors.neonGreen : Colors.transparent,
                    border: Border.all(
                      color: isFilled ? AppColors.neonGreen : AppColors.textTertiary,
                      width: 2,
                    ),
                    boxShadow: isFilled
                        ? AppColors.neonGlow(blur: 14, color: AppColors.neonGreen)
                        : null,
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

            const SizedBox(height: 16),
            // Quick bypass / unlock button for convenience
            TextButton.icon(
              onPressed: () {
                ref.read(authGuardProvider.notifier).unlockDirectly();
              },
              icon: Icon(Icons.lock_open, size: 16, color: AppColors.neonGreen),
              label: Text(
                'Unlock App',
                style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),

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
                          color: AppColors.neonGreen,
                          onTap: () => ref.read(authGuardProvider.notifier).unlockWithBiometrics(),
                        )
                      else
                        _buildActionButton(
                          Icons.lock_open,
                          color: AppColors.textTertiary,
                          onTap: () => ref.read(authGuardProvider.notifier).unlockDirectly(),
                        ),
                      _buildKeypadButton(
                        '0',
                        onTap: () => _onDigitPressed('0'),
                      ),
                      _buildActionButton(
                        Icons.backspace_outlined,
                        color: AppColors.textSecondary,
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

  Widget _buildActionButton(IconData icon, {required Color color, required VoidCallback onTap}) {
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
          child: Icon(icon, color: color, size: 26),
        ),
      ),
    );
  }
}
