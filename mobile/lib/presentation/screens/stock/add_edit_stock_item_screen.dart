import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/stock_provider.dart';
import '../../../data/models/stock_item_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/category_service.dart';

class AddEditStockItemScreen extends StatefulWidget {
  final StockItemModel? item;

  const AddEditStockItemScreen({super.key, this.item});

  @override
  State<AddEditStockItemScreen> createState() => _AddEditStockItemScreenState();
}

class _AddEditStockItemScreenState extends State<AddEditStockItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime? _expiryDate;
  int? _selectedCategoryId;
  List<dynamic> _categories = [];
  bool _isLoadingCategories = true;

  final CategoryService _categoryService = CategoryService();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _quantityController.text = widget.item!.quantity.toString();
      _unitController.text = widget.item!.unit;
      _expiryDate = widget.item!.expiryDate;
      _selectedCategoryId = widget.item!.categoryId;
      _notesController.text = widget.item!.notes ?? '';
    } else {
      _unitController.text = 'g';
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final quantity = double.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La quantité doit être supérieure à 0')),
      );
      return;
    }

    final item = StockItemModel(
      id: widget.item?.id ?? '',
      name: _nameController.text.trim(),
      quantity: quantity,
      unit: _unitController.text.trim(),
      categoryId: _selectedCategoryId,
      expiryDate: _expiryDate,
      addedAt: widget.item?.addedAt ?? DateTime.now(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    final stockProvider = context.read<StockProvider>();
    bool success;

    if (widget.item != null) {
      success = await stockProvider.updateItem(item.id, item);
    } else {
      success = await stockProvider.addItem(item);
    }

    if (!mounted) return;
    
    if (success) {
      context.pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.item != null ? 'Produit modifié' : 'Produit ajouté'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(stockProvider.error ?? 'Erreur'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text(widget.item != null ? 'Modifier le produit' : 'Ajouter un produit'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Enregistrer'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du produit *',
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantité *',
                        prefixIcon: Icon(Icons.scale_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une quantité';
                        }
                        final qty = double.tryParse(value);
                        if (qty == null || qty <= 0) {
                          return 'Quantité invalide';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(
                        labelText: 'Unité *',
                        prefixIcon: Icon(Icons.straighten),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une unité';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isLoadingCategories)
                const CircularProgressIndicator()
              else
                DropdownButtonFormField<int>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text('Aucune catégorie'),
                    ),
                    ..._categories.map((cat) {
                      final catId = cat['id'];
                      final catName = cat['name'] as String? ?? 'Sans nom';
                      final catIcon = cat['icon'] as String?;
                      
                      return DropdownMenuItem<int>(
                        value: catId is int ? catId : (catId is String ? int.tryParse(catId) : null),
                        child: Row(
                          children: [
                            if (catIcon != null)
                              Text(
                                catIcon,
                                style: const TextStyle(fontSize: 20),
                              ),
                            if (catIcon != null) const SizedBox(width: 8),
                            Text(catName),
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date d\'expiration',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    _expiryDate != null
                        ? DateFormat('dd/MM/yyyy').format(_expiryDate!)
                        : 'Sélectionner une date',
                    style: TextStyle(
                      color: _expiryDate != null
                          ? Theme.of(context).textTheme.bodyLarge?.color
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  prefixIcon: Icon(Icons.note_outlined),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

