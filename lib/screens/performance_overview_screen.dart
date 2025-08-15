import 'package:flutter/material.dart';
import '../models/trade.dart';
import '../models/trade_metrics.dart';
import '../services/database_service.dart';
import '../widgets/metrics_card.dart';
import '../widgets/performance_chart.dart';

class PerformanceOverviewScreen extends StatefulWidget {
  const PerformanceOverviewScreen({super.key});

  @override
  State<PerformanceOverviewScreen> createState() => _PerformanceOverviewScreenState();
}

class _PerformanceOverviewScreenState extends State<PerformanceOverviewScreen> {
  List<Trade> trades = [];
  TradeMetrics? metrics;
  bool isLoading = true;
  String selectedPeriod = 'All Time';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
  setState(() => isLoading = true);
  try {
    List<Trade> loadedTrades = await DatabaseService().getAllTrades();
    
    // Filter trades based on selected period
    loadedTrades = _filterTradesByPeriod(loadedTrades);
    
    final calculatedMetrics = TradeMetrics.fromTrades(loadedTrades);
    
    setState(() {
      trades = loadedTrades;
      metrics = calculatedMetrics;
      isLoading = false;
    });
  } catch (e) {
    setState(() => isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to load trading data. Please try again later.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _loadData,
            ),
          ),
        );
      }
    }
  }

  List<Trade> _filterTradesByPeriod(List<Trade> trades) {
    final now = DateTime.now();
    DateTime cutoffDate;

    switch (selectedPeriod) {
      case '7 Days':
        cutoffDate = now.subtract(const Duration(days: 7));
        break;
      case '30 Days':
        cutoffDate = now.subtract(const Duration(days: 30));
        break;
      case '90 Days':
        cutoffDate = now.subtract(const Duration(days: 90));
        break;
      case '1 Year':
        cutoffDate = now.subtract(const Duration(days: 365));
        break;
      case 'All Time':
      default:
        return trades;
    }

    return trades.where((trade) => trade.date.isAfter(cutoffDate)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : trades.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Period Selector
                        _buildPeriodSelector(),
                        const SizedBox(height: 20),

                        // Performance Chart
                        _buildPerformanceChart(),
                        const SizedBox(height: 20),

                        // Key Metrics
                        _buildKeyMetrics(),
                        const SizedBox(height: 20),

                        // Detailed Statistics
                        _buildDetailedStats(),
                        const SizedBox(height: 20),

                        // Asset Breakdown
                        _buildAssetBreakdown(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Performance Data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add some trades to see your performance analytics.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time Period',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['7 Days', '30 Days', '90 Days', '1 Year', 'All Time']
                    .map((period) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(period),
                            selected: selectedPeriod == period,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  selectedPeriod = period;
                                });
                                _loadData();
                              }
                            },
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cumulative P&L',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: metrics != null && metrics!.chartData.isNotEmpty
                  ? PerformanceChart(chartData: metrics!.chartData)
                  : const Center(
                      child: Text(
                        'Complete some trades to see your performance chart',
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetrics() {
    if (metrics == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Metrics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricsCard(
                title: 'Total P&L',
                value: '${metrics!.totalProfitLoss.toStringAsFixed(2)} USD',
                icon: Icons.account_balance_wallet,
                color: metrics!.totalProfitLoss >= 0 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: MetricsCard(
                title: 'Win Rate',
                value: '${metrics!.winRate.toStringAsFixed(1)}%',
                icon: Icons.trending_up,
                color: metrics!.winRate >= 50 ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: MetricsCard(
                title: 'Total Trades',
                value: '${metrics!.totalTrades}',
                icon: Icons.bar_chart,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: MetricsCard(
                title: 'Avg Profit',
                value: '${metrics!.avgProfitPerTrade.toStringAsFixed(2)} USD',
                icon: Icons.arrow_upward,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailedStats() {
    if (metrics == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detailed Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Winning Trades', '${metrics!.winningTrades}'),
            _buildStatRow('Losing Trades', '${metrics!.losingTrades}'),
            _buildStatRow('Average Loss', '${metrics!.avgLossPerTrade.toStringAsFixed(2)} USD'),
            _buildStatRow('Largest Win', '${metrics!.largestWin.toStringAsFixed(2)} USD'),
            _buildStatRow('Largest Loss', '${metrics!.largestLoss.toStringAsFixed(2)} USD'),
            _buildStatRow('Profit Factor', _calculateProfitFactor().toStringAsFixed(2)),
            _buildStatRow('Risk/Reward Ratio', _calculateRiskRewardRatio().toStringAsFixed(2)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetBreakdown() {
    if (trades.isEmpty) return const SizedBox();

    // Calculate P&L by asset
    Map<String, double> assetPL = {};
    Map<String, int> assetCount = {};

    for (final trade in trades.where((t) => t.isCompleted)) {
      final asset = trade.cryptoAsset;
      final pl = trade.calculateProfitLoss();
      
      assetPL[asset] = (assetPL[asset] ?? 0) + pl;
      assetCount[asset] = (assetCount[asset] ?? 0) + 1;
    }

    final sortedAssets = assetPL.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Asset Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...sortedAssets.take(10).map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${assetCount[entry.key]} trades)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${entry.value >= 0 ? '+' : ''}${entry.value.toStringAsFixed(2)} USD',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: entry.value >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            )),
            if (sortedAssets.length > 10)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '... and ${sortedAssets.length - 10} more assets',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _calculateProfitFactor() {
    if (metrics == null || metrics!.avgLossPerTrade == 0) return 0;
    return (metrics!.avgProfitPerTrade * metrics!.winningTrades) / 
           (metrics!.avgLossPerTrade * metrics!.losingTrades);
  }

  double _calculateRiskRewardRatio() {
    if (metrics == null || metrics!.avgLossPerTrade == 0) return 0;
    return metrics!.avgProfitPerTrade / metrics!.avgLossPerTrade;
  }
}