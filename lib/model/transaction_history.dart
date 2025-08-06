class TransactionHistoryResponse {
  final String code;
  final String description;
  final String status;
  final List<TransactionItem> data;

  TransactionHistoryResponse({
    required this.code,
    required this.description,
    required this.status,
    required this.data,
  });

  factory TransactionHistoryResponse.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryResponse(
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => TransactionItem.fromJson(item))
          .toList() ??
          [],
    );
  }
}

class TransactionItem {
  final String accountNumber;
  final String destinationAccountNumber;
  final int amount;
  final int balance;
  final String narration;
  final DateTime transactionDate;
  final String transactionRef;
  final String transactionType;

  TransactionItem({
    required this.accountNumber,
    required this.destinationAccountNumber,
    required this.amount,
    required this.balance,
    required this.narration,
    required this.transactionDate,
    required this.transactionRef,
    required this.transactionType,
  });
  Map<String, dynamic> toJson() {
    return {
      'accountNumber': accountNumber,
      'destinationAccountNumber': destinationAccountNumber,
      'amount': amount,
      'balance': balance,
      'narration': narration,
      'transactionDate': transactionDate.toIso8601String(),
      'transactionRef': transactionRef,
      'transactionType': transactionType,
    };
  }
  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      accountNumber: json['accountNumber'] ?? '',
      destinationAccountNumber: json['destinationAccountNumber'] ?? '',
      amount: json['amount'] ?? 0,
      balance: json['balance'] ?? 0,
      narration: json['narration'] ?? '',
      transactionDate: DateTime.parse(json['transactionDate'] ?? DateTime.now().toIso8601String()),
      transactionRef: json['transactionRef'] ?? '',
      transactionType: json['transactionType'] ?? '',
    );
  }
}