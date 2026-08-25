import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  static const _pinHashKey = 'user_pin_hash';
  static const _pinEnabledKey = 'user_pin_enabled';
  static const _biometricsEnabledKey = 'user_biometrics_enabled';
  static const _keyPrefix = 'api_key_';

  // Hashing helper
  String _hashPin(String pin) {
    return sha256.convert(utf8.encode('grivna_salt_$pin')).toString();
  }

  // PIN Management
  Future<void> savePin(String pin) async {
    final hashed = _hashPin(pin);
    await _storage.write(key: _pinHashKey, value: hashed);
    await _storage.write(key: _pinEnabledKey, value: 'true');
  }

  Future<bool> verifyPin(String pin) async {
    final storedHash = await _storage.read(key: _pinHashKey);
    if (storedHash == null) return false;
    return storedHash == _hashPin(pin);
  }

  Future<bool> isPinSet() async {
    final hash = await _storage.read(key: _pinHashKey);
    return hash != null && hash.isNotEmpty;
  }

  Future<bool> isPinEnabled() async {
    final enabled = await _storage.read(key: _pinEnabledKey);
    return enabled == 'true';
  }

  Future<void> setPinEnabled(bool enabled) async {
    await _storage.write(key: _pinEnabledKey, value: enabled.toString());
  }

  Future<void> removePin() async {
    await _storage.delete(key: _pinHashKey);
    await _storage.delete(key: _pinEnabledKey);
  }

  // Biometrics Preference
  Future<bool> isBiometricsEnabled() async {
    final val = await _storage.read(key: _biometricsEnabledKey);
    return val == 'true';
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    await _storage.write(key: _biometricsEnabledKey, value: enabled.toString());
  }

  // API Tokens & Secrets
  Future<void> saveSecret(String id, String secret) async {
    await _storage.write(key: '$_keyPrefix$id', value: secret);
  }

  Future<String?> getSecret(String id) async {
    return await _storage.read(key: '$_keyPrefix$id');
  }

  Future<void> deleteSecret(String id) async {
    await _storage.delete(key: '$_keyPrefix$id');
  }
}
