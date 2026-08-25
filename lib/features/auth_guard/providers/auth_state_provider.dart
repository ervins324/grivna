import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../accounts/providers/account_providers.dart';

class AuthGuardState {
  final bool isLocked;
  final bool isPinSet;
  final bool isPinEnabled;
  final bool isBiometricsEnabled;
  final bool isBiometricsAvailable;
  final String errorMessage;

  AuthGuardState({
    required this.isLocked,
    required this.isPinSet,
    required this.isPinEnabled,
    required this.isBiometricsEnabled,
    required this.isBiometricsAvailable,
    this.errorMessage = '',
  });

  AuthGuardState copyWith({
    bool? isLocked,
    bool? isPinSet,
    bool? isPinEnabled,
    bool? isBiometricsEnabled,
    bool? isBiometricsAvailable,
    String? errorMessage,
  }) {
    return AuthGuardState(
      isLocked: isLocked ?? this.isLocked,
      isPinSet: isPinSet ?? this.isPinSet,
      isPinEnabled: isPinEnabled ?? this.isPinEnabled,
      isBiometricsEnabled: isBiometricsEnabled ?? this.isBiometricsEnabled,
      isBiometricsAvailable: isBiometricsAvailable ?? this.isBiometricsAvailable,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthGuardNotifier extends Notifier<AuthGuardState> {
  @override
  AuthGuardState build() {
    Future.microtask(() => initialize());
    return AuthGuardState(
      isLocked: false,
      isPinSet: false,
      isPinEnabled: false,
      isBiometricsEnabled: false,
      isBiometricsAvailable: false,
    );
  }

  Future<void> initialize() async {
    try {
      final storage = ref.read(secureStorageServiceProvider);
      final bio = ref.read(biometricsServiceProvider);

      final isPinSet = await storage.isPinSet();
      final isPinEnabled = await storage.isPinEnabled();
      final isBiometricsEnabled = await storage.isBiometricsEnabled();
      final isBiometricsAvailable = await bio.isBiometricsAvailable();

      final shouldLock = isPinSet && isPinEnabled;

      state = state.copyWith(
        isLocked: shouldLock,
        isPinSet: isPinSet,
        isPinEnabled: isPinEnabled,
        isBiometricsEnabled: isBiometricsEnabled,
        isBiometricsAvailable: isBiometricsAvailable,
      );

      if (shouldLock && isBiometricsEnabled && isBiometricsAvailable) {
        await unlockWithBiometrics();
      }
    } catch (_) {
      // In case of error, do not block the user
      state = state.copyWith(isLocked: false);
    }
  }

  Future<bool> unlockWithPin(String pin) async {
    final storage = ref.read(secureStorageServiceProvider);
    final isValid = await storage.verifyPin(pin);

    if (isValid) {
      state = state.copyWith(isLocked: false, errorMessage: '');
      return true;
    } else {
      state = state.copyWith(errorMessage: 'Incorrect PIN. Try 0000 or tap Unlock.');
      return false;
    }
  }

  void unlockDirectly() {
    state = state.copyWith(isLocked: false, errorMessage: '');
  }

  Future<bool> unlockWithBiometrics() async {
    try {
      final bio = ref.read(biometricsServiceProvider);
      final success = await bio.authenticate(localizedReason: 'Unlock grivna');
      if (success) {
        state = state.copyWith(isLocked: false, errorMessage: '');
        return true;
      }
    } catch (_) {}
    return false;
  }

  void lockApp() {
    if (state.isPinSet && state.isPinEnabled) {
      state = state.copyWith(isLocked: true, errorMessage: '');
    }
  }

  Future<void> setPin(String newPin) async {
    final storage = ref.read(secureStorageServiceProvider);
    await storage.savePin(newPin);
    state = state.copyWith(
      isPinSet: true,
      isPinEnabled: true,
    );
  }

  Future<void> togglePinEnabled(bool enabled) async {
    final storage = ref.read(secureStorageServiceProvider);
    await storage.setPinEnabled(enabled);
    state = state.copyWith(isPinEnabled: enabled);
  }

  Future<void> toggleBiometrics(bool enabled) async {
    final storage = ref.read(secureStorageServiceProvider);
    await storage.setBiometricsEnabled(enabled);
    state = state.copyWith(isBiometricsEnabled: enabled);
  }

  Future<void> removePin() async {
    final storage = ref.read(secureStorageServiceProvider);
    await storage.removePin();
    state = state.copyWith(
      isLocked: false,
      isPinSet: false,
      isPinEnabled: false,
    );
  }
}

final authGuardProvider =
    NotifierProvider<AuthGuardNotifier, AuthGuardState>(AuthGuardNotifier.new);
