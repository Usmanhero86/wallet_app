class AccountResponse {
  final String accountNumber;
  final String accountName;
  final String? bankName; // Optional field

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

// models/account_model.dart
class Account {
  final String accountNumber;
  final String accountName;
  final String bankType;
  final String firstName;
  final String surname;
  final String email;
  final DateTime createdAt;

  Account({
    required this.accountNumber,
    required this.accountName,
    required this.bankType,
    required this.firstName,
    required this.surname,
    required this.email,
    required this.createdAt,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accountNumber: json['accountNumber'] ?? '',
      accountName: json['accountName'] ?? '',
      bankType: json['bankType'] ?? '',
      firstName: json['firstName'] ?? '',
      surname: json['surname'] ?? '',
      email: json['email'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
    );
  }
}