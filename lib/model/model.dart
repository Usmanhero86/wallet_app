class VirtualAccountResponse {
  final String code;
  final String description;
  final String status;
  final String bankName;
  final String accountName;
  final String accountNumber;

  VirtualAccountResponse({
    required this.code,
    required this.description,
    required this.status,
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
  });

  factory VirtualAccountResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return VirtualAccountResponse(
      code: json['code'],
      description: json['description'],
      status: json['status'],
      bankName: data['bankName'] ?? '',
      accountName: data['accountName'] ?? '',
      accountNumber: data['accountNumber'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'accountName': accountName,
      'accountNumber': accountNumber,
      'bankName': bankName,
    };
  }

}