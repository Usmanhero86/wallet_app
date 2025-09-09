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
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => TransactionItem.fromJson(item))
          .toList(),
    );
  }
}

class TransactionItem {
  final String accountNumber;
  final String destinationAccountNumber;
  final double amount;
  final double balance;
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

  /// Helper for safe number parsing
  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      accountNumber: json['accountNumber'] ?? '',
      destinationAccountNumber: json['destinationAccountNumber'] ?? '',
      amount: _parseToDouble(json['amount']),
      balance: _parseToDouble(json['balance']),
      narration: json['narration'] ?? '',
      transactionDate: DateTime.tryParse(json['transactionDate'] ?? '') ??
          DateTime(2000, 1, 1), // ✅ safer fallback
      transactionRef: json['transactionRef'] ?? '',
      transactionType: json['transactionType'] ?? '',
    );
  }

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
}
