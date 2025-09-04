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
}

class Data {
  final String accountName;
  final String accountNumber;
  final double balanceAmount;
  final DateTime? transactionDate;

  Data({
    required this.accountName,
    required this.accountNumber,
    required this.balanceAmount,
    this.transactionDate,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      accountName: json['accountName'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      balanceAmount: (json['balanceAmount'] is String)
          ? double.tryParse(json['balanceAmount']) ?? 0
          : (json['balanceAmount'] ?? 0).toDouble(),
      transactionDate: json['transactionDate'] != null && json['transactionDate'] != ''
          ? DateTime.tryParse(json['transactionDate'])
          : null,
    );
  }
}
