class AppConstants {
  // Supported cryptocurrencies
  static const List<String> popularCryptos = [
    'BTC',
    'ETH',
    'BNB',
    'XRP',
    'ADA',
    'DOGE',
    'SOL',
    'TRX',
    'DOT',
    'AVAX',
    'MATIC',
    'SHIB',
    'LTC',
    'UNI',
    'ATOM',
    'LINK',
    'XLM',
    'BCH',
    'ICP',
    'FIL',
  ];

  // Supported currencies
  static const List<String> supportedCurrencies = [
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'AUD',
    'CAD',
    'CHF',
    'CNY',
    'KRW',
    'INR',
  ];

  // Trade types
  static const List<String> tradeTypes = ['Buy', 'Sell'];

  // App settings
  static const String appName = 'Trade Trackr';
  static const String appVersion = '1.0.0';
  static const String databaseName = 'trades.db';
  static const int databaseVersion = 1;

  // Date formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayDateTimeFormat = 'MMM dd, yyyy - HH:mm';

  // Validation constants
  static const double maxAmount = 1000000000; // 1 billion
  static const double maxPrice = 1000000000; // 1 billion
  static const int maxRationaleLength = 1000;

  // Export constants
  static const String csvMimeType = 'text/csv';
  static const String exportDateFormat = 'yyyyMMdd_HHmmss';

  // Chart constants
  static const int maxChartPoints = 1000;
  static const double chartAnimationDuration = 1.5;

  // Image constants
  static const int maxImageSize = 1024; // pixels
  static const int imageQuality = 80; // percentage
  static const List<String> supportedImageFormats = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.bmp',
    '.webp'
  ];

  // Performance metrics
  static const double goodWinRate = 60.0; // percentage
  static const double excellentWinRate = 70.0; // percentage
  static const double goodProfitFactor = 1.5;
  static const double excellentProfitFactor = 2.0;

  // Color codes for P&L
  static const int profitColor = 0xFF4CAF50; // Green
  static const int lossColor = 0xFFF44336; // Red
  static const int neutralColor = 0xFF9E9E9E; // Grey
  static const int openTradeColor = 0xFFFF9800; // Orange
}