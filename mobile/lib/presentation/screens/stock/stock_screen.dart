import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/stock_provider.dart';
import '../../widgets/stock_item_card.dart';
import '../../../data/models/stock_item_model.dart';
import '../../../core/theme/app_colors.dart';
import 'add_edit_stock_item_screen.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  String _sortBy = 'expiry_date';
  int? _selectedCategoryId;
  bool _showExpiringSoon = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockProvider>().loadStock();
    });
  }

  void _showDeleteDialog(StockItemModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le produit'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${item.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              if (!context.mounted) return;
              Navigator.pop(context);
              final stockProvider = context.read<StockProvider>();
              final success = await stockProvider.deleteItem(item.id);
              if (!context.mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Produit supprimé')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(stockProvider.error ?? 'Erreur'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  List<StockItemModel> _filterAndSort(List<StockItemModel> items) {
    var filtered = items;

    // Filtrer par catégorie
    if (_selectedCategoryId != null) {
      filtered = filtered.where((item) => item.categoryId == _selectedCategoryId).toList();
    }

    // Filtrer les produits expirant bientôt
    if (_showExpiringSoon) {
      filtered = filtered.where((item) => item.isExpiringSoon).toList();
    }

    // Trier
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'name':
          return a.name.compareTo(b.name);
        case 'added_at':
          return b.addedAt.compareTo(a.addedAt);
        case 'expiry_date':
        default:
          if (a.expiryDate == null && b.expiryDate == null) return 0;
          if (a.expiryDate == null) return 1;
          if (b.expiryDate == null) return -1;
          return a.expiryDate!.compareTo(b.expiryDate!);
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Stock'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => _FilterBottomSheet(
                  sortBy: _sortBy,
                  selectedCategoryId: _selectedCategoryId,
                  showExpiringSoon: _showExpiringSoon,
                  onSortChanged: (value) => setState(() => _sortBy = value),
                  onCategoryChanged: (value) => setState(() => _selectedCategoryId = value),
                  onExpiringSoonChanged: (value) => setState(() => _showExpiringSoon = value),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<StockProvider>().loadStock(),
          ),
        ],
      ),
      body: Consumer<StockProvider>(
        builder: (context, stockProvider, _) {
          if (stockProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (stockProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stockProvider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => stockProvider.loadStock(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final items = _filterAndSort(stockProvider.items);

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text(
                    stockProvider.items.isEmpty ? 'Aucun produit' : 'Aucun résultat',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stockProvider.items.isEmpty
                        ? 'Ajoutez votre premier produit au stock'
                        : 'Essayez de modifier les filtres',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => stockProvider.loadStock(),
            child: ListView.builder(
              itemCount: items.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                return StockItemCard(
                  item: item,
                  onEdit: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditStockItemScreen(item: item),
                      ),
                    );
                    if (result == true && mounted) {
                      stockProvider.loadStock();
                    }
                  },
                  onDelete: () => _showDeleteDialog(item),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (!mounted) return;
          final navigator = Navigator.of(context);
          final stockProvider = context.read<StockProvider>();
          
          final result = await navigator.push(
            MaterialPageRoute(
              builder: (context) => const AddEditStockItemScreen(),
            ),
          );
          if (result == true && mounted) {
            stockProvider.loadStock();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterBottomSheet extends StatelessWidget {
  final String sortBy;
  final int? selectedCategoryId;
  final bool showExpiringSoon;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<int?> onCategoryChanged;
  final ValueChanged<bool> onExpiringSoonChanged;

  const _FilterBottomSheet({
    required this.sortBy,
    required this.selectedCategoryId,
    required this.showExpiringSoon,
    required this.onSortChanged,
    required this.onCategoryChanged,
    required this.onExpiringSoonChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtres et Tri',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          Text(
            'Trier par',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'expiry_date', label: Text('Date expiration')),
              ButtonSegment(value: 'name', label: Text('Nom')),
              ButtonSegment(value: 'added_at', label: Text('Date ajout')),
            ],
            selected: {sortBy},
            onSelectionChanged: (Set<String> newSelection) {
              onSortChanged(newSelection.first);
            },
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Produits expirant bientôt'),
            value: showExpiringSoon,
            onChanged: onExpiringSoonChanged,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  onCategoryChanged(null);
                  onExpiringSoonChanged(false);
                  onSortChanged('expiry_date');
                  Navigator.pop(context);
                },
                child: const Text('Réinitialiser'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Appliquer'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
