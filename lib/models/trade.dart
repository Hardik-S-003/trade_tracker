class Trade {
  final int? id;
  final String cryptoAsset;
  final String tradeType; // 'Buy' or 'Sell'
  final double amount;
  final double entryPrice;
  final double? exitPrice;
  final String currency;
  final DateTime date;
  final String? rationale;
  final String? imagePath;
  final double? profitLoss;

  Trade({
    this.id,
    required this.cryptoAsset,
    required this.tradeType,
    required this.amount,
    required this.entryPrice,
    this.exitPrice,
    required this.currency,
    required this.date,
    this.rationale,
    this.imagePath,
    this.profitLoss,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cryptoAsset': cryptoAsset,
      'tradeType': tradeType,
      'amount': amount,
      'entryPrice': entryPrice,
      'exitPrice': exitPrice,
      'currency': currency,
      'date': date.toIso8601String(),
      'rationale': rationale,
      'imagePath': imagePath,
      'profitLoss': profitLoss,
    };
  }

  factory Trade.fromMap(Map<String, dynamic> map) {
    return Trade(
      id: map['id'],
      cryptoAsset: map['cryptoAsset'],
      tradeType: map['tradeType'],
      amount: map['amount'].toDouble(),
      entryPrice: map['entryPrice'].toDouble(),
      exitPrice: map['exitPrice']?.toDouble(),
      currency: map['currency'],
      date: DateTime.parse(map['date']),
      rationale: map['rationale'],
      imagePath: map['imagePath'],
      profitLoss: map['profitLoss']?.toDouble(),
    );
  }

  Trade copyWith({
    int? id,
    String? cryptoAsset,
    String? tradeType,
    double? amount,
    double? entryPrice,
    double? exitPrice,
    String? currency,
    DateTime? date,
    String? rationale,
    String? imagePath,
    double? profitLoss,
  }) {
    return Trade(
      id: id ?? this.id,
      cryptoAsset: cryptoAsset ?? this.cryptoAsset,
      tradeType: tradeType ?? this.tradeType,
      amount: amount ?? this.amount,
      entryPrice: entryPrice ?? this.entryPrice,
      exitPrice: exitPrice ?? this.exitPrice,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      rationale: rationale ?? this.rationale,
      imagePath: imagePath ?? this.imagePath,
      profitLoss: profitLoss ?? this.profitLoss,
    );
  }

  double calculateProfitLoss() {
    if (exitPrice == null) return 0.0;
    
    if (tradeType == 'Buy') {
      return (exitPrice! - entryPrice) * amount;
    } else {
      return (entryPrice - exitPrice!) * amount;
    }
  }

  bool get isCompleted => exitPrice != null;
  
  String get statusText => isCompleted ? 'Closed' : 'Open';
}