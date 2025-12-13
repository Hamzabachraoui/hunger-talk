import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/stock_item_model.dart';
import '../../core/constants/app_constants.dart';

class StockService {
  final ApiService _apiService = ApiService();

  Future<List<StockItemModel>> getStock({
    int? categoryId,
    bool? expiredSoon,
    String? sortBy,
  }) async {
    final queryParams = <String, String>{};
    if (categoryId != null) queryParams['category_id'] = categoryId.toString();
    if (expiredSoon != null) queryParams['expired_soon'] = expiredSoon.toString();
    if (sortBy != null) queryParams['sort_by'] = sortBy;

    final queryString = queryParams.isEmpty
        ? ''
        : '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';

    debugPrint('📦 [STOCK SERVICE] Récupération du stock...');
    final response = await _apiService.get('${AppConstants.stock}$queryString');
    debugPrint('📦 [STOCK SERVICE] Réponse reçue: ${response.runtimeType}');
    
    if (response == null) {
      debugPrint('⚠️ [STOCK SERVICE] Réponse null, retour liste vide');
      return [];
    }
    if (response is! List) {
      debugPrint('❌ [STOCK SERVICE] Format invalide: ${response.runtimeType}, attendu List');
      throw Exception('Format de réponse invalide: attendu List, reçu ${response.runtimeType}');
    }
    final List<dynamic> data = response;
    debugPrint('✅ [STOCK SERVICE] ${data.length} item(s) reçu(s)');
    final items = data.map((json) {
      if (json is! Map<String, dynamic>) {
        throw Exception('Format d\'élément invalide: attendu Map, reçu ${json.runtimeType}');
      }
      return StockItemModel.fromJson(json);
    }).toList();
    debugPrint('✅ [STOCK SERVICE] ${items.length} item(s) parsé(s)');
    return items;
  }

  Future<StockItemModel> addItem(StockItemModel item) async {
    final data = item.toJson();
    debugPrint('📦 [STOCK] Données envoyées: $data');
    final response = await _apiService.post(AppConstants.stock, data);
    debugPrint('📦 [STOCK] Réponse reçue: $response');
    if (response == null || response is! Map<String, dynamic>) {
      throw Exception('Format de réponse invalide: attendu Map, reçu ${response?.runtimeType ?? "null"}');
    }
    return StockItemModel.fromJson(response);
  }

  Future<StockItemModel> updateItem(String id, StockItemModel item) async {
    // Enlever le trailing slash pour construire l'URL correctement
    final endpoint = AppConstants.stock.endsWith('/') 
        ? AppConstants.stock.substring(0, AppConstants.stock.length - 1)
        : AppConstants.stock;
    final response = await _apiService.put('$endpoint/$id', item.toJson());
    if (response == null || response is! Map<String, dynamic>) {
      throw Exception('Format de réponse invalide: attendu Map, reçu ${response?.runtimeType ?? "null"}');
    }
    return StockItemModel.fromJson(response);
  }

  Future<void> deleteItem(String id) async {
    // Enlever le trailing slash pour construire l'URL correctement
    final endpoint = AppConstants.stock.endsWith('/') 
        ? AppConstants.stock.substring(0, AppConstants.stock.length - 1)
        : AppConstants.stock;
    await _apiService.delete('$endpoint/$id');
  }
}

