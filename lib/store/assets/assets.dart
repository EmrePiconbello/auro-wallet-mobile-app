import 'dart:convert';

import 'package:auro_wallet/store/assets/types/feeTransferData.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/walletSdk/minaSDK.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/fees.dart';
import 'package:auro_wallet/store/assets/types/accountInfo.dart';
import 'package:auro_wallet/store/assets/types/transferData.dart';

part 'assets.g.dart';

class AssetsStore extends _AssetsStore with _$AssetsStore {
  AssetsStore(AppStore store) : super(store);
}

abstract class _AssetsStore with Store {
  _AssetsStore(this.rootStore);

  final AppStore rootStore;

  final String localStorageBlocksKey = 'blocks';

  final String localStorageFeesKey = 'fees';
  final String cacheBalanceKey = 'balance';
  final String cachePriceKey = 'coin_price';
  final String cacheTxsKey = 'txs';
  final String cacheFeeTxsKey = 'fee_txs';

  @observable
  bool isTxsLoading = true;

  @observable
  bool isBalanceLoading = false;

  @observable
  ObservableMap<String, AccountInfo> accountsInfo =
      ObservableMap<String, AccountInfo>();

  @observable
  Map<String, String> tokenBalances = Map<String, String>();

  @observable
  Fees transferFees = new Fees()
    ..slow = 0.001
    ..medium = 0.0101
    ..fast = 0.1
    ..cap = 10;

  @observable
  int txsCount = 0;

  @observable
  ObservableList<TransferData> pendingTxs = ObservableList<TransferData>();

  @observable
  ObservableList<TransferData> txs = ObservableList<TransferData>();

  @observable
  ObservableList<FeeTransferData> feeTxs = ObservableList<FeeTransferData>();

  @computed
  List<TransferData> get totalTxs {
    var gettime = (TransferData tx) {
      String dateTimeStr = '';
      dateTimeStr = tx.time ?? '';
      if (dateTimeStr.isEmpty) {
        return DateTime.now();
      }
      return Fmt.toDatetime(dateTimeStr);
    };
    List<TransferData> totals = [];
    // print('Txs length' + feeTxs.length.toString());
    // print('feetxs length' + feeTxs.length.toString());
    totals.addAll(txs);
    // totals.addAll(feeTxs.map((element) {
    //   return TransferData.fromFeeTransfer(element);
    // }));
    totals.sort((tx1, tx2) {
      var dateTime1 = gettime(tx1);
      var dateTime2 = gettime(tx2);
      return dateTime2.compareTo(dateTime1);
    });
    return totals;
  }

  @observable
  int txsFilter = 0;

  @observable
  ObservableMap<String, double> marketPrices = ObservableMap<String, double>();

  @action
  Future<void> setAccountInfo(String pubKey, Map amt,
      {bool needCache = true}) async {
    // if (rootStore.wallet!.currentWallet.pubKey != pubKey) return;

    accountsInfo[pubKey] = AccountInfo.fromJson(amt as Map<String, dynamic>);

    if (!needCache) return;
    // Map? cache = await rootStore.localStorage.getAccountCache(
    //   pubKey,
    //   cacheBalanceKey,
    // ) as Map?;
    // cache = amt;
    rootStore.localStorage.setAccountCache(
      pubKey,
      cacheBalanceKey,
      amt,
    );
  }

  @action
  void setTxsLoading(bool isLoading) {
    isTxsLoading = isLoading;
  }

  @action
  Future<void> clearTxs() async {
    txs.clear();
  }

  @action
  Future<void> clearFeeTxs() async {
    feeTxs.clear();
  }

  @action
  Future<void> clearPendingTxs() async {
    pendingTxs.clear();
  }

  @action
  Future<void> addPendingTxs(List<dynamic>? ls, String address) async {
    if (rootStore.wallet!.currentAddress != address) return;
    if (ls == null) return;
    ls.forEach((i) {
      i['memo'] = i['memo'] != null ? bs58Decode(i['memo']) : '';
      TransferData tx = TransferData.fromPendingJson(i);
      pendingTxs.add(tx);
    });
    pendingTxs.sort((tx1, tx2) => tx2.nonce! - tx1.nonce!);
  }

  @action
  Future<void> addFeeTxs(List<dynamic> ls, String address,
      {bool shouldCache = false}) async {
    if (rootStore.wallet!.currentAddress != address) return;

    if (ls == null) return;

    ls.forEach((i) {
      FeeTransferData tx = FeeTransferData.fromJson(i);
      feeTxs.add(tx);
    });

    if (shouldCache) {
      rootStore.localStorage.setAccountCache(
          rootStore.wallet!.currentWallet.pubKey, cacheFeeTxsKey, ls);
    }
  }

  @action
  Future<void> addTxs(List<dynamic> ls, String address,
      {bool shouldCache = false}) async {
    if (rootStore.wallet!.currentAddress != address) return;

    if (ls == null) return;

    ls.forEach((i) {
      i['memo'] = i['memo'] != null ? bs58Decode(i['memo']) : '';
      TransferData tx = TransferData.fromGraphQLJson(i);
      tx.success = tx.status != 'failed';
      i['success'] = tx.success;
      txs.add(tx);
    });

    if (shouldCache) {
      rootStore.localStorage.setAccountCache(
          rootStore.wallet!.currentWallet.pubKey, cacheTxsKey, ls);
    }
  }

  @action
  Future<void> setFeesMap(Map<String, double> fees) async {
    transferFees = Fees.fromJson(fees);
    rootStore.localStorage.setObject(localStorageFeesKey, transferFees);
  }

  @action
  void setBalanceLoading(bool isLoading) {
    isBalanceLoading = isLoading;
  }

  @action
  void setMarketPrices(String token, double price) {
    marketPrices[token] = price;
    rootStore.localStorage.setObject(
        cachePriceKey, marketPrices.map((key, value) => MapEntry(key, value)));
  }

  @action
  Future<void> loadMultiAccountCache() async {
    for (var account in rootStore.wallet!.accountListAll) {
      Map? cache = await rootStore.localStorage
          .getAccountCache(account.pubKey, cacheBalanceKey) as Map?;
      if (cache != null) {
        setAccountInfo(account.pubKey, cache, needCache: false);
      }
    }
  }

  @action
  Future<void> loadAccountCache() async {
    // return if currentAccount not exist
    String pubKey = rootStore.wallet!.currentAccountPubKey;
    if (pubKey.isEmpty) {
      return;
    }
    List cache = await Future.wait([
      rootStore.localStorage.getAccountCache(pubKey, cacheBalanceKey),
      rootStore.localStorage.getAccountCache(pubKey, cacheTxsKey),
      rootStore.localStorage.getAccountCache(pubKey, cacheFeeTxsKey),
    ]);

    if (cache[0] != null) {
      setAccountInfo(pubKey, cache[0], needCache: false);
    }
    if (cache[1] != null) {
      txs = ObservableList.of(
          List.of(cache[1]).map((i) => TransferData.fromJson(i)).toList());
    } else {
      txs = ObservableList();
    }
    if (cache[2] != null) {
      feeTxs = ObservableList.of(
          List.of(cache[2]).map((i) => FeeTransferData.fromJson(i)).toList());
    } else {
      feeTxs = ObservableList();
    }
  }

  @action
  Future<void> loadMarketPricesCache() async {
    Map<String, dynamic>? prices = await rootStore.localStorage
        .getObject(cachePriceKey) as Map<String, dynamic>?;
    if (prices != null) {
      marketPrices
          .addAll(prices.map((key, value) => MapEntry(key, value as double)));
    }
  }

  @action
  Future<void> loadFeesCache() async {
    Map<String, dynamic>? fees = await rootStore.localStorage
        .getObject(localStorageFeesKey) as Map<String, dynamic>?;
    if (fees != null) {
      transferFees = Fees.fromJson(fees);
    } else {
      transferFees = Fees.fromDefault();
    }
  }

  @action
  Future<void> clearAccountCache() async {
    rootStore.localStorage.clearAccountsCache(cacheTxsKey);
    rootStore.localStorage.clearAccountsCache(cacheFeeTxsKey);
    rootStore.localStorage.clearAccountsCache(cacheBalanceKey);
    txs = ObservableList();
    feeTxs = ObservableList();
    accountsInfo = ObservableMap<String, AccountInfo>();
  }

  @action
  Future<void> loadCache() async {
    await loadFeesCache();
    await loadMarketPricesCache();
    await loadAccountCache();
    await loadMultiAccountCache();
  }
}
