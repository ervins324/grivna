class ApiEndpoints {
  ApiEndpoints._();

  // Monobank API
  static const String monobankBaseUrl = 'https://api.monobank.ua';
  static const String monobankClientInfo = '/personal/client-info';
  static const String monobankStatement = '/personal/statement';
  static const String monobankCurrency = '/bank/currency';

  // Bybit API v5
  static const String bybitBaseUrl = 'https://api.bybit.com';
  static const String bybitWalletBalance = '/v5/account/wallet-balance';
  static const String bybitTransactionLog = '/v5/account/transaction-log';
  static const String bybitCardBalance = '/v5/asset/transfer/query-asset-info';
}
