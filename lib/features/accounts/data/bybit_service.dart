import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_client.dart';

class BybitWalletBalance {
  final double totalEquityUsd;
  final double totalWalletBalanceUsd;
  final List<BybitCoinBalance> coins;

  BybitWalletBalance({
    required this.totalEquityUsd,
    required this.totalWalletBalanceUsd,
    required this.coins,
  });

  factory BybitWalletBalance.fromJson(Map<String, dynamic> json) {
    final list = (json['result']?['list'] as List<dynamic>?) ?? [];
    if (list.isEmpty) {
      return BybitWalletBalance(
        totalEquityUsd: 0.0,
        totalWalletBalanceUsd: 0.0,
        coins: [],
      );
    }

    final accountData = Map<String, dynamic>.from(list.first as Map);
    final equity = double.tryParse(accountData['totalEquity']?.toString() ?? '0') ?? 0.0;
    final walletBal = double.tryParse(accountData['totalWalletBalance']?.toString() ?? '0') ?? 0.0;

    final coinsList = (accountData['coin'] as List<dynamic>?) ?? [];
    final coins = coinsList
        .map((c) => BybitCoinBalance.fromJson(Map<String, dynamic>.from(c as Map)))
        .toList();

    return BybitWalletBalance(
      totalEquityUsd: equity,
      totalWalletBalanceUsd: walletBal,
      coins: coins,
    );
  }
}

class BybitCoinBalance {
  final String coin;
  final double walletBalance;
  final double usdValue;

  BybitCoinBalance({
    required this.coin,
    required this.walletBalance,
    required this.usdValue,
  });

  factory BybitCoinBalance.fromJson(Map<String, dynamic> json) {
    return BybitCoinBalance(
      coin: json['coin'] as String? ?? '',
      walletBalance: double.tryParse(json['walletBalance']?.toString() ?? '0') ?? 0.0,
      usdValue: double.tryParse(json['usdValue']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class BybitTransaction {
  final String id;
  final String coin;
  final double change;
  final String type;
  final DateTime transactionTime;

  BybitTransaction({
    required this.id,
    required this.coin,
    required this.change,
    required this.type,
    required this.transactionTime,
  });

  factory BybitTransaction.fromJson(Map<String, dynamic> json) {
    final timeMs = int.tryParse(json['transactionTime']?.toString() ?? '0') ?? 0;
    return BybitTransaction(
      id: json['id']?.toString() ?? json['transactionTime']?.toString() ?? '',
      coin: json['currency']?.toString() ?? json['coin']?.toString() ?? 'USDT',
      change: double.tryParse(json['change']?.toString() ?? '0') ?? 0.0,
      type: json['type']?.toString() ?? 'TRANSFER',
      transactionTime: DateTime.fromMillisecondsSinceEpoch(timeMs),
    );
  }
}

class BybitService {
  final Dio _dio;

  BybitService({Dio? dio})
      : _dio = dio ?? DioClient.createDio(baseUrl: ApiEndpoints.bybitBaseUrl);

  String _generateSignature({
    required String timestamp,
    required String apiKey,
    required String apiSecret,
    required String recvWindow,
    required String queryString,
  }) {
    final payload = '$timestamp$apiKey$recvWindow$queryString';
    final hmacSha256 = Hmac(sha256, utf8.encode(apiSecret));
    final digest = hmacSha256.convert(utf8.encode(payload));
    return digest.toString();
  }

  /// Get Wallet Balance (Unified / Card / Funding Account)
  Future<BybitWalletBalance> getWalletBalance({
    required String apiKey,
    required String apiSecret,
    String accountType = 'UNIFIED', // UNIFIED, FUND, etc.
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      const recvWindow = '5000';
      final queryString = 'accountType=$accountType';

      final sign = _generateSignature(
        timestamp: timestamp,
        apiKey: apiKey,
        apiSecret: apiSecret,
        recvWindow: recvWindow,
        queryString: queryString,
      );

      final response = await _dio.get(
        '${ApiEndpoints.bybitWalletBalance}?$queryString',
        options: Options(
          headers: {
            'X-BAPI-API-KEY': apiKey,
            'X-BAPI-TIMESTAMP': timestamp,
            'X-BAPI-SIGN': sign,
            'X-BAPI-RECV-WINDOW': recvWindow,
          },
        ),
      );

      final data = Map<String, dynamic>.from(response.data as Map);
      final retCode = data['retCode'] as int? ?? -1;
      if (retCode != 0) {
        throw Exception(data['retMsg'] ?? 'Bybit API error $retCode');
      }

      return BybitWalletBalance.fromJson(data);
    } catch (e) {
      throw Exception('Failed to connect to Bybit: $e');
    }
  }

  /// Get Recent Transaction Logs
  Future<List<BybitTransaction>> getRecentTransactions({
    required String apiKey,
    required String apiSecret,
    String accountType = 'UNIFIED',
    int limit = 20,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      const recvWindow = '5000';
      final queryString = 'accountType=$accountType&limit=$limit';

      final sign = _generateSignature(
        timestamp: timestamp,
        apiKey: apiKey,
        apiSecret: apiSecret,
        recvWindow: recvWindow,
        queryString: queryString,
      );

      final response = await _dio.get(
        '${ApiEndpoints.bybitTransactionLog}?$queryString',
        options: Options(
          headers: {
            'X-BAPI-API-KEY': apiKey,
            'X-BAPI-TIMESTAMP': timestamp,
            'X-BAPI-SIGN': sign,
            'X-BAPI-RECV-WINDOW': recvWindow,
          },
        ),
      );

      final data = Map<String, dynamic>.from(response.data as Map);
      final list = (data['result']?['list'] as List<dynamic>?) ?? [];
      return list
          .map((item) => BybitTransaction.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
