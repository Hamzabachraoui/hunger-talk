import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _user != null;

  AuthProvider() {
    _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    try {
      _token = await _secureStorage.read(key: 'auth_token');
      if (_token != null) {
        // TODO: Charger les données utilisateur depuis l'API
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors du chargement de l\'auth: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🔐 [AUTH PROVIDER] Début de la connexion');
      final response = await _authService.login(email, password);
      
      debugPrint('📦 [AUTH PROVIDER] Réponse reçue: $response');
      debugPrint('📦 [AUTH PROVIDER] Clés dans la réponse: ${response.keys.toList()}');
      
      // Vérifier que la réponse contient access_token
      if (!response.containsKey('access_token')) {
        debugPrint('❌ [AUTH PROVIDER] access_token manquant dans la réponse');
        throw Exception('Réponse de connexion invalide: token manquant. Réponse: $response');
      }
      
      _token = response['access_token'] as String?;
      if (_token == null) {
        throw Exception('Token est null');
      }
      
      debugPrint('✅ [AUTH PROVIDER] Token récupéré: ${_token!.substring(0, 20)}...');
      
      // Le backend ne retourne pas les données utilisateur dans la réponse de login
      // On crée un UserModel minimal avec l'email (on pourra charger les détails plus tard)
      _user = UserModel(
        id: '', // Sera chargé plus tard si nécessaire
        email: email,
        firstName: '',
        lastName: '',
        createdAt: DateTime.now(),
      );

      // Sauvegarder le token AVANT de notifier les listeners
      debugPrint('💾 [AUTH PROVIDER] Sauvegarde du token dans le storage...');
      await _secureStorage.write(key: 'auth_token', value: _token!);
      debugPrint('✅✅✅ [AUTH PROVIDER] Token sauvegardé avec succès !');
      
      // Vérifier que le token est bien sauvegardé
      final savedToken = await _secureStorage.read(key: 'auth_token');
      if (savedToken == null) {
        debugPrint('❌❌❌ [AUTH PROVIDER] ERREUR: Token non sauvegardé !');
      } else {
        debugPrint('✅✅✅ [AUTH PROVIDER] Token vérifié dans le storage (${savedToken.substring(0, 20)}...)');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ [AUTH] Erreur de connexion: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String firstName, String lastName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.register(email, password, firstName, lastName);
      
      // Vérifier que la réponse contient access_token
      if (!response.containsKey('access_token')) {
        throw Exception('Réponse d\'inscription invalide: token manquant');
      }
      
      _token = response['access_token'] as String?;
      if (_token == null) {
        throw Exception('Token est null');
      }
      
      // Le backend ne retourne pas les données utilisateur dans la réponse d'inscription
      // On crée un UserModel avec les données fournies
      _user = UserModel(
        id: '', // Sera chargé plus tard si nécessaire
        email: email,
        firstName: firstName,
        lastName: lastName,
        createdAt: DateTime.now(),
      );

      await _secureStorage.write(key: 'auth_token', value: _token!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ [AUTH] Erreur d\'inscription: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      if (_token != null) {
        await _authService.logout(_token!);
      }
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');
    } finally {
      _token = null;
      _user = null;
      await _secureStorage.delete(key: 'auth_token');
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

