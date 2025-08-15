import 'package:flutter/material.dart';
import '../models/trade.dart';
import '../models/trade_metrics.dart';
import '../services/database_service.dart';
import '../widgets/metrics_card.dart';
import '../widgets/performance_chart.dart';
import 'add_trade_screen.dart';
import 'trade_history_screen.dart';
import 'performance_overview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Trade> trades = [];
  TradeMetrics? metrics;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrades();
  }

  Future<void> _loadTrades() async {
    setState(() => isLoading = true);
    try {
      final loadedTrades = await DatabaseService().getAllTrades();
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
          SnackBar(content: Text('Error loading trades: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trade Trackr',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTrades,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTrades,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : trades.isEmpty
                ? _buildEmptyState()
                : _buildHomeContent(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddTrade(),
        icon: const Icon(Icons.add),
        label: const Text('Add Trade'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Performance',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TradeHistoryScreen(),
                ),
              ).then((_) => _loadTrades());
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PerformanceOverviewScreen(),
                ),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up,
              size: 120,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Start Your Trading Journey',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Log your first trade to begin tracking your performance and improving your trading strategies.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _navigateToAddTrade(),
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Trade'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats
          Text(
            'Quick Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (metrics != null) ...[
            Row(
              children: [
                Expanded(
                  child: MetricsCard(
                    title: 'Total P&L',
                    value: '${metrics!.totalProfitLoss.toStringAsFixed(2)} USD',
                    icon: Icons.account_balance_wallet,
                    color: metrics!.totalProfitLoss >= 0
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MetricsCard(
                    title: 'Win Rate',
                    value: '${metrics!.winRate.toStringAsFixed(1)}%',
                    icon: Icons.trending_up,
                    color: metrics!.winRate >= 50
                        ? Colors.green
                        : Colors.orange,
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
          
          const SizedBox(height: 24),
          
          // Performance Chart
          Text(
            'Performance Trend',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              child: metrics != null && metrics!.chartData.isNotEmpty
                  ? PerformanceChart(chartData: metrics!.chartData)
                  : const Center(
                      child: Text(
                        'Complete some trades to see your performance chart',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Recent Trades
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Trades',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TradeHistoryScreen(),
                    ),
                  ).then((_) => _loadTrades());
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Show last 3 trades
          ...trades.take(3).map((trade) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: trade.tradeType == 'Buy' 
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                child: Icon(
                  trade.tradeType == 'Buy' 
                      ? Icons.trending_up 
                      : Icons.trending_down,
                  color: trade.tradeType == 'Buy' 
                      ? Colors.green 
                      : Colors.red,
                ),
              ),
              title: Text(
                '${trade.tradeType} ${trade.cryptoAsset}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                '${trade.amount} at ${trade.entryPrice} ${trade.currency}',
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (trade.isCompleted)
                    Text(
                      '${trade.calculateProfitLoss() >= 0 ? '+' : ''}${trade.calculateProfitLoss().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: trade.calculateProfitLoss() >= 0 
                            ? Colors.green 
                            : Colors.red,
                      ),
                    )
                  else
                    const Text(
                      'Open',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  Text(
                    trade.statusText,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          )),
          
          const SizedBox(height: 100), // Space for FAB
        ],
      ),
    );
  }

  Future<void> _navigateToAddTrade() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTradeScreen(),
      ),
    );
    
    if (result == true) {
      _loadTrades();
    }
  });