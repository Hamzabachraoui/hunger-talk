import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/stock_item_model.dart';
import '../../core/theme/app_colors.dart';

class StockItemCard extends StatelessWidget {
  final StockItemModel item;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const StockItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  Color _getStatusColor() {
    if (item.isExpired) return AppColors.stockExpired;
    if (item.isExpiringSoon) return AppColors.stockExpiring;
    return AppColors.stockNormal;
  }

  String _getStatusText() {
    if (item.isExpired) return 'Expiré';
    if (item.isExpiringSoon) return 'Expire bientôt';
    return 'En stock';
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.quantity.toStringAsFixed(1)} ${item.unit}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getStatusColor(), width: 1),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _getStatusColor(),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              if (item.categoryName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (item.categoryIcon != null)
                      Text(
                        item.categoryIcon!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    if (item.categoryIcon != null) const SizedBox(width: 4),
                    Text(
                      item.categoryName!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ],
              if (item.expiryDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Expire le ${dateFormat.format(item.expiryDate!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: item.isExpired || item.isExpiringSoon
                                ? _getStatusColor()
                                : AppColors.textSecondary,
                            fontWeight: item.isExpired || item.isExpiringSoon
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                    ),
                  ],
                ),
              ],
              if (onEdit != null || onDelete != null) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null)
                      TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Modifier'),
                      ),
                    if (onDelete != null)
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Supprimer'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

