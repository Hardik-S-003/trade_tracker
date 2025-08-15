import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'constants.dart';

class Helpers {
  // Date formatting helpers
  static String formatDate(DateTime date) {
    return DateFormat(AppConstants.displayDateFormat).format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat(AppConstants.displayDateTimeFormat).format(date);
  }

  static String formatDateForExport(DateTime date) {
    return DateFormat(AppConstants.dateTimeFormat).format(date);
  }

  // Currency formatting helpers
  static String formatCurrency(double amount, String currency) {
    final formatter = NumberFormat.currency(
      symbol: _getCurrencySymbol(currency),
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String formatCurrencyCompact(double amount, String currency) {
    if (amount.abs() >= 1000000) {
      return '${_getCurrencySymbol(currency)}${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000) {
      return '${_getCurrencySymbol(currency)}${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return formatCurrency(amount, currency);
    }
  }

  static String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'INR':
        return '₹';
      case 'CNY':
        return '¥';
      case 'KRW':
        return '₩';
      default:
        return currency;
    }
  }

  // Number formatting helpers
  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  static String formatLargeNumber(double number) {
    if (number.abs() >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number.abs() >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number.abs() >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toStringAsFixed(2);
    }
  }

  // Color helpers
  static Color getProfitLossColor(double value) {
    if (value > 0) {
      return const Color(AppConstants.profitColor);
    } else if (value < 0) {
      return const Color(AppConstants.lossColor);
    } else {
      return const Color(AppConstants.neutralColor);
    }
  }

  static Color getPerformanceColor(double winRate) {
    if (winRate >= AppConstants.excellentWinRate) {
      return const Color(AppConstants.profitColor);
    } else if (winRate >= AppConstants.goodWinRate) {
      return Colors.orange;
    } else {
      return const Color(AppConstants.lossColor);
    }
  }

  // Validation helpers
  static bool isValidAmount(String input) {
    final value = double.tryParse(input);
    return value != null && value > 0 && value <= AppConstants.maxAmount;
  }

  static bool isValidPrice(String input) {
    final value = double.tryParse(input);
    return value != null && value > 0 && value <= AppConstants.maxPrice;
  }

  static bool isValidCrypto(String input) {
    return input.isNotEmpty && input.length <= 10 && RegExp(r'^[A-Z0-9]+$').hasMatch(input);
  }

  // Time helpers
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // String helpers
  static String truncateString(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Performance calculation helpers
  static String getPerformanceGrade(double winRate) {
    if (winRate >= 80) return 'Excellent';
    if (winRate >= 70) return 'Very Good';
    if (winRate >= 60) return 'Good';
    if (winRate >= 50) return 'Average';
    if (winRate >= 40) return 'Below Average';
    return 'Poor';
  }

  static String getRiskLevel(double riskRewardRatio) {
    if (riskRewardRatio >= 3.0) return 'Conservative';
    if (riskRewardRatio >= 2.0) return 'Moderate';
    if (riskRewardRatio >= 1.0) return 'Aggressive';
    return 'High Risk';
  }

  // Snackbar helpers
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Dialog helpers
  static Future<bool?> showConfirmationDialog(
    BuildContext context,
    String title,
    String content,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}