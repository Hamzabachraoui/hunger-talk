import '../config/app_config.dart';

class AppConstants {
  // API Configuration
  // Utilise AppConfig pour la configuration flexible
  // Pour tester sur téléphone, modifiez AppConfig.baseUrl
  static String get baseUrl => AppConfig.baseUrl;
  static String get apiBaseUrl => AppConfig.apiBaseUrl;
  
  // Endpoints
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authLogout = '/auth/logout';
  
  static const String stock = '/stock';
  static const String stockCategories = '/stock/categories';
  static const String stockStatistics = '/stock/statistics/summary';
  
  static const String chat = '/chat';
  static const String chatHistory = '/chat/history';
  
  static const String recipes = '/recipes';
  static const String recommendations = '/recommendations';
  
  static const String nutritionDaily = '/nutrition/daily';
  static const String nutritionWeekly = '/nutrition/weekly';
  
  static const String notifications = '/notifications';
  
  static const String shoppingList = '/shopping-list';
  
  static const String userPreferences = '/user/preferences';
  static const String userProfile = '/user/me';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String preferencesKey = 'user_preferences';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration chatTimeout = Duration(seconds: 60);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // Stock Settings
  static const int expiringSoonDays = 3;
  static const double lowStockThreshold = 0.2; // 20% restant
}

