import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/models.dart';
import '../services/meroshare_api.dart';

// ── API singleton ────────────────────────────────────────────
final apiProvider = Provider<MeroShareApi>((ref) => MeroShareApi());

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

// ── Auth state ───────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AsyncValue<OwnDetail?>> {
  AuthNotifier(this._api, this._storage) : super(const AsyncValue.data(null));

  final MeroShareApi _api;
  final FlutterSecureStorage _storage;

  Future<void> tryAutoLogin() async {
    final token = await _storage.read(key: 'ms_token');
    if (token == null || token.isEmpty) return;
    _api.setToken(token);
    try {
      final detail = await _api.getOwnDetail();
      final capitalName = await _storage.read(key: 'ms_capital_name');
      state = AsyncValue.data(
        capitalName != null ? detail.copyWith(dpName: capitalName) : detail,
      );
    } catch (_) {
      await _storage.delete(key: 'ms_token');
      _api.clearToken();
    }
  }

  Future<void> login({
    required int clientId,
    required String username,
    required String password,
    required String capitalName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final token = await _api.login(
        clientId: clientId,
        username: username,
        password: password,
      );
      await _storage.write(key: 'ms_token', value: token);
      await _storage.write(key: 'ms_capital_name', value: capitalName);
      final detail = await _api.getOwnDetail();
      state = AsyncValue.data(detail.copyWith(dpName: capitalName));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'ms_token');
    await _storage.delete(key: 'ms_capital_name');
    _api.clearToken();
    state = const AsyncValue.data(null);
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<OwnDetail?>>(
  (ref) => AuthNotifier(
    ref.read(apiProvider),
    ref.read(secureStorageProvider),
  ),
);

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).valueOrNull != null;
});

// ── Capitals / DP list ───────────────────────────────────────
final capitalsProvider = FutureProvider<List<CapitalItem>>((ref) async {
  return ref.read(apiProvider).getCapitals();
});

// ── Portfolio ────────────────────────────────────────────────
final portfolioProvider = FutureProvider<List<Portfolio>>((ref) async {
  final detail = ref.watch(authProvider).valueOrNull;
  if (detail == null || !ref.read(apiProvider).isAuthenticated) return [];
  return ref.read(apiProvider).getPortfolio(clientCode: detail.clientCode, demat: detail.demat);
});

// ── Open IPOs ────────────────────────────────────────────────
final openIssuesProvider = FutureProvider<List<OpenIssue>>((ref) async {
  ref.watch(authProvider);
  if (!ref.read(apiProvider).isAuthenticated) return [];
  return ref.read(apiProvider).getOpenIssues();
});

// ── Applied IPOs ─────────────────────────────────────────────
final appliedIposProvider = FutureProvider<List<AppliedIpo>>((ref) async {
  ref.watch(authProvider);
  if (!ref.read(apiProvider).isAuthenticated) return [];
  return ref.read(apiProvider).getAppliedIpos();
});

// ── Rich profile (myDetail) ──────────────────────────────────
final myDetailProvider = FutureProvider<MyDetail?>((ref) async {
  final detail = ref.watch(authProvider).valueOrNull;
  if (detail == null || detail.demat.isEmpty) return null;
  if (!ref.read(apiProvider).isAuthenticated) return null;
  return ref.read(apiProvider).getMyDetail(detail.demat);
});

// ── Banks ────────────────────────────────────────────────────
final bankDetailsProvider = FutureProvider<List<BankDetail>>((ref) async {
  ref.watch(authProvider);
  if (!ref.read(apiProvider).isAuthenticated) return [];
  return ref.read(apiProvider).getBankDetails();
});

// ── Navigation ───────────────────────────────────────────────
final navIndexProvider = StateProvider<int>((ref) => 0);
