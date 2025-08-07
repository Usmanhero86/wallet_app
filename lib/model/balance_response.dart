class BalanceResponse {
  final String code;
  final Data data;
  final String description;
  final String status;

  BalanceResponse({
    required this.code,
    required this.data,
    required this.description,
    required this.status,
  });

  factory BalanceResponse.fromJson(Map<String, dynamic> json) {
    return BalanceResponse(
      code: json['code'] ?? '',
      data: Data.fromJson(json['data'] ?? {}),
      description: json['description'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'data': data.toJson(),
      'description': description,
      'status': status,
    };
  }
}

class Data {
  final String accountName;
  final String accountNumber;
  final int balanceAmount;
  final String transactionDate;

  Data({
    required this.accountName,
    required this.accountNumber,
    required this.balanceAmount,
    required this.transactionDate,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      accountName: json['accountName'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      balanceAmount: json['balanceAmount'] ?? 0,
      transactionDate: json['transactionDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountName': accountName,
      'accountNumber': accountNumber,
      'balanceAmount': balanceAmount,
      'transactionDate': transactionDate,
    };
  }
}
