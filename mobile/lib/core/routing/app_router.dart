import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/stock/stock_screen.dart';
import '../../presentation/screens/chat/chat_screen.dart';
import '../../presentation/screens/recipes/recipes_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';

class AppRouter {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Vérifier si l'utilisateur est authentifié
  static Future<String?> _checkAuth(BuildContext context, GoRouterState state) async {
    final token = await _storage.read(key: 'auth_token');
    final isLoginPage = state.uri.path == '/login' || state.uri.path == '/register';
    
    // Si pas de token et pas sur la page de login, rediriger vers login
    if (token == null && !isLoginPage) {
      return '/login';
    }
    
    // Si token existe et sur la page de login, rediriger vers dashboard
    if (token != null && isLoginPage) {
      return '/dashboard';
    }
    
    return null; // Pas de redirection nécessaire
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: _checkAuth,
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/stock',
        name: 'stock',
        builder: (context, state) => const StockScreen(),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/recipes',
        name: 'recipes',
        builder: (context, state) => const RecipesScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}

