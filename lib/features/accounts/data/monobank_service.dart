import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_client.dart';

class MonobankAccountInfo {
  final String id;
  final String sendId;
  final double balance;
  final double creditLimit;
  final String currency; // 'UAH', 'USD', 'EUR'
  final String type; // 'black', 'white', 'platinum', 'fop', etc.
  final String maskedPan;
  final String iban;

  MonobankAccountInfo({
    required this.id,
    required this.sendId,
    required this.balance,
    required this.creditLimit,
    required this.currency,
    required this.type,
    required this.maskedPan,
    required this.iban,
  });

  factory MonobankAccountInfo.fromJson(Map<String, dynamic> json) {
    final currencyCode = json['currencyCode'] as int? ?? 980;
    String curr = 'UAH';
    if (currencyCode == 840) curr = 'USD';
    if (currencyCode == 978) curr = 'EUR';

    // Monobank amounts are in cents (kopiiky)
    final balanceRaw = (json['balance'] as num? ?? 0).toDouble();
    final creditRaw = (json['creditLimit'] as num? ?? 0).toDouble();

    final maskedPanList = (json['maskedPan'] as List<dynamic>?) ?? [];
    final pan = maskedPanList.isNotEmpty ? maskedPanList.first.toString() : '';

    return MonobankAccountInfo(
      id: json['id'] as String? ?? '',
      sendId: json['sendId'] as String? ?? '',
      balance: balanceRaw / 100.0,
      creditLimit: creditRaw / 100.0,
      currency: curr,
      type: json['type'] as String? ?? 'black',
      maskedPan: pan,
      iban: json['iban'] as String? ?? '',
    );
  }
}

class MonobankClientInfo {
  final String clientId;
  final String name;
  final List<MonobankAccountInfo> accounts;

  MonobankClientInfo({
    required this.clientId,
    required this.name,
    required this.accounts,
  });

  factory MonobankClientInfo.fromJson(Map<String, dynamic> json) {
    final accountsJson = (json['accounts'] as List<dynamic>?) ?? [];
    return MonobankClientInfo(
      clientId: json['clientId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      accounts: accountsJson
          .map((e) => MonobankAccountInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MonobankStatementItem {
  final String id;
  final int time;
  final String description;
  final int mcc;
  final double amount;
  final double operationAmount;
  final int currencyCode;
  final double balance;
  final double cashbackAmount;

  MonobankStatementItem({
    required this.id,
    required this.time,
    required this.description,
    required this.mcc,
    required this.amount,
    required this.operationAmount,
    required this.currencyCode,
    required this.balance,
    required this.cashbackAmount,
  });

  factory MonobankStatementItem.fromJson(Map<String, dynamic> json) {
    return MonobankStatementItem(
      id: json['id'] as String? ?? '',
      time: json['time'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      mcc: json['mcc'] as int? ?? 0,
      amount: ((json['amount'] as num? ?? 0) / 100.0),
      operationAmount: ((json['operationAmount'] as num? ?? 0) / 100.0),
      currencyCode: json['currencyCode'] as int? ?? 980,
      balance: ((json['balance'] as num? ?? 0) / 100.0),
      cashbackAmount: ((json['cashbackAmount'] as num? ?? 0) / 100.0),
    );
  }
}

class MonobankService {
  final Dio _dio;

  MonobankService({Dio? dio})
      : _dio = dio ?? DioClient.createDio(baseUrl: ApiEndpoints.monobankBaseUrl);

  /// Fetch client info and account list with personal token
  Future<MonobankClientInfo> getClientInfo(String apiToken) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.monobankClientInfo,
        options: Options(
          headers: {'X-Token': apiToken},
        ),
      );
      return MonobankClientInfo.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to connect to Monobank: $e');
    }
  }

  /// Fetch transactions statement for a given account and time range
  Future<List<MonobankStatementItem>> getStatement({
    required String apiToken,
    required String accountId,
    required DateTime from,
    DateTime? to,
  }) async {
    try {
      final fromSeconds = from.millisecondsSinceEpoch ~/ 1000;
      final toSeconds = (to ?? DateTime.now()).millisecondsSinceEpoch ~/ 1000;
      final endpoint = '${ApiEndpoints.monobankStatement}/$accountId/$fromSeconds/$toSeconds';

      final response = await _dio.get(
        endpoint,
        options: Options(
          headers: {'X-Token': apiToken},
        ),
      );

      final list = (response.data as List<dynamic>?) ?? [];
      return list
          .map((item) => MonobankStatementItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch Monobank statement: $e');
    }
  }

  /// Fetch public currency rates (no token required)
  Future<List<Map<String, dynamic>>> getPublicCurrencies() async {
    try {
      final response = await _dio.get(ApiEndpoints.monobankCurrency);
      final list = (response.data as List<dynamic>?) ?? [];
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }
}
