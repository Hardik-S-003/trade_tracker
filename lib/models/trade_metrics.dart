import 'trade.dart';

class TradeMetrics {
  final double totalProfitLoss;
  final double winRate;
  final double avgProfitPerTrade;
  final double avgLossPerTrade;
  final int totalTrades;
  final int winningTrades;
  final int losingTrades;
  final double largestWin;
  final double largestLoss;
  final List<ChartPoint> chartData;

  TradeMetrics({
    required this.totalProfitLoss,
    required this.winRate,
    required this.avgProfitPerTrade,
    required this.avgLossPerTrade,
    required this.totalTrades,
    required this.winningTrades,
    required this.losingTrades,
    required this.largestWin,
    required this.largestLoss,
    required this.chartData,
  });

  factory TradeMetrics.fromTrades(List<Trade> trades) {
    if (trades.isEmpty) {
      return TradeMetrics(
        totalProfitLoss: 0,
        winRate: 0,
        avgProfitPerTrade: 0,
        avgLossPerTrade: 0,
        totalTrades: 0,
        winningTrades: 0,
        losingTrades: 0,
        largestWin: 0,
        largestLoss: 0,
        chartData: [],
      );
    }

    // Filter completed trades
    final completedTrades = trades.where((t) => t.isCompleted).toList();
    
    if (completedTrades.isEmpty) {
      return TradeMetrics(
        totalProfitLoss: 0,
        winRate: 0,
        avgProfitPerTrade: 0,
        avgLossPerTrade: 0,
        totalTrades: trades.length,
        winningTrades: 0,
        losingTrades: 0,
        largestWin: 0,
        largestLoss: 0,
        chartData: [],
      );
    }

    // Sort trades by date
    completedTrades.sort((a, b) => a.date.compareTo(b.date));

    // Calculate metrics
    double totalPL = 0;
    int wins = 0;
    int losses = 0;
    double totalWinAmount = 0;
    double totalLossAmount = 0;
    double largestWin = 0;
    double largestLoss = 0;
    
    List<ChartPoint> chartData = [];
    double cumulativePL = 0;

    for (int i = 0; i < completedTrades.length; i++) {
      final trade = completedTrades[i];
      final pl = trade.calculateProfitLoss();
      
      totalPL += pl;
      cumulativePL += pl;
      
      // Add point to chart data
      chartData.add(ChartPoint(
        x: i.toDouble(),
        y: cumulativePL,
        date: trade.date,
      ));
      
      if (pl > 0) {
        wins++;
        totalWinAmount += pl;
        if (pl > largestWin) largestWin = pl;
      } else if (pl < 0) {
        losses++;
        totalLossAmount += pl.abs();
        if (pl < largestLoss) largestLoss = pl;
      }
    }

    final winRate = completedTrades.isNotEmpty ? (wins / completedTrades.length) * 100 : 0.0;
    final avgProfit = wins > 0 ? totalWinAmount / wins : 0.0;
    final avgLoss = losses > 0 ? totalLossAmount / losses : 0.0;

    return TradeMetrics(
      totalProfitLoss: totalPL,
      winRate: winRate,
      avgProfitPerTrade: avgProfit,
      avgLossPerTrade: avgLoss,
      totalTrades: trades.length,
      winningTrades: wins,
      losingTrades: losses,
      largestWin: largestWin,
      largestLoss: largestLoss,
      chartData: chartData,
    );
  }
}

class ChartPoint {
  final double x;
  final double y;
  final DateTime date;

  ChartPoint({
    required this.x,
    required this.y,
    required this.date,
  });
}