class BalanceResponse {
  final String code;
  final String description;
  final String status;
  final String bankType;
  final String accountName;
  final String accountNumber;
  final String bankCode;
  final double balanceAmount;
  final DateTime transactionDate;

  BalanceResponse({
    required this.code,
    required this.description,
    required this.status,
    required this.bankType,
    required this.accountName,
    required this.accountNumber,
    required this.bankCode,
    required this.balanceAmount,
    required this.transactionDate,
  });

  factory BalanceResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return BalanceResponse(
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      bankType: data['bankType'] ?? '',
      accountName: data['accountName'] ?? '',
      accountNumber: data['accountNumber'] ?? '',
      bankCode: data['bankCode'] ?? '',
      balanceAmount: (data['balanceAmount'] ?? 0).toDouble(),
      transactionDate: DateTime.parse(data['transactionDate'] ?? DateTime.now().toIso8601String()),
    );
  }
}