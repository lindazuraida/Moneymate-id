import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/account_model.dart';

/// Sumber data lokal untuk Account, memakai shared_preferences sebagai
/// penyimpanan permanen di perangkat.
///
/// Catatan desain: semua akun disimpan sebagai satu list JSON di bawah
/// satu key (bukan satu key per akun), karena shared_preferences cocok
/// untuk data kecil-menengah seperti ini dan menghindari kebutuhan
/// database penuh (Isar/sqflite) untuk skala data sebanyak ini. Kalau
/// nanti jumlah akun + transaksi + riwayat jadi sangat besar, ini adalah
/// titik migrasi paling jelas ke database lokal yang lebih powerful.
class AccountLocalDataSource {
  static const _storageKey = 'accounts_data_v1';

  Future<List<AccountModel>> getAllAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => AccountModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAllAccounts(List<AccountModel> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(accounts.map((a) => a.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> addAccount(AccountModel account) async {
    final current = await getAllAccounts();
    current.add(account);
    await saveAllAccounts(current);
  }

  Future<void> updateAccount(AccountModel updated) async {
    final current = await getAllAccounts();
    final index = current.indexWhere((a) => a.id == updated.id);
    if (index != -1) {
      current[index] = updated;
      await saveAllAccounts(current);
    }
  }

  Future<void> deleteAccount(String id) async {
    final current = await getAllAccounts();
    current.removeWhere((a) => a.id == id);
    await saveAllAccounts(current);
  }
}
