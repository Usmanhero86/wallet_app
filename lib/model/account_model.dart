class Account {
  final String accountNumber;
  final String accountName;
  final String bankName;
  final String createdAt;

  Account({
    required this.accountNumber,
    required this.accountName,
    required this.bankName,
    required this.createdAt,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accountNumber: json['accountNumber'],
      accountName: json['accountName'],
      bankName: json['bankType'] ?? json['bankName'],
      createdAt: json['createdAt'],
    );
  }
}