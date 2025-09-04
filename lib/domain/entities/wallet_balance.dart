class WalletBalance {
  final double balanceAmount;
  final String currency;

  WalletBalance({
    required this.balanceAmount,
    required this.currency,
  });

  // ✅ Add copyWith
  WalletBalance copyWith({
    double? balanceAmount,
    String? currency,
  }) {
    return WalletBalance(
      balanceAmount: balanceAmount ?? this.balanceAmount,
      currency: currency ?? this.currency,
    );
  }

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      balanceAmount: (json['balanceAmount'] as num).toDouble(),
      currency: json['currency'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balanceAmount': balanceAmount,
      'currency': currency,
    };
  }
}
