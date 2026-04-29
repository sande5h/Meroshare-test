import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

class MeroShareApi {
  static const _webBase = 'https://webbackend.cdsc.com.np';
  static const _base = '$_webBase/api/meroShare';
  static const _viewBase = '$_webBase/api/meroShareView';

  final Dio _dio;
  String? _token;

  MeroShareApi() : _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json, text/plain, */*',
      'Origin': 'https://meroshare.cdsc.com.np',
      'Referer': 'https://meroshare.cdsc.com.np/',
    },
  ));

  void _setAuth(String token) {
    _token = token;
    _dio.options.headers['Authorization'] = token;
  }

  void setToken(String token) => _setAuth(token);
  void clearToken() {
    _token = null;
    _dio.options.headers.remove('Authorization');
  }

  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  // ── Fetch all DP / Capitals ──────────────────────────────
  Future<List<CapitalItem>> getCapitals() async {
    final res = await _dio.get('$_base/capital/');
    final list = res.data as List;
    return list.map((e) => CapitalItem.fromJson(e)).toList();
  }

  // ── Login ────────────────────────────────────────────────
  // Returns the token from the Authorization response header.
  Future<String> login({
    required int clientId,
    required String username,
    required String password,
  }) async {
    final res = await _dio.post(
      '$_base/auth/',
      data: {
        'clientId': clientId,
        'username': username,
        'password': password,
      },
    );
    // Token comes back in the Authorization response header
    if (kDebugMode) {
      debugPrint('LOGIN status: ${res.statusCode}');
      debugPrint('LOGIN headers: ${res.headers.map}');
      debugPrint('LOGIN body: ${res.data}');
    }
    final token = res.headers.value('authorization') ??
        res.headers.value('Authorization') ??
        (res.data is Map ? res.data['token'] : null) ??
        '';
    if (token.isEmpty) throw Exception('No token received from server');
    _setAuth(token);
    return token;
  }

  // ── Own account details ──────────────────────────────────
  Future<OwnDetail> getOwnDetail() async {
    final res = await _dio.get('$_base/ownDetail/');
    return OwnDetail.fromJson(res.data);
  }

  // ── Rich profile (meroShareView/myDetail/{demat}) ────────
  Future<MyDetail> getMyDetail(String demat) async {
    final res = await _dio.get('$_viewBase/myDetail/$demat');
    return MyDetail.fromJson(res.data as Map<String, dynamic>);
  }

  // ── Portfolio / Holdings ─────────────────────────────────
  Future<List<Portfolio>> getPortfolio({
    required String clientCode,
    required String demat,
    int page = 1,
    int size = 200,
  }) async {
    final res = await _dio.post(
      '$_viewBase/myPortfolio/',
      data: {
        'sortBy': 'script',
        'demat': [demat],
        'clientCode': clientCode,
        'page': page,
        'size': size,
        'sortAsc': true,
      },
    );
    final data = res.data;
    final raw = data is Map
        ? (data['meroShareMyPortfolio'] ?? data['object'] ?? [])
        : data;
    final items = raw is List ? raw : [];
    return items.map((e) => Portfolio.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ── Open IPO / Share issues ──────────────────────────────
  Future<List<OpenIssue>> getOpenIssues() async {
    final res = await _dio.post(
      '$_base/companyShare/currentIssue',
      data: {
        'filterFieldParams': [],
        'page': 1,
        'size': 200,
        'searchRoleViewConstants': 'VIEW_OPEN_SHARE',
        'filterDateParams': [],
      },
    );
    final data = res.data;
    final items = (data is Map ? data['object'] ?? [] : data) as List;
    return items.map((e) => OpenIssue.fromJson(e)).toList();
  }

  // ── Applied IPOs ─────────────────────────────────────────
  Future<List<AppliedIpo>> getAppliedIpos({int page = 1, int size = 200}) async {
    final res = await _dio.post(
      '$_base/applicantForm/active/search/',
      data: {
        'filterFieldParams': [
          {'key': 'companyShare.companyIssue.companyISIN.script', 'alias': 'Scrip'},
          {'key': 'companyShare.companyIssue.companyISIN.company.name', 'alias': 'Company Name'},
        ],
        'page': page,
        'size': size,
        'searchRoleViewConstants': 'VIEW_APPLICANT_FORM_COMPLETE',
        'filterDateParams': [
          {'key': 'appliedDate', 'condition': '', 'alias': '', 'value': ''},
        ],
      },
    );
    final data = res.data;
    final items = (data is Map ? data['object'] ?? [] : data) as List;
    final list = items.map((e) => AppliedIpo.fromJson(e)).toList();

    // Fetch detail for each to get real allotment status
    final results = await Future.wait(
      list.map((ipo) => getAppliedDetail(ipo.applicantFormId).then(
        (detail) => ipo.withDetail(
          statusName: detail['statusName'] ?? ipo.statusName,
          receivedKitta: (detail['receivedKitta'] ?? 0) as int,
          appliedKitta: detail['appliedKitta'] is int
              ? detail['appliedKitta'] as int
              : (detail['appliedKitta'] as num?)?.toInt(),
        ),
      ).catchError((_) => ipo)),
    );
    return results;
  }

  Future<Map<String, dynamic>> getAppliedDetail(int applicantFormId) async {
    final res = await _dio.get(
      '$_base/applicantForm/report/detail/$applicantFormId',
    );
    return res.data as Map<String, dynamic>;
  }

  // ── Banks linked to account ──────────────────────────────
  Future<List<BankDetail>> getBankDetails() async {
    final res = await _dio.get('$_base/bank/');
    final data = res.data;
    final raw = data is List
        ? data
        : (data is Map ? (data['object'] ?? data['banks'] ?? []) : []);
    final items = (raw is List ? raw : [raw])
        .whereType<Map>()
        .map((e) => BankDetail.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    // The list endpoint only returns {id, name, branch...}. Fetch per-bank
    // detail to fill in accountNumber / branch / crn.
    final detailed = await Future.wait(items.map((b) async {
      try {
        final r = await _dio.get('$_base/bank/${b.id}');
        final d = r.data;
        final m = d is List && d.isNotEmpty ? d.first : d;
        if (m is Map) {
          final mm = Map<String, dynamic>.from(m);
          return b.copyWith(
            accountNumber:
                (mm['accountNumber'] ?? b.accountNumber) as String? ?? '',
            accountBranch: (mm['accountBranch'] ??
                    mm['branchName'] ??
                    mm['branch'] ??
                    b.accountBranch) as String? ??
                '',
            crn: (mm['crn'] ?? b.crn) as String? ?? '',
          );
        }
      } catch (_) {}
      return b;
    }));
    return detailed;
  }

  // ── Apply for IPO ────────────────────────────────────────
  Future<Map<String, dynamic>> applyIpo({
    required int companyShareId,
    required String crn,
    required String boid,
    required int kitta,
    required String transactionPin,
    required int bankId,
    required String accountNumber,
  }) async {
    final res = await _dio.post(
      '$_base/applicantForm/',
      data: {
        'companyShareId': companyShareId,
        'crn': crn,
        'boid': boid,
        'appliedKitta': kitta,
        'accountTypeId': 1,
        'customerId': 1,
        'demat': boid,
        'transactionPIN': transactionPin,
        'bankId': bankId,
        'accountNumber': accountNumber,
      },
    );
    return res.data is Map ? Map<String, dynamic>.from(res.data) : {};
  }

}
