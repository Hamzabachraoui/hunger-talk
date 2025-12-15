import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/stock_item_model.dart';
import '../../data/services/stock_service.dart';

class StockProvider with ChangeNotifier {
  final StockService _stockService = StockService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List<StockItemModel> _items = [];
  bool _isLoading = false;
  String? _error;

  List<StockItemModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadStock() async {
    // Vérifier que le token existe avant de faire la requête
    final token = await _storage.read(key: 'auth_token');
    if (token == null) {
      debugPrint('⚠️ [STOCK PROVIDER] Token manquant, impossible de charger le stock');
      _error = 'Non authentifié. Veuillez vous reconnecter.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('📦 [STOCK PROVIDER] Chargement du stock...');
      _items = await _stockService.getStock();
      debugPrint('✅ [STOCK PROVIDER] Stock chargé: ${_items.length} item(s)');
      if (_items.isNotEmpty) {
        debugPrint('   Premier item: ${_items.first.name}');
      }
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('❌ [STOCK PROVIDER] Erreur lors du chargement: $e');
      debugPrint('   Stack: $stackTrace');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addItem(StockItemModel item) async {
    try {
      debugPrint('📦 [STOCK PROVIDER] Ajout d\'un item: ${item.name}');
      final newItem = await _stockService.addItem(item);
      debugPrint('✅ [STOCK PROVIDER] Item ajouté avec succès: ${newItem.id}');
      _items.add(newItem);
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [STOCK PROVIDER] Erreur lors de l\'ajout: $e');
      debugPrint('   Stack: $stackTrace');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateItem(String id, StockItemModel item) async {
    try {
      final updatedItem = await _stockService.updateItem(id, item);
      final index = _items.indexWhere((i) => i.id == id);
      if (index != -1) {
        _items[index] = updatedItem;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteItem(String id) async {
    try {
      await _stockService.deleteItem(id);
      _items.removeWhere((i) => i.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

