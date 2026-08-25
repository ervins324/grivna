// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AccountsTableTable extends AccountsTable
    with TableInfo<$AccountsTableTable, AccountsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _balanceMeta =
      const VerificationMeta('balance');
  @override
  late final GeneratedColumn<double> balance = GeneratedColumn<double>(
      'balance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('UAH'));
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultValue: const Constant(false));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt =
      GeneratedColumn<DateTime>('last_synced_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _colorHexMeta =
      const VerificationMeta('colorHex');
  @override
  late final GeneratedColumn<int> colorHex = GeneratedColumn<int>(
      'color_hex', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultValue: const Constant(false));
  static const VerificationMeta _externalAccountIdMeta =
      const VerificationMeta('externalAccountId');
  @override
  late final GeneratedColumn<String> externalAccountId =
      GeneratedColumn<String>('external_account_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        type,
        balance,
        currency,
        isSynced,
        lastSyncedAt,
        colorHex,
        isArchived,
        externalAccountId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts_table';
  @override
  VerificationContext validateIntegrity(Insertable<AccountsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('balance')) {
      context.handle(_balanceMeta,
          balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta));
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    if (data.containsKey('color_hex')) {
      context.handle(_colorHexMeta,
          colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('external_account_id')) {
      context.handle(
          _externalAccountIdMeta,
          externalAccountId.isAcceptableOrUnknown(
              data['external_account_id']!, _externalAccountIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      balance: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}balance'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
      colorHex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_hex']),
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
      externalAccountId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}external_account_id']),
    );
  }

  @override
  $AccountsTableTable createAlias(String alias) {
    return $AccountsTableTable(attachedDatabase, alias);
  }
}

class AccountsTableData extends DataClass
    implements Insertable<AccountsTableData> {
  final String id;
  final String name;
  final String type;
  final double balance;
  final String currency;
  final bool isSynced;
  final DateTime? lastSyncedAt;
  final int? colorHex;
  final bool isArchived;
  final String? externalAccountId;
  const AccountsTableData(
      {required this.id,
      required this.name,
      required this.type,
      required this.balance,
      required this.currency,
      required this.isSynced,
      this.lastSyncedAt,
      this.colorHex,
      required this.isArchived,
      this.externalAccountId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['balance'] = Variable<double>(balance);
    map['currency'] = Variable<String>(currency);
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || colorHex != null) {
      map['color_hex'] = Variable<int>(colorHex);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    if (!nullToAbsent || externalAccountId != null) {
      map['external_account_id'] = Variable<String>(externalAccountId);
    }
    return map;
  }

  AccountsTableCompanion toCompanion(bool nullToAbsent) {
    return AccountsTableCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      balance: Value(balance),
      currency: Value(currency),
      isSynced: Value(isSynced),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      colorHex: colorHex == null && nullToAbsent
          ? const Value.absent()
          : Value(colorHex),
      isArchived: Value(isArchived),
      externalAccountId: externalAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalAccountId),
    );
  }

  factory AccountsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      balance: serializer.fromJson<double>(json['balance']),
      currency: serializer.fromJson<String>(json['currency']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      colorHex: serializer.fromJson<int?>(json['colorHex']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      externalAccountId:
          serializer.fromJson<String?>(json['externalAccountId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'balance': serializer.toJson<double>(balance),
      'currency': serializer.toJson<String>(currency),
      'isSynced': serializer.toJson<bool>(isSynced),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'colorHex': serializer.toJson<int?>(colorHex),
      'isArchived': serializer.toJson<bool>(isArchived),
      'externalAccountId': serializer.toJson<String?>(externalAccountId),
    };
  }

  AccountsTableData copyWith(
          {String? id,
          String? name,
          String? type,
          double? balance,
          String? currency,
          bool? isSynced,
          Value<DateTime?> lastSyncedAt = const Value.absent(),
          Value<int?> colorHex = const Value.absent(),
          bool? isArchived,
          Value<String?> externalAccountId = const Value.absent()}) =>
      AccountsTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        balance: balance ?? this.balance,
        currency: currency ?? this.currency,
        isSynced: isSynced ?? this.isSynced,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
        colorHex: colorHex.present ? colorHex.value : this.colorHex,
        isArchived: isArchived ?? this.isArchived,
        externalAccountId: externalAccountId.present
            ? externalAccountId.value
            : this.externalAccountId,
      );
}

class AccountsTableCompanion extends UpdateCompanion<AccountsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<double> balance;
  final Value<String> currency;
  final Value<bool> isSynced;
  final Value<DateTime?> lastSyncedAt;
  final Value<int?> colorHex;
  final Value<bool> isArchived;
  final Value<String?> externalAccountId;
  const AccountsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.balance = const Value.absent(),
    this.currency = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.externalAccountId = const Value.absent(),
  });
  AccountsTableCompanion.insert({
    required String id,
    required String name,
    required String type,
    this.balance = const Value.absent(),
    this.currency = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.externalAccountId = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        type = Value(type);

  AccountsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? type,
      Value<double>? balance,
      Value<String>? currency,
      Value<bool>? isSynced,
      Value<DateTime?>? lastSyncedAt,
      Value<int?>? colorHex,
      Value<bool>? isArchived,
      Value<String?>? externalAccountId}) {
    return AccountsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      isSynced: isSynced ?? this.isSynced,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      colorHex: colorHex ?? this.colorHex,
      isArchived: isArchived ?? this.isArchived,
      externalAccountId: externalAccountId ?? this.externalAccountId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (balance.present) {
      map['balance'] = Variable<double>(balance.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<int>(colorHex.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (externalAccountId.present) {
      map['external_account_id'] = Variable<String>(externalAccountId.value);
    }
    return map;
  }
}

// ---------------- Transactions Table ----------------

class $TransactionsTableTable extends TransactionsTable
    with TableInfo<$TransactionsTableTable, TransactionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
      'account_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _toAccountIdMeta =
      const VerificationMeta('toAccountId');
  @override
  late final GeneratedColumn<String> toAccountId = GeneratedColumn<String>(
      'to_account_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('UAH'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('General'));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultValue: const Constant(false));
  static const VerificationMeta _externalIdMeta =
      const VerificationMeta('externalId');
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
      'external_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        accountId,
        toAccountId,
        amount,
        currency,
        type,
        category,
        description,
        timestamp,
        isSynced,
        externalId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<TransactionsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('to_account_id')) {
      context.handle(
          _toAccountIdMeta,
          toAccountId.isAcceptableOrUnknown(
              data['to_account_id']!, _toAccountIdMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('external_id')) {
      context.handle(
          _externalIdMeta,
          externalId.isAcceptableOrUnknown(
              data['external_id']!, _externalIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_id'])!,
      toAccountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}to_account_id']),
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      externalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}external_id']),
    );
  }

  @override
  $TransactionsTableTable createAlias(String alias) {
    return $TransactionsTableTable(attachedDatabase, alias);
  }
}

class TransactionsTableData extends DataClass
    implements Insertable<TransactionsTableData> {
  final String id;
  final String accountId;
  final String? toAccountId;
  final double amount;
  final String currency;
  final String type;
  final String category;
  final String description;
  final DateTime timestamp;
  final bool isSynced;
  final String? externalId;
  const TransactionsTableData(
      {required this.id,
      required this.accountId,
      this.toAccountId,
      required this.amount,
      required this.currency,
      required this.type,
      required this.category,
      required this.description,
      required this.timestamp,
      required this.isSynced,
      this.externalId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    if (!nullToAbsent || toAccountId != null) {
      map['to_account_id'] = Variable<String>(toAccountId);
    }
    map['amount'] = Variable<double>(amount);
    map['currency'] = Variable<String>(currency);
    map['type'] = Variable<String>(type);
    map['category'] = Variable<String>(category);
    map['description'] = Variable<String>(description);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || externalId != null) {
      map['external_id'] = Variable<String>(externalId);
    }
    return map;
  }

  TransactionsTableCompanion toCompanion(bool nullToAbsent) {
    return TransactionsTableCompanion(
      id: Value(id),
      accountId: Value(accountId),
      toAccountId: toAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(toAccountId),
      amount: Value(amount),
      currency: Value(currency),
      type: Value(type),
      category: Value(category),
      description: Value(description),
      timestamp: Value(timestamp),
      isSynced: Value(isSynced),
      externalId: externalId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalId),
    );
  }

  factory TransactionsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionsTableData(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      toAccountId: serializer.fromJson<String?>(json['toAccountId']),
      amount: serializer.fromJson<double>(json['amount']),
      currency: serializer.fromJson<String>(json['currency']),
      type: serializer.fromJson<String>(json['type']),
      category: serializer.fromJson<String>(json['category']),
      description: serializer.fromJson<String>(json['description']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      externalId: serializer.fromJson<String?>(json['externalId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'toAccountId': serializer.toJson<String?>(toAccountId),
      'amount': serializer.toJson<double>(amount),
      'currency': serializer.toJson<String>(currency),
      'type': serializer.toJson<String>(type),
      'category': serializer.toJson<String>(category),
      'description': serializer.toJson<String>(description),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'isSynced': serializer.toJson<bool>(isSynced),
      'externalId': serializer.toJson<String?>(externalId),
    };
  }

  TransactionsTableData copyWith(
          {String? id,
          String? accountId,
          Value<String?> toAccountId = const Value.absent(),
          double? amount,
          String? currency,
          String? type,
          String? category,
          String? description,
          DateTime? timestamp,
          bool? isSynced,
          Value<String?> externalId = const Value.absent()}) =>
      TransactionsTableData(
        id: id ?? this.id,
        accountId: accountId ?? this.accountId,
        toAccountId: toAccountId.present ? toAccountId.value : this.toAccountId,
        amount: amount ?? this.amount,
        currency: currency ?? this.currency,
        type: type ?? this.type,
        category: category ?? this.category,
        description: description ?? this.description,
        timestamp: timestamp ?? this.timestamp,
        isSynced: isSynced ?? this.isSynced,
        externalId: externalId.present ? externalId.value : this.externalId,
      );
}

class TransactionsTableCompanion
    extends UpdateCompanion<TransactionsTableData> {
  final Value<String> id;
  final Value<String> accountId;
  final Value<String?> toAccountId;
  final Value<double> amount;
  final Value<String> currency;
  final Value<String> type;
  final Value<String> category;
  final Value<String> description;
  final Value<DateTime> timestamp;
  final Value<bool> isSynced;
  final Value<String?> externalId;
  const TransactionsTableCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.toAccountId = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.type = const Value.absent(),
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.externalId = const Value.absent(),
  });
  TransactionsTableCompanion.insert({
    required String id,
    required String accountId,
    this.toAccountId = const Value.absent(),
    required double amount,
    this.currency = const Value.absent(),
    required String type,
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    required DateTime timestamp,
    this.isSynced = const Value.absent(),
    this.externalId = const Value.absent(),
  })  : id = Value(id),
        accountId = Value(accountId),
        amount = Value(amount),
        type = Value(type),
        timestamp = Value(timestamp);

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (toAccountId.present) {
      map['to_account_id'] = Variable<String>(toAccountId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    return map;
  }
}

// ---------------- Categories Table ----------------

class $CategoriesTableTable extends CategoriesTable
    with TableInfo<$CategoriesTableTable, CategoriesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconNameMeta =
      const VerificationMeta('iconName');
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
      'icon_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('category'));
  static const VerificationMeta _colorHexMeta =
      const VerificationMeta('colorHex');
  @override
  late final GeneratedColumn<int> colorHex = GeneratedColumn<int>(
      'color_hex', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0xFFFAFAFA));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('expense'));
  static const VerificationMeta _isCustomMeta =
      const VerificationMeta('isCustom');
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
      'is_custom', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, iconName, colorHex, type, isCustom];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<CategoriesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_name')) {
      context.handle(_iconNameMeta,
          iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta));
    }
    if (data.containsKey('color_hex')) {
      context.handle(_colorHexMeta,
          colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('is_custom')) {
      context.handle(_isCustomMeta,
          isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoriesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoriesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      iconName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_name'])!,
      colorHex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_hex'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      isCustom: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_custom'])!,
    );
  }

  @override
  $CategoriesTableTable createAlias(String alias) {
    return $CategoriesTableTable(attachedDatabase, alias);
  }
}

class CategoriesTableData extends DataClass
    implements Insertable<CategoriesTableData> {
  final String id;
  final String name;
  final String iconName;
  final int colorHex;
  final String type;
  final bool isCustom;
  const CategoriesTableData(
      {required this.id,
      required this.name,
      required this.iconName,
      required this.colorHex,
      required this.type,
      required this.isCustom});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon_name'] = Variable<String>(iconName);
    map['color_hex'] = Variable<int>(colorHex);
    map['type'] = Variable<String>(type);
    map['is_custom'] = Variable<bool>(isCustom);
    return map;
  }

  CategoriesTableCompanion toCompanion(bool nullToAbsent) {
    return CategoriesTableCompanion(
      id: Value(id),
      name: Value(name),
      iconName: Value(iconName),
      colorHex: Value(colorHex),
      type: Value(type),
      isCustom: Value(isCustom),
    );
  }

  factory CategoriesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoriesTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconName: serializer.fromJson<String>(json['iconName']),
      colorHex: serializer.fromJson<int>(json['colorHex']),
      type: serializer.fromJson<String>(json['type']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'iconName': serializer.toJson<String>(iconName),
      'colorHex': serializer.toJson<int>(colorHex),
      'type': serializer.toJson<String>(type),
      'isCustom': serializer.toJson<bool>(isCustom),
    };
  }

  CategoriesTableData copyWith(
          {String? id,
          String? name,
          String? iconName,
          int? colorHex,
          String? type,
          bool? isCustom}) =>
      CategoriesTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        iconName: iconName ?? this.iconName,
        colorHex: colorHex ?? this.colorHex,
        type: type ?? this.type,
        isCustom: isCustom ?? this.isCustom,
      );
}

class CategoriesTableCompanion extends UpdateCompanion<CategoriesTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> iconName;
  final Value<int> colorHex;
  final Value<String> type;
  final Value<bool> isCustom;
  const CategoriesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconName = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.type = const Value.absent(),
    this.isCustom = const Value.absent(),
  });
  CategoriesTableCompanion.insert({
    required String id,
    required String name,
    this.iconName = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.type = const Value.absent(),
    this.isCustom = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<int>(colorHex.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    return map;
  }
}

// ---------------- Subscriptions Table ----------------

class $SubscriptionsTableTable extends SubscriptionsTable
    with TableInfo<$SubscriptionsTableTable, SubscriptionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscriptionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('USD'));
  static const VerificationMeta _billingCycleMeta =
      const VerificationMeta('billingCycle');
  @override
  late final GeneratedColumn<String> billingCycle = GeneratedColumn<String>(
      'billing_cycle', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('monthly'));
  static const VerificationMeta _cycleDaysMeta =
      const VerificationMeta('cycleDays');
  @override
  late final GeneratedColumn<int> cycleDays = GeneratedColumn<int>(
      'cycle_days', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(30));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Subscriptions'));
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _nextBillingDateMeta =
      const VerificationMeta('nextBillingDate');
  @override
  late final GeneratedColumn<DateTime> nextBillingDate =
      GeneratedColumn<DateTime>('next_billing_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
      'account_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultValue: const Constant(true));
  static const VerificationMeta _colorHexMeta =
      const VerificationMeta('colorHex');
  @override
  late final GeneratedColumn<int> colorHex = GeneratedColumn<int>(
      'color_hex', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        amount,
        currency,
        billingCycle,
        cycleDays,
        category,
        startDate,
        nextBillingDate,
        accountId,
        isActive,
        colorHex
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscriptions_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<SubscriptionsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('billing_cycle')) {
      context.handle(
          _billingCycleMeta,
          billingCycle.isAcceptableOrUnknown(
              data['billing_cycle']!, _billingCycleMeta));
    }
    if (data.containsKey('cycle_days')) {
      context.handle(_cycleDaysMeta,
          cycleDays.isAcceptableOrUnknown(data['cycle_days']!, _cycleDaysMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('next_billing_date')) {
      context.handle(
          _nextBillingDateMeta,
          nextBillingDate.isAcceptableOrUnknown(
              data['next_billing_date']!, _nextBillingDateMeta));
    } else if (isInserting) {
      context.missing(_nextBillingDateMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('color_hex')) {
      context.handle(_colorHexMeta,
          colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubscriptionsTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubscriptionsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      billingCycle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}billing_cycle'])!,
      cycleDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cycle_days'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      nextBillingDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_billing_date'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_id']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      colorHex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_hex']),
    );
  }

  @override
  $SubscriptionsTableTable createAlias(String alias) {
    return $SubscriptionsTableTable(attachedDatabase, alias);
  }
}

class SubscriptionsTableData extends DataClass
    implements Insertable<SubscriptionsTableData> {
  final String id;
  final String name;
  final double amount;
  final String currency;
  final String billingCycle;
  final int cycleDays;
  final String category;
  final DateTime startDate;
  final DateTime nextBillingDate;
  final String? accountId;
  final bool isActive;
  final int? colorHex;
  const SubscriptionsTableData(
      {required this.id,
      required this.name,
      required this.amount,
      required this.currency,
      required this.billingCycle,
      required this.cycleDays,
      required this.category,
      required this.startDate,
      required this.nextBillingDate,
      this.accountId,
      required this.isActive,
      this.colorHex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['amount'] = Variable<double>(amount);
    map['currency'] = Variable<String>(currency);
    map['billing_cycle'] = Variable<String>(billingCycle);
    map['cycle_days'] = Variable<int>(cycleDays);
    map['category'] = Variable<String>(category);
    map['start_date'] = Variable<DateTime>(startDate);
    map['next_billing_date'] = Variable<DateTime>(nextBillingDate);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || colorHex != null) {
      map['color_hex'] = Variable<int>(colorHex);
    }
    return map;
  }

  SubscriptionsTableCompanion toCompanion(bool nullToAbsent) {
    return SubscriptionsTableCompanion(
      id: Value(id),
      name: Value(name),
      amount: Value(amount),
      currency: Value(currency),
      billingCycle: Value(billingCycle),
      cycleDays: Value(cycleDays),
      category: Value(category),
      startDate: Value(startDate),
      nextBillingDate: Value(nextBillingDate),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      isActive: Value(isActive),
      colorHex: colorHex == null && nullToAbsent
          ? const Value.absent()
          : Value(colorHex),
    );
  }

  factory SubscriptionsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubscriptionsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      amount: serializer.fromJson<double>(json['amount']),
      currency: serializer.fromJson<String>(json['currency']),
      billingCycle: serializer.fromJson<String>(json['billingCycle']),
      cycleDays: serializer.fromJson<int>(json['cycleDays']),
      category: serializer.fromJson<String>(json['category']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      nextBillingDate: serializer.fromJson<DateTime>(json['nextBillingDate']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      colorHex: serializer.fromJson<int?>(json['colorHex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'amount': serializer.toJson<double>(amount),
      'currency': serializer.toJson<String>(currency),
      'billingCycle': serializer.toJson<String>(billingCycle),
      'cycleDays': serializer.toJson<int>(cycleDays),
      'category': serializer.toJson<String>(category),
      'startDate': serializer.toJson<DateTime>(startDate),
      'nextBillingDate': serializer.toJson<DateTime>(nextBillingDate),
      'accountId': serializer.toJson<String?>(accountId),
      'isActive': serializer.toJson<bool>(isActive),
      'colorHex': serializer.toJson<int?>(colorHex),
    };
  }

  SubscriptionsTableData copyWith(
          {String? id,
          String? name,
          double? amount,
          String? currency,
          String? billingCycle,
          int? cycleDays,
          String? category,
          DateTime? startDate,
          DateTime? nextBillingDate,
          Value<String?> accountId = const Value.absent(),
          bool? isActive,
          Value<int?> colorHex = const Value.absent()}) =>
      SubscriptionsTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        currency: currency ?? this.currency,
        billingCycle: billingCycle ?? this.billingCycle,
        cycleDays: cycleDays ?? this.cycleDays,
        category: category ?? this.category,
        startDate: startDate ?? this.startDate,
        nextBillingDate: nextBillingDate ?? this.nextBillingDate,
        accountId: accountId.present ? accountId.value : this.accountId,
        isActive: isActive ?? this.isActive,
        colorHex: colorHex.present ? colorHex.value : this.colorHex,
      );
}

class SubscriptionsTableCompanion
    extends UpdateCompanion<SubscriptionsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> amount;
  final Value<String> currency;
  final Value<String> billingCycle;
  final Value<int> cycleDays;
  final Value<String> category;
  final Value<DateTime> startDate;
  final Value<DateTime> nextBillingDate;
  final Value<String?> accountId;
  final Value<bool> isActive;
  final Value<int?> colorHex;
  const SubscriptionsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.billingCycle = const Value.absent(),
    this.cycleDays = const Value.absent(),
    this.category = const Value.absent(),
    this.startDate = const Value.absent(),
    this.nextBillingDate = const Value.absent(),
    this.accountId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.colorHex = const Value.absent(),
  });
  SubscriptionsTableCompanion.insert({
    required String id,
    required String name,
    required double amount,
    this.currency = const Value.absent(),
    this.billingCycle = const Value.absent(),
    this.cycleDays = const Value.absent(),
    this.category = const Value.absent(),
    required DateTime startDate,
    required DateTime nextBillingDate,
    this.accountId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.colorHex = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        amount = Value(amount),
        startDate = Value(startDate),
        nextBillingDate = Value(nextBillingDate);

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (billingCycle.present) {
      map['billing_cycle'] = Variable<String>(billingCycle.value);
    }
    if (cycleDays.present) {
      map['cycle_days'] = Variable<int>(cycleDays.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (nextBillingDate.present) {
      map['next_billing_date'] = Variable<DateTime>(nextBillingDate.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<int>(colorHex.value);
    }
    return map;
  }
}

// ---------------- Exchange Rates Table ----------------

class $ExchangeRatesTableTable extends ExchangeRatesTable
    with TableInfo<$ExchangeRatesTableTable, ExchangeRatesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExchangeRatesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fromCurrencyMeta =
      const VerificationMeta('fromCurrency');
  @override
  late final GeneratedColumn<String> fromCurrency = GeneratedColumn<String>(
      'from_currency', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _toCurrencyMeta =
      const VerificationMeta('toCurrency');
  @override
  late final GeneratedColumn<String> toCurrency = GeneratedColumn<String>(
      'to_currency', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<double> rate = GeneratedColumn<double>(
      'rate', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _buyRateMeta =
      const VerificationMeta('buyRate');
  @override
  late final GeneratedColumn<double> buyRate = GeneratedColumn<double>(
      'buy_rate', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _sellRateMeta =
      const VerificationMeta('sellRate');
  @override
  late final GeneratedColumn<double> sellRate = GeneratedColumn<double>(
      'sell_rate', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, fromCurrency, toCurrency, rate, buyRate, sellRate, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exchange_rates_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<ExchangeRatesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('from_currency')) {
      context.handle(
          _fromCurrencyMeta,
          fromCurrency.isAcceptableOrUnknown(
              data['from_currency']!, _fromCurrencyMeta));
    } else if (isInserting) {
      context.missing(_fromCurrencyMeta);
    }
    if (data.containsKey('to_currency')) {
      context.handle(
          _toCurrencyMeta,
          toCurrency.isAcceptableOrUnknown(
              data['to_currency']!, _toCurrencyMeta));
    } else if (isInserting) {
      context.missing(_toCurrencyMeta);
    }
    if (data.containsKey('rate')) {
      context.handle(
          _rateMeta, rate.isAcceptableOrUnknown(data['rate']!, _rateMeta));
    } else if (isInserting) {
      context.missing(_rateMeta);
    }
    if (data.containsKey('buy_rate')) {
      context.handle(_buyRateMeta,
          buyRate.isAcceptableOrUnknown(data['buy_rate']!, _buyRateMeta));
    }
    if (data.containsKey('sell_rate')) {
      context.handle(_sellRateMeta,
          sellRate.isAcceptableOrUnknown(data['sell_rate']!, _sellRateMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExchangeRatesTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExchangeRatesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      fromCurrency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}from_currency'])!,
      toCurrency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}to_currency'])!,
      rate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rate'])!,
      buyRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}buy_rate'])!,
      sellRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}sell_rate'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ExchangeRatesTableTable createAlias(String alias) {
    return $ExchangeRatesTableTable(attachedDatabase, alias);
  }
}

class ExchangeRatesTableData extends DataClass
    implements Insertable<ExchangeRatesTableData> {
  final String id;
  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final double buyRate;
  final double sellRate;
  final DateTime updatedAt;
  const ExchangeRatesTableData(
      {required this.id,
      required this.fromCurrency,
      required this.toCurrency,
      required this.rate,
      required this.buyRate,
      required this.sellRate,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['from_currency'] = Variable<String>(fromCurrency);
    map['to_currency'] = Variable<String>(toCurrency);
    map['rate'] = Variable<double>(rate);
    map['buy_rate'] = Variable<double>(buyRate);
    map['sell_rate'] = Variable<double>(sellRate);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ExchangeRatesTableCompanion toCompanion(bool nullToAbsent) {
    return ExchangeRatesTableCompanion(
      id: Value(id),
      fromCurrency: Value(fromCurrency),
      toCurrency: Value(toCurrency),
      rate: Value(rate),
      buyRate: Value(buyRate),
      sellRate: Value(sellRate),
      updatedAt: Value(updatedAt),
    );
  }

  factory ExchangeRatesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExchangeRatesTableData(
      id: serializer.fromJson<String>(json['id']),
      fromCurrency: serializer.fromJson<String>(json['fromCurrency']),
      toCurrency: serializer.fromJson<String>(json['toCurrency']),
      rate: serializer.fromJson<double>(json['rate']),
      buyRate: serializer.fromJson<double>(json['buyRate']),
      sellRate: serializer.fromJson<double>(json['sellRate']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fromCurrency': serializer.toJson<String>(fromCurrency),
      'toCurrency': serializer.toJson<String>(toCurrency),
      'rate': serializer.toJson<double>(rate),
      'buyRate': serializer.toJson<double>(buyRate),
      'sellRate': serializer.toJson<double>(sellRate),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ExchangeRatesTableData copyWith(
          {String? id,
          String? fromCurrency,
          String? toCurrency,
          double? rate,
          double? buyRate,
          double? sellRate,
          DateTime? updatedAt}) =>
      ExchangeRatesTableData(
        id: id ?? this.id,
        fromCurrency: fromCurrency ?? this.fromCurrency,
        toCurrency: toCurrency ?? this.toCurrency,
        rate: rate ?? this.rate,
        buyRate: buyRate ?? this.buyRate,
        sellRate: sellRate ?? this.sellRate,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

class ExchangeRatesTableCompanion
    extends UpdateCompanion<ExchangeRatesTableData> {
  final Value<String> id;
  final Value<String> fromCurrency;
  final Value<String> toCurrency;
  final Value<double> rate;
  final Value<double> buyRate;
  final Value<double> sellRate;
  final Value<DateTime> updatedAt;
  const ExchangeRatesTableCompanion({
    this.id = const Value.absent(),
    this.fromCurrency = const Value.absent(),
    this.toCurrency = const Value.absent(),
    this.rate = const Value.absent(),
    this.buyRate = const Value.absent(),
    this.sellRate = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ExchangeRatesTableCompanion.insert({
    required String id,
    required String fromCurrency,
    required String toCurrency,
    required double rate,
    this.buyRate = const Value.absent(),
    this.sellRate = const Value.absent(),
    required DateTime updatedAt,
  })  : id = Value(id),
        fromCurrency = Value(fromCurrency),
        toCurrency = Value(toCurrency),
        rate = Value(rate),
        updatedAt = Value(updatedAt);

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fromCurrency.present) {
      map['from_currency'] = Variable<String>(fromCurrency.value);
    }
    if (toCurrency.present) {
      map['to_currency'] = Variable<String>(toCurrency.value);
    }
    if (rate.present) {
      map['rate'] = Variable<double>(rate.value);
    }
    if (buyRate.present) {
      map['buy_rate'] = Variable<double>(buyRate.value);
    }
    if (sellRate.present) {
      map['sell_rate'] = Variable<double>(sellRate.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }
}

// ---------------- App Settings Table ----------------

class $AppSettingsTableTable extends AppSettingsTable
    with TableInfo<$AppSettingsTableTable, AppSettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<AppSettingsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsTableData(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $AppSettingsTableTable createAlias(String alias) {
    return $AppSettingsTableTable(attachedDatabase, alias);
  }
}

class AppSettingsTableData extends DataClass
    implements Insertable<AppSettingsTableData> {
  final String key;
  final String value;
  const AppSettingsTableData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsTableCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory AppSettingsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsTableData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSettingsTableData copyWith({String? key, String? value}) =>
      AppSettingsTableData(
        key: key ?? this.key,
        value: value ?? this.value,
      );
}

class AppSettingsTableCompanion
    extends UpdateCompanion<AppSettingsTableData> {
  final Value<String> key;
  final Value<String> value;
  const AppSettingsTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
  });
  AppSettingsTableCompanion.insert({
    required String key,
    required String value,
  })  : key = Value(key),
        value = Value(value);

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    return map;
  }
}

// ---------------- Database Implementation ----------------

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $AccountsTableTable accountsTable =
      $AccountsTableTable(this);
  late final $TransactionsTableTable transactionsTable =
      $TransactionsTableTable(this);
  late final $CategoriesTableTable categoriesTable =
      $CategoriesTableTable(this);
  late final $SubscriptionsTableTable subscriptionsTable =
      $SubscriptionsTableTable(this);
  late final $ExchangeRatesTableTable exchangeRatesTable =
      $ExchangeRatesTableTable(this);
  late final $AppSettingsTableTable appSettingsTable =
      $AppSettingsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        accountsTable,
        transactionsTable,
        categoriesTable,
        subscriptionsTable,
        exchangeRatesTable,
        appSettingsTable
      ];
}
