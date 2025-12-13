import 'package:equatable/equatable.dart';

class StockItemModel extends Equatable {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final int? categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final DateTime? expiryDate;
  final DateTime addedAt;
  final DateTime? updatedAt;
  final String? notes;

  const StockItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.expiryDate,
    required this.addedAt,
    this.updatedAt,
    this.notes,
  });

  // Helper pour parser les dates (format YYYY-MM-DD)
  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue is DateTime) {
      return dateValue;
    }
    if (dateValue is String) {
      // Si c'est juste une date (YYYY-MM-DD), ajouter l'heure à minuit
      if (dateValue.length == 10) {
        return DateTime.parse('${dateValue}T00:00:00');
      }
      return DateTime.parse(dateValue);
    }
    throw Exception('Format de date invalide: ${dateValue.runtimeType}');
  }

  // Helper pour parser les datetime (format ISO avec heure)
  static DateTime _parseDateTime(dynamic dateTimeValue) {
    if (dateTimeValue is DateTime) {
      return dateTimeValue;
    }
    if (dateTimeValue is String) {
      return DateTime.parse(dateTimeValue);
    }
    throw Exception('Format de datetime invalide: ${dateTimeValue.runtimeType}');
  }

  factory StockItemModel.fromJson(Map<String, dynamic> json) {
    // Gérer les UUID qui peuvent être des String ou des objets
    String id;
    if (json['id'] is String) {
      id = json['id'] as String;
    } else {
      id = json['id'].toString();
    }

    // Gérer category_id qui peut être null, int, ou String
    int? categoryId;
    if (json['category_id'] != null) {
      if (json['category_id'] is int) {
        categoryId = json['category_id'] as int;
      } else if (json['category_id'] is String) {
        categoryId = int.tryParse(json['category_id'] as String);
      } else {
        categoryId = null;
      }
    }

    return StockItemModel(
      id: id,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      categoryId: categoryId,
      categoryName: json['category_name'] as String?,
      categoryIcon: json['category_icon'] as String?,
      expiryDate: json['expiry_date'] != null
          ? _parseDate(json['expiry_date'])
          : null,
      addedAt: _parseDateTime(json['added_at']),
      updatedAt: json['updated_at'] != null
          ? _parseDateTime(json['updated_at'])
          : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      if (categoryId != null) 'category_id': categoryId,
      if (expiryDate != null) 'expiry_date': expiryDate!.toIso8601String().split('T')[0],
      if (notes != null) 'notes': notes,
    };
  }

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final daysUntilExpiry = expiryDate!.difference(now).inDays;
    return daysUntilExpiry >= 0 && daysUntilExpiry <= 3;
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  @override
  List<Object?> get props => [id, name, quantity, unit, categoryId, expiryDate];
}

