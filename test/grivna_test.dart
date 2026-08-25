import 'package:flutter_test/flutter_test.dart';
import 'package:grivna/core/utils/currency_formatter.dart';
import 'package:grivna/core/utils/date_time_utils.dart';
import 'package:grivna/features/accounts/data/bybit_service.dart';
import 'package:grivna/features/accounts/data/monobank_service.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('Formats UAH currency correctly', () {
      final formatted = CurrencyFormatter.format(1450.50, currency: AppCurrency.uah);
      expect(formatted, '1,450.50 ₴');
    });

    test('Formats USD currency correctly', () {
      final formatted = CurrencyFormatter.format(1450.50, currency: AppCurrency.usd);
      expect(formatted, '\$ 1,450.50');
    });

    test('Converts UAH to USD correctly with exchange rate', () {
      final usd = CurrencyFormatter.convert(
        amount: 4150.0,
        from: AppCurrency.uah,
        to: AppCurrency.usd,
        uahToUsdRate: 41.50,
      );
      expect(usd, closeTo(100.0, 0.001));
    });

    test('Converts USD to UAH correctly with exchange rate', () {
      final uah = CurrencyFormatter.convert(
        amount: 100.0,
        from: AppCurrency.usd,
        to: AppCurrency.uah,
        uahToUsdRate: 41.50,
      );
      expect(uah, closeTo(4150.0, 0.001));
    });
  });

  group('DateTimeUtils Tests', () {
    test('Formats days remaining', () {
      final futureDate = DateTime.now().add(const Duration(days: 5));
      final result = DateTimeUtils.formatDaysRemaining(futureDate);
      expect(result, 'in 5 days');
    });
  });

  group('Monobank Model Tests', () {
    test('Parses MonobankAccountInfo correctly from JSON with kopiykas', () {
      final json = {
        'id': 'mono_acc_123',
        'sendId': 'send_123',
        'balance': 4875000, // 48,750.00 UAH in kopiykas
        'creditLimit': 0,
        'currencyCode': 980,
        'type': 'black',
        'maskedPan': ['4441********1234'],
        'iban': 'UA1234567890',
      };

      final acc = MonobankAccountInfo.fromJson(json);
      expect(acc.id, 'mono_acc_123');
      expect(acc.balance, 48750.00);
      expect(acc.currency, 'UAH');
      expect(acc.type, 'black');
    });

    test('Parses MonobankStatementItem correctly', () {
      final json = {
        'id': 'tx_123',
        'time': 1690000000,
        'description': 'Silpo',
        'mcc': 5411,
        'amount': -35000, // -350.00 UAH
        'operationAmount': -35000,
        'currencyCode': 980,
        'balance': 4500000,
        'cashbackAmount': 700,
      };

      final tx = MonobankStatementItem.fromJson(json);
      expect(tx.id, 'tx_123');
      expect(tx.description, 'Silpo');
      expect(tx.amount, -350.00);
      expect(tx.mcc, 5411);
    });
  });

  group('Bybit Model Tests', () {
    test('Parses BybitWalletBalance correctly', () {
      final json = {
        'retCode': 0,
        'retMsg': 'OK',
        'result': {
          'list': [
            {
              'totalEquity': '3420.50',
              'totalWalletBalance': '3420.50',
              'coin': [
                {
                  'coin': 'USDT',
                  'walletBalance': '3000.00',
                  'usdValue': '3000.00',
                },
                {
                  'coin': 'USDC',
                  'walletBalance': '420.50',
                  'usdValue': '420.50',
                }
              ]
            }
          ]
        }
      };

      final wallet = BybitWalletBalance.fromJson(json);
      expect(wallet.totalEquityUsd, 3420.50);
      expect(wallet.coins.length, 2);
      expect(wallet.coins[0].coin, 'USDT');
      expect(wallet.coins[0].walletBalance, 3000.00);
    });
  });
}
