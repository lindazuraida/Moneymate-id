import '../entities/account.dart';

/// Kontrak repository untuk operasi terhadap [Account].
///
/// Layer domain/presentation bergantung pada abstraksi ini, bukan pada
/// implementasi konkret — supaya nanti ganti dari shared_preferences ke
/// database lokal lain (atau sinkron ke Firestore) tidak perlu mengubah
/// kode presentation sama sekali, cukup ganti implementasinya saja.
abstract class AccountRepository {
  Future<List<Account>> getAllAccounts();
  Future<void> addAccount(Account account);
  Future<void> updateAccount(Account account);
  Future<void> deleteAccount(String id);
}
