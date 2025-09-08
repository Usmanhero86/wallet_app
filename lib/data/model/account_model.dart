class AccountModel {
  final String accountNumber;
  final String accountName;
  final String bankType;
  final String firstName;
  final String surname;
  final String email;
  final DateTime createdAt;

  AccountModel({
    required this.accountNumber,
    required this.accountName,
    required this.bankType,
    required this.firstName,
    required this.surname,
    required this.email,
    required this.createdAt,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      accountNumber: json['accountNumber'] ?? '',
      accountName: json['accountName'] ?? '',
      bankType: json['bankType'] ?? '',
      firstName: json['firstName'] ?? '',
      surname: json['surname'] ?? '',
      email: json['email'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
