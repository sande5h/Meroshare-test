class CapitalItem {
  final int id;
  final String name;
  const CapitalItem({required this.id, required this.name});

  factory CapitalItem.fromJson(Map<String, dynamic> j) =>
      CapitalItem(id: j['id'], name: j['name']);
}

class AuthState {
  final String token;
  final String name;
  final String demat;
  final String clientId;
  final String email;

  const AuthState({
    required this.token,
    required this.name,
    required this.demat,
    required this.clientId,
    required this.email,
  });

  factory AuthState.fromJson(Map<String, dynamic> j) => AuthState(
        token: j['token'] ?? '',
        name: j['name'] ?? '',
        demat: j['demat'] ?? '',
        clientId: j['clientId']?.toString() ?? '',
        email: j['email'] ?? '',
      );
}

class OwnDetail {
  final String name;
  final String email;
  final String contact;
  final String boid;
  final String demat;
  final String clientCode;
  final String dpName;
  final String gender;
  final String address;

  const OwnDetail({
    required this.name,
    required this.email,
    required this.contact,
    required this.boid,
    required this.demat,
    required this.clientCode,
    required this.dpName,
    required this.gender,
    required this.address,
  });

  OwnDetail copyWith({String? dpName}) => OwnDetail(
        name: name,
        email: email,
        contact: contact,
        boid: boid,
        demat: demat,
        clientCode: clientCode,
        dpName: dpName ?? this.dpName,
        gender: gender,
        address: address,
      );

  factory OwnDetail.fromJson(Map<String, dynamic> j) => OwnDetail(
        name: j['name'] ?? '',
        email: j['meroShareEmail'] ?? j['email'] ?? '',
        contact: j['contact'] ?? j['mobileNumber'] ?? '',
        boid: j['boid'] ?? '',
        demat: j['demat'] ?? '',
        clientCode: j['clientCode']?.toString() ?? '',
        dpName: j['dpName'] ?? j['profileName'] ?? '',
        gender: j['gender'] ?? '',
        address: j['address'] ?? '',
      );
}

class MyDetail {
  final String boid;
  final String name;
  final String email;
  final String contact;
  final String address;
  final String gender;
  final String dob;
  final String dpName;
  final String capital;
  final String accountNumber;
  final String accountType;
  final String accountStatusFlag;
  final String accountOpenDate;
  final String bankName;
  final String bankCode;
  final String branchCode;
  final String citizenshipNumber;
  final String citizenCode;
  final String issuedFrom;
  final String issuedDate;
  final String fatherMotherName;
  final String grandfatherSpouseName;
  final String subStatus;

  const MyDetail({
    required this.boid,
    required this.name,
    required this.email,
    required this.contact,
    required this.address,
    required this.gender,
    required this.dob,
    required this.dpName,
    required this.capital,
    required this.accountNumber,
    required this.accountType,
    required this.accountStatusFlag,
    required this.accountOpenDate,
    required this.bankName,
    required this.bankCode,
    required this.branchCode,
    required this.citizenshipNumber,
    required this.citizenCode,
    required this.issuedFrom,
    required this.issuedDate,
    required this.fatherMotherName,
    required this.grandfatherSpouseName,
    required this.subStatus,
  });

  factory MyDetail.fromJson(Map<String, dynamic> j) => MyDetail(
        boid: j['boid']?.toString() ?? '',
        name: j['name'] ?? '',
        email: j['email'] ?? '',
        contact: j['contact'] ?? '',
        address: j['address'] ?? '',
        gender: j['gender'] ?? '',
        dob: j['dob']?.toString() ?? '',
        dpName: j['dpName'] ?? '',
        capital: j['capital']?.toString() ?? '',
        accountNumber: j['accountNumber']?.toString() ?? '',
        accountType: j['accountType'] ?? '',
        accountStatusFlag: j['accountStatusFlag'] ?? '',
        accountOpenDate: j['aod']?.toString() ?? j['accountOpenDate']?.toString() ?? '',
        bankName: j['bankName'] ?? '',
        bankCode: j['bankCode']?.toString() ?? '',
        branchCode: j['branchCode']?.toString() ?? '',
        citizenshipNumber: j['citizenshipNumber']?.toString() ?? '',
        citizenCode: j['citizenCode']?.toString() ?? '',
        issuedFrom: j['issuedFrom'] ?? '',
        issuedDate: j['issuedDate']?.toString() ?? '',
        fatherMotherName: j['fatherMotherName'] ?? '',
        grandfatherSpouseName: j['grandfatherSpouseName'] ?? '',
        subStatus: j['subStatus'] ?? '',
      );
}

double _d(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

int _i(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

class Portfolio {
  final String script;
  final String scriptDesc;
  final double currentBalance;
  final double previousClosingPrice;
  final double lastTransactionPrice;
  final double valueOfLastTransPrice;
  final double valueOfPrevClosingPrice;

  const Portfolio({
    required this.script,
    required this.scriptDesc,
    required this.currentBalance,
    required this.previousClosingPrice,
    required this.lastTransactionPrice,
    required this.valueOfLastTransPrice,
    required this.valueOfPrevClosingPrice,
  });

  double get pl => valueOfLastTransPrice - valueOfPrevClosingPrice;
  bool get isProfit => valueOfLastTransPrice >= valueOfPrevClosingPrice;

  factory Portfolio.fromJson(Map<String, dynamic> j) => Portfolio(
        script: j['script'] ?? '',
        scriptDesc: j['scriptDesc'] ?? '',
        currentBalance: _d(j['currentBalance']),
        previousClosingPrice: _d(j['previousClosingPrice']),
        lastTransactionPrice: _d(j['lastTransactionPrice']),
        valueOfLastTransPrice: _d(j['valueOfLastTransPrice']),
        valueOfPrevClosingPrice: _d(j['valueOfPrevClosingPrice']),
      );
}

class OpenIssue {
  final int id;
  final String companyName;
  final String scrip;
  final String shareTypeName;
  final String shareGroupName;
  final double minUnit;
  final String issueOpenDate;
  final String issueCloseDate;
  final double issuePrice;
  final String status;

  const OpenIssue({
    required this.id,
    required this.companyName,
    required this.scrip,
    required this.shareTypeName,
    required this.shareGroupName,
    required this.minUnit,
    required this.issueOpenDate,
    required this.issueCloseDate,
    required this.issuePrice,
    required this.status,
  });

  factory OpenIssue.fromJson(Map<String, dynamic> j) => OpenIssue(
        id: _i(j['companyShareId'] ?? j['id']),
        companyName: j['companyName'] ?? '',
        scrip: j['scrip'] ?? '',
        shareTypeName: j['shareTypeName'] ?? '',
        shareGroupName: j['shareGroupName'] ?? '',
        minUnit: _d(j['minUnit'] ?? 10),
        issueOpenDate: j['issueOpenDate']?.toString() ?? '',
        issueCloseDate: j['issueCloseDate']?.toString() ?? '',
        issuePrice: _d(j['issuePrice'] ?? 100),
        status: j['action'] ?? 'Apply',
      );
}

class AppliedIpo {
  final int id;
  final int applicantFormId;
  final String companyName;
  final String scrip;
  final String shareTypeName;
  final int appliedKitta;
  final int receivedKitta;
  final String statusName;
  final String appliedDate;

  const AppliedIpo({
    required this.id,
    required this.applicantFormId,
    required this.companyName,
    required this.scrip,
    required this.shareTypeName,
    required this.appliedKitta,
    required this.receivedKitta,
    required this.statusName,
    required this.appliedDate,
  });

  bool get isAllotted => statusName.toLowerCase() == 'alloted' ||
      statusName.toLowerCase() == 'allotted';

  AppliedIpo withDetail({
    required String statusName,
    required int receivedKitta,
    int? appliedKitta,
  }) =>
      AppliedIpo(
        id: id,
        applicantFormId: applicantFormId,
        companyName: companyName,
        scrip: scrip,
        shareTypeName: shareTypeName,
        appliedKitta: appliedKitta ?? this.appliedKitta,
        receivedKitta: receivedKitta,
        statusName: statusName,
        appliedDate: appliedDate,
      );

  factory AppliedIpo.fromJson(Map<String, dynamic> j) => AppliedIpo(
        id: j['companyShareId'] ?? 0,
        applicantFormId: j['applicantFormId'] ?? 0,
        companyName: j['companyName'] ?? '',
        scrip: j['scrip'] ?? '',
        shareTypeName: j['shareTypeName'] ?? '',
        appliedKitta: (j['appliedKitta'] ?? j['noOfUnit'] ?? 0) as int,
        receivedKitta: 0,
        statusName: j['statusName'] ?? j['status'] ?? '',
        appliedDate: j['appliedDate'] ?? '',
      );
}

class BankDetail {
  final int id;
  final String bankName;
  final String accountNumber;
  final String accountBranch;
  final String crn;
  final int? customerId;
  final int? accountBranchId;
  final int? accountTypeId;

  const BankDetail({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.accountBranch,
    required this.crn,
    this.customerId,
    this.accountBranchId,
    this.accountTypeId,
  });

  factory BankDetail.fromJson(Map<String, dynamic> j) => BankDetail(
        id: (j['id'] ?? 0) as int,
        bankName: (j['bankName'] ?? j['name'] ?? '') as String,
        accountNumber: (j['accountNumber'] ?? '') as String,
        accountBranch:
            (j['accountBranch'] ?? j['branchName'] ?? j['branch'] ?? '') as String,
        crn: (j['crn'] ?? '') as String,
      );

  BankDetail copyWith({
    String? bankName,
    String? accountNumber,
    String? accountBranch,
    String? crn,
    int? customerId,
    int? accountBranchId,
    int? accountTypeId,
  }) =>
      BankDetail(
        id: id,
        bankName: bankName ?? this.bankName,
        accountNumber: accountNumber ?? this.accountNumber,
        accountBranch: accountBranch ?? this.accountBranch,
        crn: crn ?? this.crn,
        customerId: customerId ?? this.customerId,
        accountBranchId: accountBranchId ?? this.accountBranchId,
        accountTypeId: accountTypeId ?? this.accountTypeId,
      );
}
