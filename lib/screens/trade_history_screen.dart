import 'package:flutter/material.dart';
import '../models/trade.dart';
import '../services/database_service.dart';
import '../services/export_service.dart';
import '../widgets/trade_card.dart';
import 'add_trade_screen.dart';

class TradeHistoryScreen extends StatefulWidget {
  const TradeHistoryScreen({super.key});

  @override
  State<TradeHistoryScreen> createState() => _TradeHistoryScreenState();
}

class _TradeHistoryScreenState extends State<TradeHistoryScreen> {
  List<Trade> trades = [];
  List<Trade> filteredTrades = [];
  bool isLoading = true;
  String? selectedAsset;
  String? selectedType;
  String sortBy = 'date'; // 'date', 'asset', 'profitLoss'
  bool sortAscending = false;

  @override
  void initState() {
    super.initState();
    _loadTrades();
  }

  Future<void> _loadTrades() async {
    setState(() => isLoading = true);
    try {
      final loadedTrades = await DatabaseService().getAllTrades();
      setState(() {
        trades = loadedTrades;
        filteredTrades = loadedTrades;
        isLoading = false;
      });
      _applySortAndFilter();
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading trades: $e')),
        );
      }
    }
  }

  void _applySortAndFilter() {
    List<Trade> result = List.from(trades);

    // Apply filters
    if (selectedAsset != null) {
      result = result.where((trade) => trade.cryptoAsset == selectedAsset).toList();
    }
    if (selectedType != null) {
      result = result.where((trade) => trade.tradeType == selectedType).toList();
    }

    // Apply sorting
    result.sort((a, b) {
      int comparison = 0;
      switch (sortBy) {
        case 'date':
          comparison = a.date.compareTo(b.date);
          break;
        case 'asset':
          comparison = a.cryptoAsset.compareTo(b.cryptoAsset);
          break;
        case 'profitLoss':
          final apl = a.calculateProfitLoss();
          final bpl = b.calculateProfitLoss();
          comparison = apl.compareTo(bpl);
          break;
      }
      return sortAscending ? comparison : -comparison;
    });

    setState(() {
      filteredTrades = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: trades.isNotEmpty ? _exportData : null,
            tooltip: 'Export CSV',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTrades,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters and Sort Controls
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Filter Row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        value: selectedAsset,
                        decoration: const InputDecoration(
                          labelText: 'Filter by Asset',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All Assets'),
                          ),
                          ...trades
                              .map((trade) => trade.cryptoAsset)
                              .toSet()
                              .map((asset) => DropdownMenuItem(
                                    value: asset,
                                    child: Text(asset),
                                  )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedAsset = value;
                          });
                          _applySortAndFilter();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        value: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Filter by Type',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: const [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All Types'),
                          ),
                          DropdownMenuItem(
                            value: 'Buy',
                            child: Text('Buy'),
                          ),
                          DropdownMenuItem(
                            value: 'Sell',
                            child: Text('Sell'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedType = value;
                          });
                          _applySortAndFilter();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Sort Row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: sortBy,
                        decoration: const InputDecoration(
                          labelText: 'Sort by',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'date', child: Text('Date')),
                          DropdownMenuItem(value: 'asset', child: Text('Asset')),
                          DropdownMenuItem(value: 'profitLoss', child: Text('P&L')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            sortBy = value!;
                          });
                          _applySortAndFilter();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilterChip(
                      label: Text(sortAscending ? 'Ascending' : 'Descending'),
                      selected: true,
                      onSelected: (selected) {
                        setState(() {
                          sortAscending = !sortAscending;
                        });
                        _applySortAndFilter();
                      },
                      avatar: Icon(
                        sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                
                // Clear filters button
                if (selectedAsset != null || selectedType != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          selectedAsset = null;
                          selectedType = null;
                        });
                        _applySortAndFilter();
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear Filters'),
                    ),
                  ),
              ],
            ),
          ),
          
          // Trade List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTrades.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadTrades,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredTrades.length,
                          itemBuilder: (context, index) {
                            final trade = filteredTrades[index];
                            return TradeCard(
                              trade: trade,
                              onTap: () => _editTrade(trade),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTrade(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasFilters = selectedAsset != null || selectedType != null;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.filter_alt_off : Icons.history,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'No trades match your filters' : 'No trades yet',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters 
                  ? 'Try adjusting your filters to see more trades.'
                  : 'Start by adding your first trade to see it here.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (!hasFilters)
              FilledButton.icon(
                onPressed: () => _navigateToAddTrade(),
                icon: const Icon(Icons.add),
                label: const Text('Add Trade'),
              )
            else
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedAsset = null;
                    selectedType = null;
                  });
                  _applySortAndFilter();
                },
                child: const Text('Clear Filters'),
              ),
          ],
        ),
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
  }

  Future<void> _editTrade(Trade trade) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTradeScreen(trade: trade),
      ),
    );

    if (result == true) {
      _loadTrades();
    }
  }

  Future<void> _exportData() async {
    try {
      final success = await ExportService.exportTradesToCSV(filteredTrades);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success 
                ? 'Trades exported successfully!' 
                : 'Export cancelled'),
            backgroundColor: success ? Colors.green : null,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }
}