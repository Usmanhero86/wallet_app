class AccountResponse {
  final String accountNumber;
  final String accountName;
  final String? bankName;

  AccountResponse({
    required this.accountNumber,
    required this.accountName,
    this.bankName,
  });

  factory AccountResponse.fromJson(Map<String, dynamic> json) {
    return AccountResponse(
      accountNumber: json['accountNumber'] ?? '',
      accountName: json['accountName'] ?? '',
      bankName: json['bankName'] ?? json['bankType'],
    );
  }
}


