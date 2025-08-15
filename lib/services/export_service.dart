import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/trade.dart';

class ExportService {
  static Future<bool> exportTradesToCSV(List<Trade> trades) async {
    try {
      if (trades.isEmpty) return false;

      // Prepare CSV data
      List<List<dynamic>> csvData = [];
      
      // Add headers
      csvData.add([
        'Date',
        'Crypto Asset',
        'Trade Type',
        'Amount',
        'Entry Price',
        'Exit Price',
        'Currency',
        'Profit/Loss',
        'Status',
        'Rationale',
      ]);

      // Add trade data
      for (final trade in trades) {
        csvData.add([
          DateFormat('yyyy-MM-dd HH:mm:ss').format(trade.date),
          trade.cryptoAsset,
          trade.tradeType,
          trade.amount,
          trade.entryPrice,
          trade.exitPrice ?? '',
          trade.currency,
          trade.isCompleted ? trade.calculateProfitLoss().toStringAsFixed(2) : '',
          trade.statusText,
          trade.rationale ?? '',
        ]);
      }

      // Convert to CSV string
      String csvString = const ListToCsvConverter().convert(csvData);

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/trades_export_$timestamp.csv');

      // Write CSV file
      await file.writeAsString(csvString);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Trade Trackr - Exported Trades',
        subject: 'Trading Data Export',
      );

      return true;
    } catch (e) {
      throw Exception('Failed to export trades: $e');
    }
  }

  static Future<File> createCSVFile(List<Trade> trades) async {
    List<List<dynamic>> csvData = [];
    
    // Add headers
    csvData.add([
      'Date',
      'Crypto Asset',
      'Trade Type',
      'Amount',
      'Entry Price',
      'Exit Price',
      'Currency',
      'Profit/Loss',
      'Status',
      'Rationale',
    ]);

    // Add trade data
    for (final trade in trades) {
      csvData.add([
        DateFormat('yyyy-MM-dd HH:mm:ss').format(trade.date),
        trade.cryptoAsset,
        trade.tradeType,
        trade.amount,
        trade.entryPrice,
        trade.exitPrice ?? '',
        trade.currency,
        trade.isCompleted ? trade.calculateProfitLoss().toStringAsFixed(2) : '',
        trade.statusText,
        trade.rationale ?? '',
      ]);
    }

    // Convert to CSV string
    String csvString = const ListToCsvConverter().convert(csvData);

    // Get documents directory
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/trades_export_$timestamp.csv');

    // Write CSV file
    await file.writeAsString(csvString);

    return file;
  }

  static String formatTradeForEmail(List<Trade> trades) {
    if (trades.isEmpty) return 'No trades to export.';

    StringBuffer buffer = StringBuffer();
    buffer.writeln('Trade Trackr - Trading Summary');
    buffer.writeln('Generated: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
    buffer.writeln('');

    // Calculate summary
    final completedTrades = trades.where((t) => t.isCompleted).toList();
    final totalPL = completedTrades.fold<double>(
      0, 
      (sum, trade) => sum + trade.calculateProfitLoss()
    );
    final wins = completedTrades.where((t) => t.calculateProfitLoss() > 0).length;
    final losses = completedTrades.where((t) => t.calculateProfitLoss() < 0).length;
    final winRate = completedTrades.isNotEmpty 
        ? (wins / completedTrades.length) * 100 
        : 0.0;

    buffer.writeln('SUMMARY');
    buffer.writeln('Total Trades: ${trades.length}');
    buffer.writeln('Completed Trades: ${completedTrades.length}');
    buffer.writeln('Win Rate: ${winRate.toStringAsFixed(1)}%');
    buffer.writeln('Total P&L: ${totalPL.toStringAsFixed(2)} USD');
    buffer.writeln('');

    buffer.writeln('TRADE DETAILS');
    buffer.writeln('Date\t\tAsset\tType\tAmount\tEntry\tExit\tP&L');
    buffer.writeln('-' * 70);

    for (final trade in trades) {
      final dateStr = DateFormat('yyyy-MM-dd').format(trade.date);
      final pl = trade.isCompleted 
          ? trade.calculateProfitLoss().toStringAsFixed(2)
          : 'Open';
      
      buffer.writeln(
        '$dateStr\t${trade.cryptoAsset}\t${trade.tradeType}\t${trade.amount}\t${trade.entryPrice}\t${trade.exitPrice ?? 'N/A'}\t$pl'
      );
    }

    return buffer.toString();
  }
}