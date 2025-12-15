import 'package:flutter_test/flutter_test.dart';

import 'package:hunger_talk/data/models/stock_item_model.dart';

void main() {
  test('StockItemModel.fromJson gère les formats communs', () {
    final model = StockItemModel.fromJson(const {
      'id': 'abc-123',
      'name': 'Lait',
      'quantity': 2.5,
      'unit': 'L',
      'category_id': '4',
      'expiry_date': '2025-12-01',
      'added_at': '2025-01-10T10:00:00Z',
      'updated_at': '2025-01-11T10:00:00Z',
      'notes': 'Bio',
    });

    expect(model.id, 'abc-123');
    expect(model.quantity, 2.5);
    expect(model.categoryId, 4);
    expect(model.expiryDate, DateTime(2025, 12, 1));
    expect(model.addedAt, DateTime.parse('2025-01-10T10:00:00Z'));
    expect(model.updatedAt, DateTime.parse('2025-01-11T10:00:00Z'));
    expect(model.notes, 'Bio');
  });

  test('toJson n\'envoie que les champs attendus', () {
    final model = StockItemModel(
      id: '1',
      name: 'Pates',
      quantity: 1,
      unit: 'kg',
      categoryId: 2,
      expiryDate: DateTime(2025, 5, 1),
      addedAt: DateTime(2025, 1, 1),
      notes: 'Integrales',
    );

    final json = model.toJson();

    expect(json['name'], 'Pates');
    expect(json['quantity'], 1);
    expect(json['unit'], 'kg');
    expect(json['category_id'], 2);
    expect(json['expiry_date'], '2025-05-01');
    expect(json['notes'], 'Integrales');
    expect(json.containsKey('id'), isFalse);
  });
}

