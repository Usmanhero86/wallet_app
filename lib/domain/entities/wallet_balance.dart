class WalletBalance {
  final double availableBalance;
  final double ledgerBalance;

  WalletBalance({
    required this.availableBalance,
    required this.ledgerBalance,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      availableBalance: (json['availableBalance'] ?? 0).toDouble(),
      ledgerBalance: (json['ledgerBalance'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'availableBalance': availableBalance,
      'ledgerBalance': ledgerBalance,
    };
  }

  WalletBalance copyWith({
    double? availableBalance,
    double? ledgerBalance,
  }) {
    return WalletBalance(
      availableBalance: availableBalance ?? this.availableBalance,
      ledgerBalance: ledgerBalance ?? this.ledgerBalance,
    );
  }
}
