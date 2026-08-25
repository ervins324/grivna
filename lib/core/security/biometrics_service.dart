import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricsService {
  final LocalAuthentication _auth;

  BiometricsService({LocalAuthentication? auth}) : _auth = auth ?? LocalAuthentication();

  Future<bool> isBiometricsAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } on PlatformException {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  Future<bool> authenticate({String localizedReason = 'Authenticate to access grivna'}) async {
    try {
      final isAvailable = await isBiometricsAvailable();
      if (!isAvailable) return false;

      return await _auth.authenticate(
        localizedReason: localizedReason,
      );
    } on PlatformException {
      return false;
    }
  }
}
