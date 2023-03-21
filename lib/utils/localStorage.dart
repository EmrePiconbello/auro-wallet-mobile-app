import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auro_wallet/utils/secureStorage.dart';

class LocalStorage {
  final walletsKey = 'wallet_account_list';
  final currentWalletKey = 'wallet_current_id';
  final contactsKey = 'wallet_contact_list';
  final seedKey = 'wallet_seed';
  final customKVKey = 'wallet_kv';

  _LocalStorage storage = _LocalStorage();

  Future<void> addWallet(Map<String, dynamic> acc) async {
    return storage.addItemToList(walletsKey, acc);
  }

  Future<void> removeWallet(String pubKey) async {
    return storage.removeItemFromList(walletsKey, 'id', pubKey);
  }

  Future<void> clearWallets() async {
    return storage.clearList(walletsKey);
  }

  Future<void> updateWallet(Map<String, dynamic> acc) async {
    return storage.updateItemInList(walletsKey, 'id', acc['id'], acc);
  }

  Future<List<Map<String, dynamic>>> getWalletList() async {
    return storage.getList(walletsKey);
  }

  Future<bool> setCurrentWallet(String walletId) async {
    return storage.setKV(currentWalletKey, walletId);
  }

  Future<String?> getCurrentWallet() async {
    return storage.getKV(currentWalletKey);
  }

  Future<List<Map<String, dynamic>>> getContactList() async {
    return storage.getList(contactsKey);
  }

  Future<void> addContact(Map<String, dynamic> con) async {
    return storage.addItemToList(contactsKey, con);
  }

  Future<void> removeContact(String address) async {
    return storage.removeItemFromList(contactsKey, 'address', address);
  }

  Future<void> updateContact(Map<String, dynamic> con, String oldAddress) async {
    return storage.updateItemInList(
        contactsKey, 'address', oldAddress, con);
  }


  Future<bool> setObject(String key, Object value) async {
    String str = await compute(jsonEncode, value);
    return storage.setKV('${customKVKey}_$key', str);
  }

  Future<bool> removeKey(String key) async {
    return storage.removeKey('${customKVKey}_$key');
  }

  Future<Object?> getObject(String key) async {
    String? value = await storage.getKV('${customKVKey}_$key');
    if (value != null) {
      Object data = await jsonDecode(value);
      return data;
    }
    return null;
  }

  Future<void> clearAccountsCache(String key) async {
    Map? data = await getObject(key) as Map?;
    data = {};
    setObject(key, data);
  }

  Future<void> setAccountCache(
      String accPubKey, String key, Object value) async {
    Map? data = await getObject(key) as Map?;
    if (data == null) {
      data = {};
    }
    data[accPubKey] = value;
    setObject(key, data);
  }

  Future<Object?> getAccountCache(String accPubKey, String key) async {
    Map? data = await getObject(key) as Map?;
    if (data == null) {
      return null;
    }
    return data[accPubKey];
  }

  // cache timeout 10 minutes
  static const int customCacheTimeLength = 10 * 60 * 1000;

  static bool checkCacheTimeout(int cacheTime) {
    return DateTime.now().millisecondsSinceEpoch - customCacheTimeLength >
        cacheTime;
  }
}

class _LocalStorage {

  Future<String?> getKV(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<bool> setKV(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }

  Future<bool> removeKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }

  Future<void> addItemToList(String storeKey, Map<String, dynamic> acc) async {
    List<Map<String, dynamic>> ls = [];

    String? str = await getKV(storeKey);
    if (str != null) {
      Iterable l = jsonDecode(str);
      ls = l.map((i) => Map<String, dynamic>.from(i)).toList();
    }

    ls.add(acc);

    setKV(storeKey, jsonEncode(ls));
  }

  Future<void> clearList(String storeKey) async {
    var ls = await getList(storeKey);
    ls.clear();
    setKV(storeKey, jsonEncode(ls));
  }

  Future<void> removeItemFromList(
      String storeKey, String itemKey, String itemValue) async {
    var ls = await getList(storeKey);
    ls.removeWhere((item) => item[itemKey] == itemValue);
    setKV(storeKey, jsonEncode(ls));
  }

  Future<void> updateItemInList(String storeKey, String itemKey,
      String itemValue, Map<String, dynamic> itemNew) async {
    List<Map<String, dynamic>> ls = await getList(storeKey);
    int index = ls.indexWhere((item) => item[itemKey] == itemValue);
    if (index >= 0) {
      ls.removeAt(index);
      ls.insert(index, itemNew);
      setKV(storeKey, jsonEncode(ls));
    }
  }

  Future<List<Map<String, dynamic>>> getList(String storeKey) async {
    List<Map<String, dynamic>> res = [];

    String? str = await getKV(storeKey);
    if (str != null) {
      Iterable l = jsonDecode(str);
      res = l.map((i) => Map<String, dynamic>.from(i)).toList();
    }
    return res;
  }
}
